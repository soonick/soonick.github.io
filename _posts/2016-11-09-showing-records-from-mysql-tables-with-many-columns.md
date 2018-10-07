---
id: 3970
title: Showing records from MySQL tables with many columns
date: 2016-11-09T10:48:20+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3970
permalink: /2016/11/showing-records-from-mysql-tables-with-many-columns/
categories:
  - Mysql
tags:
  - MySQL
  - productivity
---
Lately I&#8217;ve been working on a system that has a lot of big tables (with a lot of columns), and often I want to do something like:

```sql
SELECT * FROM users WHERE id = 1;
```

But there are so many columns that it doesn&#8217;t look good on a terminal:

```
+----+-------------------+---------------------+---------------------+---------------------+-----------------------+--------+-------------------------------------+----------------------------------------------------------------------------------------------------+
| id | username          | created_at          | updated_at          | issuer              | issuer_id             | points | email                               | picture_url                                                                                        |
+----+-------------------+---------------------+---------------------+---------------------+-----------------------+--------+-------------------------------------+----------------------------------------------------------------------------------------------------+
|  1 | carlos            | 2016-01-31 13:03:36 | 2016-11-04 18:15:56 | accounts.google.com | 111394444444498347111 |    100 | NULL                                | https://lh4.googleusercontent.com/-laaaaaajmcc/AAAAAAAAAAA/AAAAAAAAAAA/qwertyuioaa/s96-c/photo.jpg |
+----+-------------------+---------------------+---------------------+---------------------+-----------------------+--------+-------------------------------------+----------------------------------------------------------------------------------------------------+
```

<!--more-->

There is an easy way to tell MySQL to output data in a format that is more easy to read for these scenarios:

```sql
SELECT * FROM users WHERE id = 1\G;
```

The output looks like this:

```
*************************** 1. row ***************************
         id: 1
   username: carlos
 created_at: 2016-01-31 13:03:36
 updated_at: 2016-11-04 18:15:56
     issuer: accounts.google.com
  issuer_id: 111394444444498347111
     points: 100
      email: NULL
picture_url: https://lh4.googleusercontent.com/-laaaaaajmcc/AAAAAAAAAAA/AAAAAAAAAAA/qwertyuioaa/s96-c/photo.jpg
1 row in set (0.00 sec)
```

Since now each value is printed in its own line, the content can be read more easily.
