---
title: Dependency management in C++ with Conan
author: adrian.ancona
layout: post
date: 2019-04-03
permalink: /2019/04/dependency-management-in-cpp-with-conan/
tags:
  - c++
  - programming
  - dependency_management
  - automation
  - productivity
---

I consider [dependency management](/tag/dependency_management) a very important part of a maintainable software project. Once you start writing software that depends on other code, it can quickly become unpractical to do dependency management by hand, so a good system is necessary to make it easy to work on such projects.

Since C++ has been out for a while, I expected to find a very mature ecosystem in this regard. Looking around and reading a little, I found that there is no community agreed way of solving the problem of managing dependencies. One reason for this seems to be that it's not easy to build a system that helps you do dependency management when there are many ways to build a package.

<!--more-->

With the lack of a standard way to do dependency management, I decided to look for the most popular tool for the job. The project I found has the most support is [Conan](https://conan.io/), so I'm going to give it a try.

## Conan

Conan is an open source project backed by [JFrog](https://jfrog.com/). JFrog has been a major player in package/dependency management in the Java world for a long time, so they have a lot of experience in this environment.

As with most package managers, you can host your own private repository if you need to. For open source projects, [Bintray](https://bintray.com/), can be used free of charge.

## Installing Conan

In order to use Conan, we need to first intall the command line utility. Since Conan is written in python, the preferred way to install it, is using PIP. You can look at my [Introduction to PIP](/2015/08/introduction-to-pip/) article to get an idea of how it works, but this is the summary:

```bash
pip install conan
```

In Linux, you might need to use `sudo` for the installation to go through. If you have trouble, I recommend you take a look at the [official install documentation for Conan](https://docs.conan.io/en/latest/installation.html).

## Searching packages

A new Conan installation comes with a `remote` named `conan-center` added by default. A remote is a repository that can be used to find and install packages. To see all the remotes in your system you can use:

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

One thing to keep in mind is that search is case-sensitive.

## Using Conan on a project

To illustrate how Conan can be used in a project, let's start a small project with a simple dependency. This is going to be our folder structure:

```
project-directory/
|---conanfile.txt
|---CMakeLists.txt
|---build/
|---src/
    |---main.cpp
```

The project consists of a single file that will use a single dependency.

Conan uses a `conanfile.txt` file to declare the dependencies on the project. Let's add our dependency to this file:

```ini
[requires]
boost/1.69.0@conan/stable

[generators]
cmake
```

I'm going to be using Cmake for my project. If you are not familiar, you might want to check my [introduction to CMake](/2019/03/building-a-cpp-project-with-cmake/).

We can install the dependencies from the build folder:

```bash
cd build
conan install ..
```

This command will install all the dependencies, as well as all the transitive dependencies. A file called `conanbuildinfo.cmake` will be generated in the build folder, and all the dependencies will be downloaded to `~/.conan/data/`. The `cmake` file makes it easy to use the dependencies in a project that is already using CMake.

Let's now create the project `CMakeLists.txt` file:

```cmake
# Minimum version of CMake required to build this project
cmake_minimum_required(VERSION 3.0)

# Name of the project
project(Project)

# Include Conan dependencies
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)

# This will setup conan environment. Without this, including our dependencies
# would fail
conan_basic_setup()

# Compile main.cpp
add_executable(project src/main.cpp)

# Link the dependencies with our binary
target_link_libraries(project ${CONAN_LIBS})
```

The `main.cpp` file, doesn't do anything, but uses the dependency:

```cpp
#include <boost/uuid/uuid_generators.hpp>

int main() {
  const auto uuid = boost::uuids::random_generator();
}
```

Now we can build the whole project:

```bash
cd build
cmake ..
make
```

That's it, we have now created an easy to reproduce build for a C++ project using Conan.
