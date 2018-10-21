---
id: 4157
title: Simple strategy for MySQL backups
date: 2017-02-23T00:51:39+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4157
permalink: /2017/02/simple-strategy-for-mysql-backups/
tags:
  - automation
  - linux
  - mysql
  - productivity
---
I now have a good amount of data in my blog that I would be very sad if I lost. As a precautionary measure I decided to build a little system that will backup my data regularly so I&#8217;m prepared in case of a disaster.

## The strategy

The strategy is going to be very simple. I&#8217;m going to create a user in my database that has read permissions on the tables I want to backup. This user will run mysqldump from a different machine and will save the backups there. I will create a cron job that will do this once a day.

<!--more-->

## Creating a read-only MySQL user

Log into MySQL with a user that has enough power to create new users. And create a backup user:

```sql
CREATE USER 'backup-user'@'%' IDENTIFIED BY 'somepassword';
GRANT SELECT ON dbname.* TO 'backup-user'@'%';
```

## Testing the user

With the user created, we can test our back-up powers:

```
mysqldump --single-transaction -u backup-user -h myhost -p'somepassword' dbname > $(date +%F_%S)-dbname.sql
```

You can see that the file we are dumping to has a weird name: $(date +%F_%S)-dbname.sql. This prepends the current date to the file name. This way you can create multiple backups in the same folder.

## Creating a CRON job

Lastly we need to add this to a cron job:

```
19 4 * * * mysqldump --single-transaction -u backup-user -h myhost -p'somepassword' dbname > /backups/$(date +%F_%S)-dbname.sql
```

And the backup will be generated every day at 4 am.
