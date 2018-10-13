---
id: 225
title: 'apache2: Could not reliably determine your servers&#8217;s fully qualified domain name, using 127.0.0.1 for ServerName'
date: 2011-06-11T18:05:05+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=225
permalink: /2011/06/apache2-could-not-reliably-determine-your-serverss-fully-qualified-domain-name-using-127-0-0-1-for-servername/
categories:
  - Linux
tags:
  - apache
  - linux
---
This is a common problem I find when I do a new Apache 2 install on Ubuntu. There is a simple solution to stop seeing this message. Edit httpd.conf, type this command in a terminal:

```
sudo gedit /etc/apache2/httpd.conf
```

Add this line at the end of the file

```
ServerName myserver
```

You can replace **myserver** with whatever name you want to use for your server.

If that doesn&#8217;t completely fix the problem try adding the same line:

```
ServerName myserver
```

At the end of /etc/apache2/apache2.conf

That should do it.

<!--more-->
