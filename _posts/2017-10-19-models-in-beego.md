---
id: 4449
title: Models in Beego
date: 2017-10-19T04:37:42+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4449
permalink: /2017/10/models-in-beego/
categories:
  - Go
tags:
  - design patterns
  - golang
  - programming
---
Before we start creating models, we need to make sure our app can connect to our database. At the time of this writing Beego supports MySQL, PostgreSQL and Sqlite3.

We can have the ORM connect to our database from our main.go file:

```go
package main

import (
    "os"
    "strings"

    _ "app/routers"

    "github.com/astaxie/beego"
    "github.com/astaxie/beego/orm"
    _ "github.com/go-sql-driver/mysql"
)

func init() {
    orm.RegisterDriver("mysql", orm.DRMySQL)
    parts := []string{os.Getenv("MYSQL_USER"), ":", os.Getenv("MYSQL_PASSWORD"),
            "@tcp(", os.Getenv("MYSQL_HOST"), ":3306)/", os.Getenv("MYSQL_DATABASE")}
    orm.RegisterDataBase("default", "mysql", strings.Join(parts, ""))
}

func main() {
    if beego.BConfig.RunMode == "dev" {
        beego.BConfig.WebConfig.DirectoryIndex = true
        beego.BConfig.WebConfig.StaticDir["/swagger"] = "swagger"
    }
    beego.Run()
}
```

<!--more-->

If you are not familiar with the [init function](https://golang.org/doc/effective_go.html#init), it works similar to a constructor at the package level. The important thing here is that _init()_ will be executed before _main()_.

In the example above, I use strings.Join to generate a connection string. I do this because having the parts that make the connection string as environment variables makes it easier for me to modify them for different environments. The format of the connection string is as follows:

```
user:password@tcp(host:port)/database_name
```

With this, Beego has now access to our database.

## The database

Models are and abstraction of our database, which means they should represent the state of the database. One way to do this is by writing models in your application and have these models transform the database into the state it needs. Beego allows you to do this with the _orm.RunSyncdb_ function.

Another way to keep the models and database in sync (this is the way I prefer) is by having the DB be the source of truth. This means, database changes are done via [database migrations](http://ncona.com/2017/10/database-migrations-in-beego/) and the models are manually modified to match the DB.

The reason I prefer to use database migrations is because I feel it gives me more control. You could have your program execute RunSyncdb every time it is started and things might work well, however, if your database is very busy at the moment you do your deployment, you might lock the database for a long time if you are modifying the structure of a table or adding an index. With migrations, since you have to run them manually, you can choose the best moment to make the DB changes without blocking deployments.

## Models

Models live inside the _models/_ folder inside the project. Lets look at a simple model in _models/user.go_:

```go
package models

import (
    "github.com/astaxie/beego/orm"
)

type User struct {
    Id         int
    Username   string
}

func init() {
    orm.RegisterModel(new(User))
}
```

This is a very simple model with two fields: Id and Username. These two fields correspond to the id and username columns on the user table. To be able to use this model with the ORM, we need to register it, which we do in the init function.

The model can be customized in many ways, so it is probably a good idea to look at the documentation. Here are some examples of things that can be done:

```go
package models

import (
    "time"

    "github.com/astaxie/beego/orm"
)

type User struct {
    Id         int
    Username   string
    CreatedAt  time.Time `orm:"auto_now_add;type(datetime)"`
    UpdatedAt  time.Time `orm:"auto_now;type(datetime);null"`
    PictureUrl string    `orm:"null"`
}

func init() {
    orm.RegisterModel(new(User))
}

func (u *User) TableName() string {
    return "users"
}
```

We added some annotations to have the ORM automatically populate the created\_at and updated\_at columns. We also made some of the columns default value null (If not specified, the default value is empty). Finally, we specified a custom table name for this model. Look at the documentation for more ways to customize the model.

## Queries

Now that we have a model, it&#8217;s time to start using it.

To get a record by id:

```go
o := orm.NewOrm()
user := models.User{Id: 1}
err := o.Read(&user)
```

After this, the user variable will have all the fields filled with the values from the database.

Query a record by other fields:

```go
o := orm.NewOrm()
user := models.User{
    Issuer:   "tacos",
    IssuerId: "1234",
}
err := o.Read(&user, "Issuer", "IssuerId")
```

Add a new record:

```go
o := orm.NewOrm()
user := models.User{
    Issuer:   "tacos",
    IssuerId: "1234",
}
err := o.Insert(&user)
```

For updating a record, you first need to get the record, do the modification and then call Update:

```go
user.Issuer = "new issuer"
_, err = o.Update(&user)
```

## Advanced queries

For doing more [advanced queries](https://beego.me/docs/mvc/model/query.md) we need to use QuerySetters. The documentation shows all the possible ways you can create a query, but here is an example:

```go
o := orm.NewOrm()

var users []*User
qs := o.QueryTable("users").Filter("user_id__in", userIds).
    OrderBy("-created_at").Limit(10).Filter("created_at__lt", until)

qs.All(&user)
```

You can see above that we use different functions to create the query we need, including limit, order by and other where clauses. After executing the query, we store the result in an array of *User by calling _All_ on the QuerySetter.

## Transactions

Beego also supports transactions. They look a little like this:

```go
o := orm.NewOrm()

o.Begin()

currentUser := controller.Ctx.Input.GetData("currentUser").(models.User)
user := models.User{Id: currentUser.Id}
o.Read(&user)

newAction := models.Action{
    User:   &user,
}
_, err := o.Insert(&newAction)
if err != nil {
    o.Rollback()
    return
}

user.Points = user.Points + 1
_, err = o.Update(&user)
if err != nil {
    o.Rollback()
    return
}

o.Commit()
```

## Joins

Lets say we have a table that has a relationship with another table. This can be expressed in the model like this:

```go
type Like struct {
    Id        int
    CreatedAt time.Time `orm:"auto_now_add;type(datetime)"`
    User      *User     `orm:"rel(fk)"`
    Post      *Post     `orm:"rel(fk)"`
}
```

We have a model that has two fields that are foreign keys to other tables. You can see that the type of that field ends up being the related model and both fields are annotated as a foreign key.

This annotation allows us to make queries that include fields in those related tables:

```go
o := orm.NewOrm()

var likes []*Like
qs := o.QueryTable("likes").Filter("user_id__in", userIds).RelatedSel()
qs.All(&likes)
```

This query will return the likes, but it will also return the related users and posts. The cool thing is that it does the join for you so it ends up doing just one query.

## Debugging

As your data access patters become more complex, you will most likely want to know what the ORM is doing to make sure you don&#8217;t affect your database by sending too many queries, or queries that are too heavy. This is easy to do with a simple setting (You should only turn on this setting for development):

```go
if env == "dev" {
    orm.Debug = true
}
```

This will add information about the queries being made to the logs.

## Conclusion

In this post I demonstrated some of the things that can be done with Beego&#8217;s ORM. I didn&#8217;t go into much detail into the functionality nor covered all the things you can do. I recommend you look at the documentation for a more complete and up-to-date reference.
