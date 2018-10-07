---
id: 1927
title: Failed to load libGL.so
date: 2014-01-09T04:33:02+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1927
permalink: /2014/01/failed-to-load-libgl-so/
categories:
  - Mobile development
tags:
  - android
  - linux
  - mobile
---
I was having this problem while trying to run the Android emulator on my machine. To fix it you can use this command for Fedora:

```
sudo yum install mesa-libGL-devel
```

or this command for Ubuntu:

```
sudo apt-get install libgl1-mesa-dev
```
