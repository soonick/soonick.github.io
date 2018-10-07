---
id: 3675
title: MySQL for production
date: 2016-06-01T18:49:54+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3675
permalink: /2016/06/mysql-for-production/
categories:
  - Mysql
tags:
  - linux
  - MySQL
  - security
---
I&#8217;m starting a web project and I decided to save some money by hosting my MySQL database in a cheap instance in Digital Ocean. I was a little concerned about security so I did some research and found some ways to make my installation a little safer.

The first thing any installation must do is run:

```
sudo mysql_secure_installation
```

This step will allow you to set a root password if you haven&#8217;t already done so. This of course is something you must do if you want any kind of security. The script will also remove the default anonymous account, only allow root connections from localhost and remove the test database.

If you expect connections to your mysql database to come from a single host you can restrict this inside **/etc/my.cnf** by adding something like this:

```
bind-address = 127.0.0.1
```

This can be any valid IP address. If you want to allow connections from more than one IP addresses then you will have to do this at the network level.

MySQL allows you to load data from the local file system using a LOAD statement. If you are not using this statement, the best thing is to remove the access to local files altogether. You can do this by adding a line to your **/etc/my.cnf** file:

```
local-infile = 0
```

<!--more-->

## Verify the current installation

You can quickly check your installation security settings using this command:

```sql
SELECT user, host, password FROM mysql.user;
```

You will see something like this:

```
+------+-----------+-------------------------------------------+
| user | host      | password                                  |
+------+-----------+-------------------------------------------+
| root | localhost | *7F0C90A004C46C64A0EB9DDDCE5DE0DC437A635C |
| root | 127.0.0.1 | *7F0C90A004C46C64A0EB9DDDCE5DE0DC437A635C |
| root | ::1       | *7F0C90A004C46C64A0EB9DDDCE5DE0DC437A635C |
| jose | %         |                                           |
+------+-----------+-------------------------------------------+
```

In the previous output we can see that the user jose has not password set. This can be fixed with this command:

```sql
UPDATE mysql.user SET password=PASSWORD("secret-password") WHERE user="jose";
```

This sets the password secret-password to the user jose. Another thing that should be fixed is the Host. Jose can currently log-in from anywhere(%). We can fix this also with this command:

```sql
UPDATE mysql.user SET host="localhost" WHERE user="jose";
```

Now you need to flush the privileges for the changes to take effect:

```sql
FLUSH PRIVILEGES;
```

## Creating users

The root user should be used for administration, when you need applications to access your database you should create users with more restrictive permissions. You can create a user with this command:

```sql
CREATE USER "user-name"@"localhost" IDENTIFIED BY "secret";
```

A typical application will most likely need to SELECT and UPDATE records. You can grant these permissions:

```sql
GRANT SELECT, INSERT, UPDATE ON cooldb.* TO "user-name"@"localhost";
```

You should give as little permissions as you can. If you are not sure, it is better to fail on the side of security. If in the future you find you need more access you can always grant it. After changing any permissions, remember to flush the permissions:

```sql
FLUSH PRIVILEGES;
```

Another very important point to make a MySQL installation secure is securing the network. If possible you should communicate with your database over the same private network so nobody can sniff the traffic. If for some reason you can&#8217;t use a private network you should use an encrypted connection so traffic can&#8217;t be sniffed. I will write in another post a little about network security.
