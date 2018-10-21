---
id: 4432
title: Database migrations in Beego
date: 2017-10-12T02:19:33+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4432
permalink: /2017/10/database-migrations-in-beego/
tags:
  - automation
  - design_patterns
  - golang
  - mysql
  - productivity
  - programming
---
A few weeks ago I wrote an article [showing how to start a simple Beego server](http://ncona.com/2017/10/introduction-to-beego/). Today I&#8217;m going to go a little further and explain how to start building your database using migrations. For my examples I will use a MySQL server with an empty database (no tables) named beego.

It is possible to just log in to a database server and type the SQL commands necessary to create or modify tables when we need to, but using migrations helps keep track of the changes made to the database over time. This provides something similar to version control at the database level.

If we need to create a new table, we would start by creating a new migration file using the bee tool:

```
bee generate migration create_user_table
```

<!--more-->

This command will create a file inside _database/migrations_ folder. The file name contains the date, time and name of the migration. In my case it ended up with this name: `_20170915\_074754\_create\_user\_table.go_`. And the content looks like this:

```go
package main

import (
    "github.com/astaxie/beego/migration"
)

// DO NOT MODIFY
type CreateUserTable_20170915_074754 struct {
    migration.Migration
}

// DO NOT MODIFY
func init() {
    m := &CreateUserTable_20170915_074754{}
    m.Created = "20170915_074754"

    migration.Register("CreateUserTable_20170915_074754", m)
}

// Run the migrations
func (m *CreateUserTable_20170915_074754) Up() {
    // use m.SQL("CREATE TABLE ...") to make schema update
}

// Reverse the migrations
func (m *CreateUserTable_20170915_074754) Down() {
    // use m.SQL("DROP TABLE ...") to reverse schema update
}
```

This is a skeleton migration file. We are supposed to modify the Up and Down functions with the SQL necessary to create our table (or modify the table, or whichever database operation we want to do).

Since the name of the migration is `_create\_user\_table_`, that is what I&#8217;m going to do:

```go
// Run the migrations
func (m *CreateUserTable_20170915_074754) Up() {
    m.SQL("CREATE TABLE user(id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255))")
}

// Reverse the migrations
func (m *CreateUserTable_20170915_074754) Down() {
    m.SQL("DROP TABLE user")
}
```

We have created our first migration file. Now we need to run it.

Running it should be as easy as executing one command. Sadly, there is a [little bug](https://github.com/beego/bee/issues/447) that breaks the command:

```
bee migrate -conn="${MYSQL_USER}:${MYSQL_PASSWORD}@tcp(${MYSQL_HOST}:3306)/${MYSQL_DATABASE}"
______
| ___ \
| |_/ /  ___   ___
| ___ \ / _ \ / _ \
| |_/ /|  __/|  __/
\____/  \___| \___| v1.9.1
2017/09/16 06:11:44 INFO     ▶ 0001 Using 'mysql' as 'driver'
2017/09/16 06:11:44 INFO     ▶ 0002 Using 'root:rootpassword@tcp(mysql:3306)/beego' as 'conn'
2017/09/16 06:11:44 INFO     ▶ 0003 Running all outstanding migrations
2017/09/16 06:11:44 INFO     ▶ 0004 Creating 'migrations' table...
2017/09/16 06:11:46 ERROR    ▶ 0005 Could not build migration binary: exit status 1
2017/09/16 06:11:46 ERROR    ▶ 0006 |> m.go:10:2: cannot find package "github.com/lib/pq" in any of:
2017/09/16 06:11:46 ERROR    ▶ 0007 |>    /go/src/app/vendor/github.com/lib/pq (vendor tree)
2017/09/16 06:11:46 ERROR    ▶ 0008 |>    /usr/local/go/src/github.com/lib/pq (from $GOROOT)
2017/09/16 06:11:46 ERROR    ▶ 0009 |>    /go/src/github.com/lib/pq (from $GOPATH)
2017/09/16 06:11:46 WARN     ▶ 0010 Could not remove temporary file: remove m: no such file or directory
```

I created a [fork that fixes this bug](https://github.com/soonick/bee), and submitted a [pull request](https://github.com/beego/bee/pull/476) that hopefully will be merged soon. In the meantime, I&#8217;m using my fork to run the migration. The migration runs the SQL command as expected and we end up with a _user_ table.

If for some reason you want to rollback a migration (This could be very dangerous, so be careful when doing this), there is also a command you can use:

```
bee migrate rollback -conn="${MYSQL_USER}:${MYSQL_PASSWORD}@tcp(${MYSQL_HOST}:3306)/${MYSQL_DATABASE}"
```

This command will run the Down() function of the last applied migration.

## Last remarks

Migrations are very useful for keeping track of the changes made to your database and to set up lower environments (development, qa, etc&#8230;), but I recommend to not automate the process in production.

For a development environment it is very convenient to run all the migrations in your local database and end with a database that matches production. This is really nice.

For a qa or testing environment, you could run pending migrations automatically as part of the deploy process. Every time code is pushed to the environment, the migrations will be automatically executed against the database for that environment. This can work pretty well assuming you don&#8217;t accidentally create a migration that does something destructive that you later regret. Anyway, for an environment that is not production, you should be able to recover from a failure like this.

For production I prefer to run the migrations manually. This ensures that the person running the command is someone that understands the system well enough that they have been granted access to the production database. Another good thing is that you can execute the query at a time when your database load is low, so it won&#8217;t affect your users.

Another thing to keep in mind with migrations is that they are not magical. Backwards incompatible changes have to be coordinated and done carefully. If you are going to remove a column, make sure that nobody is using it. Also be careful with forward changes. Since database migrations in production are applied manually and not exactly at the same time the code is deployed, be careful not to deploy code that depends on a database field that is not in production yet.
