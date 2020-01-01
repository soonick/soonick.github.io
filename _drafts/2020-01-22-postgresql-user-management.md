---
title: PostgreSQL user management
author: adrian.ancona
layout: post
date: 2020-01-22
permalink: /2020/01/postgresql-user-management/
tags:
  - postgresql
  - linux
---

In my previous post I gave a brief [introduction to PostgreSQL](/2020/01/introduction-to-postgresql/). In this post I'm going to dig deeper into user management and permissions.

## Roles

PostgreSQL uses roles for authentication. There are two different kind of roles: groups and users. Users and groups can belong to groups; The only difference is that users can be used to log-in to a database. If a user is created with the `INHERIT` property set, it will inherit permissions from the groups it belongs to.

To see all roles that currently exist on an installation of PostgreSQL, `\du` can be used:

```sh
\du
                                   List of roles
 Role name |                         Attributes                         | Member of
-----------+------------------------------------------------------------+-----------
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
```

<!--more-->

Alternatively, the `pg_roles` table can be inspected:

```sql
SELECT
   *
FROM
   pg_roles;
```

## Managing users and groups

To create a group:

```sql
CREATE ROLE some_group;
```

To create a user and make it a member of that group:

```sql
CREATE ROLE some_user INHERIT;
GRANT some_group TO some_user;
```

The group membership can be seen using `\du`:

```sh
\du
                                     List of roles
 Role name  |                         Attributes                         |  Member of
------------+------------------------------------------------------------+--------------
 postgres   | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 some_group | Cannot login                                               | {}
 some_user  | Cannot login                                               | {some_group}
```

To remove a user from a group:

```sql
REVOKE some_group FROM some_user;
```

To delete a role:

```sql
DROP ROLE some_user;
```

## Giving permissions to users

A user can only connect to a database if it has the `CONNECT` permission for it. The permission can be granted:

```sql
GRANT CONNECT ON DATABASE test TO some_user;
```

Listing the databases shows which users can connect to each database;

```sh
\l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 test      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =Tc/postgres         +
           |          |          |             |             | postgres=CTc/postgres+
           |          |          |             |             | some_user=c/postgres
```

