---
id: 1331
title: Create MySQL users
date: 2013-05-02T04:51:45+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1331
permalink: /2013/05/create-mysql-users/
tags:
  - mysql
---
I always forget the syntax to create a new mysql user, so I decided to write it in here for later reference. I am doing this from a mysql terminal, so first we need to login:

```
mysql -uroot -p
mysql>
```

And then we can:

```sql
CREATE USER 'username'@'domain' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON database.table TO 'username'@'domain'
```

When issuing the GRANT command you can use wildcards like this:

```sql
GRANT ALL PRIVILEGES ON *.* TO 'username'@'%'
```

And that is pretty much all there is to it.

<!--more-->
