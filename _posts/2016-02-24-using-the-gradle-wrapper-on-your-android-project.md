---
id: 3516
title: Using the Gradle wrapper on your Android project
date: 2016-02-24T17:02:20+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3516
permalink: /2016/02/using-the-gradle-wrapper-on-your-android-project/
tags:
  - android
  - automation
  - mobile
  - productivity
---
I have an android project I&#8217;ve been working on for a few weeks. I got a new computer recently and I wanted to work on this project. I downloaded the Android SDK and gradle. When I tried to run a build:

```
gradle assembleDebug
```

I got this error:

```
Gradle version 2.2 is required. Current version is 2.11. If using the gradle wrapper, try editing the distributionUrl in /home/you/repos/asdf/gradle/wrapper/gradle-wrapper.properties to gradle-2.2-all.zip
```

<!--more-->

I think I had probably seen this error before and I just downloaded the right version of gradle. This time however I decided to take a look at Gradle wapper to see what it was about.

Once you have a version of Gradle installed it is easy to create a wrapper file. Since my build.gradle file is now in a &#8220;broken&#8221; state because it requires a version of Gradle that I don&#8217;t have installed, I will move it aside for a second:

```
mv build.gradle build.gradle.back
```

Since I want to use version 2.2 for my project I just needed to do this:

```
gradle wrapper --gradle-version 2.2
```

Now we can restore build.gradle:

```
mv build.gradle.back build.gradle
```

You will see some files being generated. All these files should be checked into version control because it will allow developers to compile the project even when they don&#8217;t have Gradle installed (The wrapper will install the correct version for them). To build the project you can now use the wrapper:

```
./gradlew assembleDebug
```