The permissions can be interpreted like this (Taken from [PostgreSQL documentation](https://www.postgresql.org/docs/current/ddl-priv.html#PRIVILEGE-ABBREVS-TABLE)):

```sh
=Tc/postgres
```

Since there is no role before `=`, it means these are permision for everybody. The role following the slash (`/`) is the user that granted that permission. The letters between the `=` and the `/` are the actual permissions. Here is what they mean:

| Privilege  | Abbreviation | Applicable Object Types |
|------------|--------------|-------------------------|
| SELECT     | r (“read”)   | LARGE OBJECT, SEQUENCE, TABLE (and table-like objects), table column |
| INSERT     | a (“append”) | TABLE, table column |
| UPDATE     | w (“write”)  | LARGE OBJECT, SEQUENCE, TABLE, table column |
| DELETE     | d            | TABLE |
| TRUNCATE   | D            | TABLE |
| REFERENCES | x            | TABLE, table column |
| TRIGGER    | t            | TABLE |
| CREATE     | C            | DATABASE, SCHEMA, TABLESPACE |
| CONNECT    | c            | DATABASE |
| TEMPORARY  | T            | DATABASE |
| EXECUTE    | X            | FUNCTION, PROCEDURE |
| USAGE      | U            | DOMAIN, FOREIGN DATA WRAPPER, FOREIGN SERVER, LANGUAGE, SCHEMA, SEQUENCE, TYPE |
{: .s-table }

Different permissions can be granted to allow different operations. Let's say we want `some_user` to be able to read from a table:

```sql
GRANT SELECT ON users TO some_user;
```

In this case, `users` refers to the table with that name in the current database.

To list all the permissions on all tables in the current database, `\dp` can be used:

```sh
\dp
                                      Access privileges
 Schema |     Name     |   Type   |     Access privileges     | Column privileges | Policies
--------+--------------+----------+---------------------------+-------------------+----------
 public | users        | table    | postgres=arwdDxt/postgres+|                   |
        |              |          | some_user=r/postgres      |                   |
 public | users_id_seq | sequence |                           |                   |
(2 rows)
```

Alternatively `information_schema.role_table_grants` can be inspected:

```sql
SELECT
  grantee, privilege_type
FROM
  information_schema.role_table_grants
WHERE
  table_name = 'users';
```

## Authorizing users

We now have a user with permissions to read from a table, but we can't yet log-in using this user. When listing the roles, there was a message saying "Cannot login":

```sh
\du
                                     List of roles
 Role name  |                         Attributes                         |  Member of
------------+------------------------------------------------------------+--------------
 postgres   | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 some_group | Cannot login                                               | {}
 some_user  | Cannot login                                               | {some_group}
```

We need to modify the role to allow it to log-in:

```sql
ALTER ROLE some_user WITH LOGIN;
```

This allows us to log-in using peer authentication:

```sh
sudo adduser some_user
sudo -i -u some_user
psql -d test
```

Peer authentication is not very useful for a production database, since we need to allow different systems to connect to the database from other hosts.

To enable different authentication methods for users, we need to use [`pg_hba.conf`](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html) (HBA stands for host-based authentication). This configuration file lists all the users that are allowed to connect to the database and which authentication methods they are allowed to use.

The location of the file can be found with an SQL query:

```sql
SELECT
  name, setting
FROM
  pg_settings
WHERE
  name = 'hba_file';
```

Output for me looks like this:

```sh
   name   |               setting
----------+-------------------------------------
 hba_file | /etc/postgresql/11/main/pg_hba.conf
(1 row)
```

The file's content looks something like this:

```ini
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                peer
local   all             all                                     peer
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
```

Let's look at what the different fields mean.

- `TYPE` - This refers to the type of connection. The possible values are:
  - `local` - Unix socket connections.
  - `host` - TCP/IP connections.
  - `hostssl` - Same as `host`, but only using SSL.
  - `hostnossl` - Same as `host`, but only not using SSL.
- `DATABASE` - Name of the database we want to allow connections to. The special value `all` means connection to all databases is allowed.
- `USER` - Name of the user we want to allow to connect. The value `all` means, all users.
- `ADDRESS` - For connection types that allow remote connections, this specifies which hosts are allowed to connect. This is typically expressed using CIDR.
- `METHOD` - Authentication method to use.

I'm not going to cover all authentication methods in this article. I'm just going to cover one that provides a balance of security and ease of implementation; the `scram-sha-256` method over SSL. This method allows a user to connect using a password, but also forces SSL so the credentials can't be sniffed.

PostgreSQL uses md5 encryption by default at the time of this writing. This might change in the future, so let's inspect the `password_encryption` setting to be sure:

```sql
SHOW password_encryption;
 password_encryption
---------------------
 md5
(1 row)
```

Since the value is not `scram-sha-256`, we will need to change it. It can be changed with this command:

```sql
ALTER SYSTEM SET password_encryption = 'scram-sha-256';
```

Or by manually editing `postgresql.conf`. To find the file:

```sql
SELECT
  name, setting
FROM
  pg_settings
WHERE
  name = 'config_file';
```

And then make sure it contains this line:

```ini
password_encryption = 'scram-sha-256'
```

Whichever method you choose, you will need to reload the settings after the change:

```sql
SELECT pg_reload_conf();
```

If the change is successful, the `password_encryption` setting will look like this:

```sql
SHOW password_encryption;
 password_encryption
---------------------
 scram-sha-256
(1 row)
```

Once this is done, we can set a password for the user. The best way to add a password is using `\password`:

```sh
\password some_user
```

A prompt will ask for the new password.

Another way to add a password is by using `ALTER USER`, but it has the disadvantage of the password being logged in plain text in the commands history:

```sql
ALTER USER some_user WITH ENCRYPTED PASSWORD 'some_password';
```

We can inspect `pg_shadow` to confirm `scram-sha-256` was used:

```sql
SELECT
  usename, passwd
FROM
  pg_shadow
WHERE
  usename = 'some_user';

  usename  |                                                                passwd
-----------+---------------------------------------------------------------------------------------------------------------------------------------
 some_user | SCRAM-SHA-256$4096:bgml0WDKDideiJI0CUVLKw==$ku89rUtLQ1SEyXtnDxbvaWxxrvfL2SHsEAnq7DzzCOo=:0kC+l+8wKv1j5cMiE3LG0TnIW7pEmqFE8D11CKhI+FI=
(1 row)
```

If the passwd field has `SCRAM-SHA-256` at the beginning, it means everything went well.

The next step is to make sure PostgreSQL is accepting connections from other hosts. My article about [handling connection refused error](/2020/01/postgresql-connection-refused/) explains how to do this.

Besides allowing connections from other hosts, we also need to allow the user we created to log-in from other hosts. To do this, we need to modify our `hba_file` to allow `some_user` to connect from any host:

```ini
hostssl   some_database   some_user   all   scram-sha-256
```

If we want to allow connections only from hosts that are part of a subnet:

```ini
hostssl   some_database   some_user   10.120.33.0/24   scram-sha-256
```

If we want to allow connections only from a specific host:

```ini
hostssl   some_database   some_user   10.120.33.1/32   scram-sha-256
```

Since we used `hostssl` as the connection type, PostgreSQL won't allow the connection unless it uses SSL.

When a client connects to the database, it can choose which [`sslmode`](https://www.postgresql.org/docs/current/libpq-ssl.html) to use. The most secure level is `verify-full`, which requires a Certificate Authority that validates the certificate of the server. The level that I use internally is `require`, which guarantees that communication will be encrypted, but doesn't protect from man-in-the-middle attacks.

## Conclusion

In this article I explained how to create users, assign them permissions and allow them to connect to a database. These are the steps I followed to create a small service that required to talk to a PostgreSQL database on another host. Hopefully this helps you get started too.
