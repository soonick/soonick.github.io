---
title: Introduction to PostgreSQL
author: adrian.ancona
layout: post
date: 2020-01-01
permalink: /2020/01/introduction-to-postgresql/
tags:
  - postgresql
  - linux
---

PostgreSQL is a relational database management system (RDBMS) similar to MySQL. I usually go for MySQL, but I'm going to be working on a project that uses PostgreSQL, so I need to get familiar with it.

## Installation

Installation on an Ubuntu system is easy:

```sh
sudo apt install postgresql
```

<!--more-->

## Roles

PostgreSQL uses roles as method of authentication. A role is basically a user, and each role has certain permissions.

With a new installation, a `postgres` role is created that is allowed to connect via [`peer authentication`](https://www.postgresql.org/docs/current/auth-peer.html).

### Peer Authentication

This method of authentication is only allowed for local connections. It consists on checking the currently logged-in Unix username against the available roles.

This means; to log-in using the `postgres` role, we need to first log-in as the `postgres` user:

```sh
sudo -i -u postgres
psql
```

## Prompt

The PostgreSQL prompt looks like this:

```sh
postgres=#
```

To exit you can use `\q` or `Ctrl + d`.

## Working with databases

To list all the databases `\list` or `\l` can be used:

```sh
postgres-# \list
                              List of databases
   Name    |  Owner   | Encoding | Collate |  Ctype  |   Access privileges
-----------+----------+----------+---------+---------+-----------------------
 postgres  | postgres | UTF8     | C.UTF-8 | C.UTF-8 |
 template0 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
 template1 | postgres | UTF8     | C.UTF-8 | C.UTF-8 | =c/postgres          +
           |          |          |         |         | postgres=CTc/postgres
(3 rows)
```

By default, you will be connected to the `postgres` database. `\conninfo` can be used to check which database you are currently connected to:

```sh
\conninfo
You are connected to database "postgres" as user "postgres" via socket in "/var/run/postgresql" at port "5432".
```

To create a new database:

```sh
CREATE DATABASE test;
```

You can switch databases with `\connect` or `\c`:

```sh
\c test
You are now connected to database "test" as user "postgres".
```

To delete a database:

```sh
DROP DATABASE test;
```

## Woking with tables

Once connected to a database, `\dt` can be used to list all the tables:

```sh
\dt
         List of relations
 Schema | Name  | Type  |  Owner   
--------+-------+-------+----------
 public | users | table | postgres
(1 row)
```

SQL can be used to create a new table. For example:

```sql
CREATE TABLE users(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);
```

`SERIAL` is the equivalent of MySQL's `AUTO_INCREMENT`.

To see the structure of a table `\d` can be used:

```sh
\d users
                                    Table "public.users"
 Column |          Type          | Collation | Nullable |              Default
--------+------------------------+-----------+----------+-----------------------------------
 id     | integer                |           | not null | nextval('users_id_seq'::regclass)
 name   | character varying(255) |           |          |
Indexes:
    "users_pkey" PRIMARY KEY, btree (id)
```

## Conclusion

In this article I covered enough to log-in to the PostgreSQL server and work with databases and tables. In another post I'll to try to cover user management, permissions and authentication.
