---
title: Simple Back-ups with PostgreSQL
author: adrian.ancona
layout: post
date: 2020-02-12
permalink: /2020/02/simple-back-ups-with-postgresql/
tags:
  - postgresql
  - linux
---

I have a PostgreSQL database that I want to back-up periodically in case my server crashes suddenly. In this post I'm going to explore a simple but efficient way to create a back-up and how to apply it.

## SQL Dump

When we take an SQL dump from a database, we will get a file with the SQL commands necessary to recreate the database to the current state.

To take an SQL dump for a PostgreSQL database, we can use `pg_dump`:

<!--more-->

```sh
pg_dump somedb > filename.sql
```

`pg_dump` is a client application much like `psql`. It can be run from remote hosts similarly to other client applications:

```sh
pg_dump -h my.database.com -U someuser somedb > filename.sql
```

The user creating the dump must have read permissions on all tables for the database being backed-up.

## Restoring the dump

Applying the dump file is as easy as creating it:

```sh
psql somedb < filename.sql
```

The user running this command must have permissions to create tables, modify them and insert records on those tables.

By default, if a command fails, the dump will continue running. This might leave the database in a weird state. I prefer running the whole dump as a transaction and stopping if there is any error. This command does that:

```sh
psql --single-transaction --set ON_ERROR_STOP=on somedb < filename.sql
```

If an error occurs, all the changes will be reverted and the database will be left in the same state as before the command was run.
