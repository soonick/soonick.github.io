---
id: 2289
title: Consuming Android library with gradle
date: 2014-08-21T21:39:53+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2289
permalink: /2014/08/consuming-android-library-with-gradle/
categories:
  - Mobile development
tags:
  - android
  - gradle
  - productivity
---
I have an Android project in gradle where I want to use a library packaged in an aar file. After some research I found the easiest way to consume it is by adding a flatDir repository to your build.gradle file.

```groovy
repositories {
  flatDir {
    dirs 'libs'
  }
}
```

You probably already have a repositories section in your build.gradle file so you will only need to add the flatDir section. Also, make sure that you are adding it as a top level. The first time I tried I was adding it to the repositories section inside of buildscript and it was not working.

After specifying the repository you need to add your aar file inside the libs directory and reference it from the dependencies section inside build.gradle (also make sure it is top level):

```groovy
dependencies {
  compile 'com.ncona.conversiongraph:conversion-graph:1.0@aar'
}
```

Now you can use your library within your app.
