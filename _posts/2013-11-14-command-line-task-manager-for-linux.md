---
id: 1841
title: Command line task manager for Linux
date: 2013-11-14T05:38:48+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1841
permalink: /2013/11/command-line-task-manager-for-linux/
categories:
  - Linux
tags:
  - linux
  - productivity
---
I found this little gem because I wanted to see how my raspberry pi was handling one running process. You can use the **top** command to see the running processes:

```
top
```

You will probably have a bunch of zombie processes you don&#8217;t care about. To omit those use:

```
top -i
```
