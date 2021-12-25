---
id: 3678
title: Avoid SSH connection timeout
date: 2016-05-25T17:26:06+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3678
permalink: /2016/05/avoid-ssh-connection-timeout/
tags:
  - linux
---
I have gotten tired of my SSH connections timing out when connecting to my servers, so I found out how to fix it. Edit this file **/etc/ssh/ssh_config** in the computer you are using as a client. Then add these lines at the end:

```
ServerAliveInterval 15
ServerAliveCountMax 3
```

**ServerAliveInterval** &#8211; The number of seconds the client(your computer) will wait before it sends a null package to the server. Sending a null package to the server will keep the connection alive.

**ServerAliveCountMax** &#8211; How many times the client will try to send a message to the server if it doesn&#8217;t respond.

With the configuration above, the client will send a null package every 15 seconds. If the server doesn&#8217;t respond to one of those packages then after 15 seconds the clients will try again and then one more time. After three failures the client will disconnect.

<!--more-->
