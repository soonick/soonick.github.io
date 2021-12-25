---
id: 647
title: 'sudo: unable to resolve host'
date: 2012-05-31T00:10:42+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=647
permalink: /2012/05/sudo-unable-to-resolve-host/
tags:
  - apache
  - linux
---
Today out of the blue (or at least that is what I thought when I first saw it) I started seeing this message everytime I issued a command using sudo:

```
$ sudo ls
sudo: unable to resolve host adrian
```

After a little investigations I found out that it actually didn&#8217;t come out of nowhere, but I was the one who made this happened. What happens is that you usually have an entry in the file **/etc/hostname** where you specify the name of your host. So when you use the sudo command it tries to connect to the host computer to check for permissions. This can get really complicated, but if you are only working on your computer your host is usually the local host.

<!--more-->

So to fix this problem you need to check the name you have in **/etc/hostname** and make sure that you have it mapped to 127.0.0.1 in your **/etc/hosts** file. For example:

hostname:

```
adrian
```

hosts:

```
127.0.0.1 adrian
```
