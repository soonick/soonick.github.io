---
title: Dependency management in C++ with Conan
author: adrian.ancona
layout: post
tags:
  - c++
  - programming
  - dependency_management
  - automation
  - productivity
---

I consider [dependency management](/tag/dependency_management) a very important part of a maintainable software project. Once you start writing software that depends on other code, it can quickly become unmanageable to do dependency management by hand, so a good system is necessary to make it easy to work on such project.

Since C++ has been out for a while, I expected to find a very mature ecosystem in this regard. Looking around and reading a litle, I found that there is no community agreed way of solving the problem of managing dependencies. One reason for this seems to be that it's not easy to build a system that helps you do dependency management when there are many way to build a package.

With the lack of a standard way to do dependency management, I decided to look for the most popular tool for the job. The project I found has most support is [Conan](https://conan.io/), so I'm going to give it a try.

## Conan

Conan is an open source project backed by [JFrog](https://jfrog.com/). JFrog has been a major player in package/dependency management in the Java world for a long time, so they has a lot of experience in this environment.

As with most package managers, you can host your own private repository if you need to. For open source projects, [Bintray](https://bintray.com/), can be used free of charge.

## Installing Conan

In order to use Conan, we need to first intall the command line utility. Since Conan is built in python, the preferred way to install it is using PIP. You can look at my [Introduction to PIP](/2015/08/introduction-to-pip/) article to get an idea of how it works.

```python
pip install conan
```

In Linux, you might need to use `sudo` for the installation to go through. If you have trouble, I recommend you take a look at the [official install documentation for Conan](https://docs.conan.io/en/latest/installation.html).

## Searching packages

A new Conan installation comes with a `remote` named `conan-center` added by default. A remote is a repository that can be used to find and packages. To see all the remotes in your system you can use:

```bash
$ conan remote list
conan-center: https://conan.bintray.com [Verify SSL: True]
```

You can search your `remotes` for a package:

```bash
$ conan search *boost* -r all
Existing package recipes:

Remote 'conan-center':
boost/1.64.0@conan/stable
boost/1.65.1@conan/stable
boost/1.66.0@conan/stable
boost/1.67.0@conan/stable
boost/1.68.0@conan/stable
boost/1.69.0@conan/stable
```

One thing to keep in mind is that searches are case sensitive.

## Using Conan on a project

To illustrate how Conan can be used in a project, let's start a small project with a simple dependency. This is going to be our folder structure:

```
ajsdfpioasjdfpoiasjdfpoasifjd
```

Conan uses a `conanfile.txt` file to declare the dependencies on the project. Let's add our dependency to this file:

```conan
[requires]
boost/1.69.0@conan/stable

[generators]
cmake
```

I'm using Cmake. See my article if you are not familiar.

We can get the dependencies using:

```bash
mkdir build
cd build
conan install ..
```

This command will install all the dependencies, as well as all the transitive dependencies. A file called `conanbuildinfo.cmake` will be generated in the build folder, and all the dependencies will be downloaded to `~/.conan/data/`. The `cmake` file makes it easy to use the dependencies in a project that is already using CMake.

We can now add these dependencies to our build by making some changes to the project's `CMakeLists.txt` file:

```cmake
 cmake_minimum_required(VERSION 2.8.12)
 project(MD5Encrypter)

 add_definitions("-std=c++11")

 include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
 conan_basic_setup()

 add_executable(md5 md5.cpp)
 target_link_libraries(md5 ${CONAN_LIBS})
```

That's it, we have now created an easy to reproduce build for a C++ project using Conan.
