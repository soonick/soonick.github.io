---
id: 3348
title: Suspending processes
date: 2015-12-09T08:06:07+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3348
permalink: /2015/12/suspending-processes/
tags:
  - bash
  - linux
  - productivity
---
Sometimes when I&#8217;m running a process in the foreground (most commonly, vim). I unintentionally press Ctrl + z and I get a message like this:

```
[1]+  Stopped                 vim
```

There might be reasons why you want to do this if you are running in a system that gives you a single terminal, but when running a UI where you can have multiple terminal tabs open, this usually happens by mistake. But no reason to panic, if you want to go back you just have to type this command:

```
fg
```

As a matter of fact, you can have different jobs running on the background:

```
jobs
[1]   Stopped                 vim
[2]-  Stopped                 vim
[3]+  Stopped                 less Makefile
```

And reopen them using fg %n. For example:

```
fg %2
```

<!--more-->
