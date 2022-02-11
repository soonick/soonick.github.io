---
id: 1949
title: How to inspect your Android sqlite DB
date: 2014-03-06T02:52:30+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1949
permalink: /2014/03/how-to-inspect-your-android-sqlite-db/
tags:
  - android
  - debugging
  - linux
  - mobile
---
I am developing an Android app that makes use of an SQLite database. Every now and then I want to see what is the state of my app&#8217;s database to make sure things are being stored the way I expect. To do this you need to connect to your emulator using an adb shell.

Make sure your emulator is running and run this command to get a terminal to the emulator:

```
adb shell
```

You will be presented with a prompt similar to this one:

```
root@android:/ #
```

<!--more-->

Then go to the folder where the database for your app lives:

```
cd /data/data/<Your app, something like com.mydomain.myapp>/databases/
```

There you will find your database files. You can then use the SQLite client to inspect your database:

```
sqlite3 mydb.db
```

I am very familiar with MySQL, so the first thing I tried was to run SHOW TABLES. This command doesn&#8217;t exist in SQLite, so I had to find the equivalent:

```
.tables
```

Notice that there is no **semicolon** at the end of the line. For some reason the command doesn&#8217;t work if you add a semicolon. Then I tried DESCRIBE table, but it didn&#8217;t work again. The closest replacement I found was:

```
.schema mytable
```

which will return the create statement for the table.

Select statements are pretty similar to MySQL, so if you want to see all the contents of a table you can use:

```sql
SELECT * FROM mytable;
```
