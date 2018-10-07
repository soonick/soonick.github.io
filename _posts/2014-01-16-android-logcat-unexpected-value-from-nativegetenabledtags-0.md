---
id: 1907
title: 'Android Logcat Unexpected value from nativeGetEnabledTags: 0'
date: 2014-01-16T04:47:13+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1907
permalink: /2014/01/android-logcat-unexpected-value-from-nativegetenabledtags-0/
categories:
  - Mobile development
tags:
  - android
  - debugging
  - java
  - productivity
---
Every time I try to use logcat to debug my android App I get this message a lot:

```
W/Trace &nbsp; ( 1264): Unexpected value from nativeGetEnabledTags: 0
```

This apparently is some kind of bug. This makes it really hard to read the logs I really care about so I am now using this command to filter all those entries:

```
adb logcat | grep -v .*nativeGetEnabledTags.*
```
