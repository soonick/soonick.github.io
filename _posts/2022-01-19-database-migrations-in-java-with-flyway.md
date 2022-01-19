---
title: Flyway - Version control for Databases in Java
author: adrian.ancona
layout: post
date: 2022-01-19
permalink: /2022/01/flyway-version-control-for-databases-in-java
tags:
  - databases
  - design_patterns
  - programming
---

## Database migrations

Database migrations (or Schema migrations) are the technique used to keep track of changes in the schema of a database. There are many tools for handling database migrations for different languages and frameworks; They typically provide these features:

- Represent schema changes in code (so they can be added to source control)
- Keep track of the last migration applied
- Apply only the necessary migrations

Having all the schema changes in code also makes it easy to ensure all environments are running exactly the same DB schema.

<!--more-->

## Flyway

Flyway is a database migrations tool for Java that integrates with most relational databases out there.

Flyway needs two things to work:
- Credentials to a database
- A folder with migrations to apply

Once we have those things configured, we can run Flyway.

When we run Flyway, this is what happens:
- Looks for the schema history table and creates it if it doesn't exist. This table is used to track which migrations have already been applied to the DB
- Migrations are read and applied in order (We'll learn about ordering later in the article)
- For each applied migration a record is written to the schema history table
- Last applied migration is marked as current

Next time Flyway in run, only migrations with a version newer than `current` will be applied

### Migrations order

Migrations are most commonly written in plain SQL. A new `.sql` file is created every time we need to modify the DB. Files need to follow the following naming convention:

```bash
V1__some_name.sql
```

Forward migrations need to start with the letter `V`, followed by a number. This number must be higher than the highest numbered migration file already present. Then we need the `__` separator, some arbitrary name and the `.sql` extension.

We can also create undo migrations (prefixed with `U` instead of `V`) and repeatable migrations (prefixed with `R` instead of `V`).

### Using Flyway

Donwload and install the [flyway binary](https://flywaydb.org/download/community). Then we just need to use this command:

```bash
flyway -user=<db-user> \
    -password=<db-password> \
    -url=<db-url> \
    -locations=<path to migration files> \
    migrate
```

`<db-url>` must be a connection url for the database. `<path to migration files>` must follow this format: `filesystem:/path/to/migrations`, assuming the migrations are inside the `/path/to/migrations` folder. A real example looks like this:

```bash
flyway -user=root \
    -password=moresecret \
    -url=jdbc:mysql://localhost/mydb \
    -locations="filesystem:./migrations" \
    migrate
```

If we try to apply a migration, but the migration fails we'll get a message like this:

```
ERROR: Migration of schema `mydb` to version "1 - hello" failed! Please restore backups and roll back database and code!
ERROR: Migration V1__hello.sql failed
```

When this happens, we can manually revert the changes or use an undo migration to revert the migration. After we fix the DB to the latest know good state, we can use this command:

```bash
flyway -user=root \
    -password=moresecret \
    -url=jdbc:mysql://localhost/mydb \
    revert
```

To tell flyway that the DB is in a stable state.

After fixing the migration file that had problems, we can run the `migrate` command again.

## Conclusion

Flyway is a simple tool to do one task. There are some options that I didn't cover, but this post showed the simplest way to start using it to keep track of schema changes.
