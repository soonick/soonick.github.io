---
id: 3785
title: Android development with Docker
date: 2016-07-20T16:58:48+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3785
permalink: /2016/07/android-development-with-docker/
categories:
  - Mobile development
tags:
  - android
  - automation
  - docker
  - mobile
---
> This post was written in 2016. I wrote an updated version on 2018. [Android development with Docker 2018](http://ncona.com/2018/07/android-development-with-docker-2/) 

I&#8217;ve been using Docker for developing servers and other web applications for a few months and I find it very comfortable. When I want to work on one of my projects I just need to clone the git repository and run a Docker command and everything is ready to start developing. The environment and all dependencies are installed inside the Docker container automatically and the developer doesn&#8217;t need to worry about a thing.

Today I decided to try to expand this concept to one of my Android projects. With Android development there are a few challenges to overcome. We need to get the correct development tools to build the project as well as a way to easily install the build into a device for testing. A few people have already done a lot of work on this subject so I&#8217;m going to use as much of their work as I can.

<!--more-->

I created a Dockerfile based on [jacekmarchwicki&#8217;s android image](https://hub.docker.com/r/jacekmarchwicki/android/). I removed some stuff that I didn&#8217;t need and changed the versions of some of the Android tools:

```docker
FROM ubuntu:14.04

RUN apt-get update

# Install java7
RUN apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:webupd8team/java \
    && apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 \
    select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer

# Install Deps
RUN dpkg --add-architecture i386 && apt-get update \
    && apt-get install -y --force-yes expect wget \
    libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1

# Install Android SDK
RUN cd /opt && wget --output-document=android-sdk.tgz --quiet \
    http://dl.google.com/android/android-sdk_r24.3.3-linux.tgz \
    && tar xzf android-sdk.tgz && rm -f android-sdk.tgz \
    && chown -R root.root android-sdk-linux

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install sdk elements
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools
RUN ["/opt/tools/android-accept-licenses.sh", \
    "android update sdk --all --force --no-ui --filter platform-tools,tools,build-tools-23,build-tools-23.0.2,android-23,addon-google_apis_x86-google-23,extra-android-support,extra-android-m2repository,extra-google-m2repository,extra-google-google_play_services,sys-img-armeabi-v7a-android-23"]

# Cleaning
RUN apt-get clean

# Go to workspace
RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace
```

You might also want to create a .dockerignore file so you don&#8217;t have problems with files generated when running a build in the container. My file looks like this:

```
build/
.gradle/
```

Before you can use this Dockerfile you will need to download android-accept-licenses.sh, save it under the tools folder and add execute permissions.

```
mkdir tools
cd tools
wget https://raw.githubusercontent.com/oren/docker-ionic/master/tools/android-accept-licenses.sh
chmod +x android-accept-licenses.sh
```

Now you can build the image:

```bash
docker build -t android-docker .
```

This step will take some time since it will download the operating system, all the dependencies and all the Android tools.

When the command is done you can start working on your project. I recommend you open a terminal using:

```bash
docker run -it --privileged --volume=$(pwd):/opt/workspace android-docker bash
```

The privileged flag is necessary so the docker container can access Android devices connected via USB. Building and installing your app in a device connected via USB requires only this command:

```
./gradlew installDebug
```

By adding the Dockerfile to your project and sharing these commands your team will have a reproducible and easy to set up Android development environment.

There are a few things that can be improved, for example, having an emulator and being able to test without a hardware device. For now, this workflow is good enough for me. I will explore in the future how to create and run an emulator inside the docker container.
