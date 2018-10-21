---
id: 1998
title: Configure syntastic to work fine with Android projects
date: 2014-03-13T03:39:57+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1998
permalink: /2014/03/configure-syntastic-to-work-fine-with-android-projects/
tags:
  - android
  - java
  - mobile
  - productivity
  - vim
---
Synstastic is a syntax checker for many programming languages, including Java. The problem that I was having is that for my Android project it wasn&#8217;t helping me at all because it couldn&#8217;t find any of the Android libraries and almost every line showed as an error.

The reason for this is that syntastic uses javac in the background to look at the file and find out if there are any errors. It does a good job for classes in the java standard library, but it doesn&#8217;t know where to find the Android SDK so it throws errors for every line that makes use of it. To fix this we need to add the java SDK to our path.

There are two ways of doing this. The first one will only last for the length of the vim session and will go away when you quit. Use this vim command:

```
:SyntasticJavacEditClasspath
```

<!--more-->

A split window will open where you can enter one path on each line. This is what I put in mine:

```
/<path to my app>/bin/classes
/<path to android-sdk>/platforms/android-19/*.jar
```

Then save and the split window will go away. The next time you run syntastic it will use the new class paths that you just added.

The second way to add class paths is by adding this to your .vimrc file:

```
let g:syntastic_java_javac_classpath = "/<path to my app>/bin/classes:/<path to android-sdk>/platforms/android-19/*.jar"
```

Both of these features are really new so make sure you get the latest version of syntastic if it doesn&#8217;t work for you.

## Note:

> I was having a problem adding a specific path to my class path. For some reason it was being ignored. I looked at the code and found it is because Java syntax checker for Syntastic uses vim&#8217;s glob() function to expand paths you want to add to your class path. The problem is that glob() respects(ignores) patterns added using **set wildignore**. If you have this problem make sure you don&#8217;t have the path you want to add in your wildignore list.
