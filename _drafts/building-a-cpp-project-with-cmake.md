---
title: Building a C++ project with CMake
author: adrian.ancona
layout: post
tags:
  - c++
  - programming
  - automation
  - productivity
---

Now that I know enough C++ to be able to build something useful, I started looking at tools that will make it possible to create maintainable projects. I'm exploring CMake because it is probably the most popular build tool for C++ projects. It allows you to create platform independent configuration files that can then be translated to the platform of your choice.

## Installation

In ubuntu you can install CMake using apt-get:

```
sudo apt-get install cmake
```

For other systems, you can download the binary from [CMake's downloads page](https://cmake.org/download/).

## Example project

Before we start playing with CMake, we will need a project to build. The project won't actually do anything, but it will contain a few files an directories to simulate a larger project. This is going to be the directory structure:

```
project-directory/
|---main.cpp
|---helpers/
|   |---AwesomeHelper.cpp
|   |---AwesomeHelper.h
|   |---OkHelper.cpp
|   |---OkHelper.h
|
|---models/
|   |---Person.cpp
|   |---Person.h
```

The result of building this project will be an executable program. Our dependency hierarchy will be like this:

```
          --------
          | main |
          --------
          /      \
         /        \
  ----------     -----------------
  | Person |     | AwesomeHelper |
  ----------     -----------------
      |
      |
  ------------
  | OkHelper |
  ------------
```
