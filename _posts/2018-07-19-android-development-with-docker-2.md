---
id: 5185
title: Android development with Docker
date: 2018-07-19T04:22:12+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=5185
permalink: /2018/07/android-development-with-docker-2/
categories:
  - Mobile development
tags:
  - android
  - automation
  - docker
  - mobile
  - productivity
  - projects
---
A couple of years ago I wrote a post explaining how to develop and Android application inside a Docker container. After some time away from Android development I tried to follow the instructions in my post but they didn&#8217;t work quite well.

A lot has changed in the way Android applications are developed since my last post. Installing SDK elements is easier and Kotlin is the language of choice now. Luckily, once we put everything inside Docker, we don&#8217;t have to worry much about the environment and just code.

Create a folder for your project and add a Dockerfile inside that folder:

<!--more-->

```docker
FROM ubuntu:18.04

RUN apt-get update

# Install some dependencies
RUN dpkg --add-architecture i386 && apt-get update \
    && apt-get install -y expect wget unzip \
    libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1

# Install java
RUN apt-get install -y openjdk-8-jdk-headless

# Install the Android SDK
RUN cd /opt && wget --output-document=android-sdk.zip --quiet \
    https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \
    && unzip android-sdk.zip -d /opt/android-sdk && rm -f android-sdk.zip

# Setup environment
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Install SDK elements. This might change depending on what your app needs
# I'm installing the most basic ones. You should modify this to install the ones
# you need. You can get a list of available elements by getting a shell to the
# container and using `sdkmanager --list`
RUN echo yes | sdkmanager "platform-tools" "platforms;android-28"

# Go to workspace
RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace
```

Build the Docker image:

```
docker build -t android-docker .
```

Get a shell to the container:

```
docker run -it --privileged --volume=$(pwd)/workspace:/opt/workspace android-docker bash
```

I use &#8211;privileged so the container has access to the host&#8217;s USB ports (This is necessary so it can install the Android app to the connected device). I&#8217;m assuming the application code will be in a folder called _workspace_ and mounting this folder in the container.

Build the Android app and install it to the connected device:

```
./gradlew installDebug
```

I created a very small [&#8220;_Hello world_&#8221; application on Github](https://github.com/soonick/android-docker-hello-world) that you can just download and modify as needed if you want to start an app from scratch.
