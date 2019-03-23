---
title: Building a C++ project with CMake
author: adrian.ancona
layout: post
date: 2019-03-20
permalink: /2019/03/building-a-cpp-project-with-cmake/
tags:
  - c++
  - programming
  - automation
  - productivity
---

Now that I know enough C++ to be able to build something useful, I started looking at tools that will make it possible to create maintainable projects. I'm exploring CMake because it is probably the most popular build tool for C++ projects. It allows you to create platform independent configuration files that can then be translated to the platform of your choice.

## Installation

In Ubuntu, you can install CMake using apt-get:

```
sudo apt-get install cmake
```

For other systems, you can download the binary from [CMake's downloads page](https://cmake.org/download/).

<!--more-->

## Example project

Before we start playing with CMake, we will need a project to build. The project won't actually do anything, but it will contain a few files and directories to simulate a larger project. This is going to be the directory structure:

```
project-directory/
|---src/
|   |---main.cpp
|   |---helpers/
|   |   |---AwesomeHelper.cpp
|   |   |---AwesomeHelper.h
|   |   |---OkHelper.cpp
|   |   |---OkHelper.h
|   |
|   |---models/
|   |   |---Person.cpp
|   |   |---Person.h
|
|---libraries/
    |---MyLibrary/
        |---src/
            |---MyLibrary.cpp
            |---MyLibrary.h
```

The result of building this project will be an executable program. Our dependency tree will be like this:

```
                   --------
                   | main |
                   --------
                _/    |     \_
              _/      |       \_
            _/        |         \_
           /          |           \
  ----------   -----------------   -------------
  | Person |   | AwesomeHelper |   | MyLibrary |
  ----------   -----------------   -------------
      |
      |
  ------------
  | OkHelper |
  ------------
```

# Configuring a CMake project

A CMake project starts with a `CMakeLists.txt` file. Projects can be nested, so multiple `CMAkeLists.txt` files can exist within a project. For this example, we will have a project-wide `CMakeLists.txt` file, and another one for `MyLibrary`.

Let's start by creating a `CMakeLists.txt` file in the `project-directory/libraries/MyLibrary` folder. This file will instruct CMake how we want the library to be built:

```cmake
# Minimum version of CMake required to build this project
cmake_minimum_required(VERSION 3.0)

# Name of the project
project(MyLibrary)

# Add a library to this build. The name of the library is MyLibrary and it
# consists of only the MyLibrary.cpp file
add_library(MyLibrary src/MyLibrary.cpp)
```

# Building the project

We will build the library in a folder named `build`, so generated files are separated from our source code:

```bash
cd project-directory/libraries/MyLibrary
mkdir build
cd build
cmake ..
make
```

A few files will be generated in the build folder. Among them, a file named `libMyLibrary.a`. That is the library we just generated.

```bash
$ ls
CMakeCache.txt  CMakeFiles  cmake_install.cmake  libMyLibrary.a  Makefile
```

# Putting it all together

Now that the library is ready, we can continue with the executable. We will create a `CMakeLists.txt` file in `project-directory`:

```cmake
# Minimum version of CMake required to build this project
cmake_minimum_required(VERSION 3.0)

# Name of the project
project(Project)

# Add all the source files needed to build the executable
add_executable(Project src/main.cpp src/helpers/AwesomeHelper.cpp src/helpers/OkHelper.cpp src/models/Person.cpp)

# Include the directory where MyLibrary project is. Otherwise, we can't use the
# library
add_subdirectory(libraries/MyLibrary)

# Link the executable and the library together
target_link_libraries(Project MyLibrary)
```

Now we can build the whole project with just a few easy to remember commands:

```bash
cd build
cmake ..
make
```

# Adding variables to CMakeLists.txt

I feel having to constantly type paths can be a problem if I ever want to change my folder structure, so I will add some variables for the folder names:

```cmake
# Minimum version of CMake required to build this project
cmake_minimum_required(VERSION 3.0)

# Name of the project
project(Project)

# Create a few variables for the folder names, so they are easier to rename in
# the future
set(HELPERS_DIR src/helpers)
set(MODELS_DIR src/models)

# Add all the source files needed to build the executable
add_executable(
  Project
  src/main.cpp
  ${HELPERS_DIR}/AwesomeHelper.cpp
  ${HELPERS_DIR}/OkHelper.cpp
  ${MODELS_DIR}/Person.cpp
)

# Include the directory where MyLibrary project is. Otherwise, we can't use the
# library
add_subdirectory(libraries/MyLibrary)

# Link the executable and the library together
target_link_libraries(Project MyLibrary)
```

# Conclusion

C++ build system is not very easy to use, so having a tool like this can really help make sense of a project. Another advantage of using CMake is that by using it, the project can now be compiled in multiple platforms with no extra work.
