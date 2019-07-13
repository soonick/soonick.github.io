---
title: Creating a C++ package with Conan
author: adrian.ancona
layout: post
date: 2019-07-17
permalink: /2019/07/creating-a-cpp-package-with-conan/
tags:
  - c++
  - programming
  - dependency_management
---


In the past I wrote an article that explains how to [consume packages using Conan](/2019/04/dependency-management-in-cpp-with-conan/). In this article I'm going to explain how we can create our own packages with Conan.

I'm going to create a simple cpp library an make a conan package out of it.

## Sample package

The first step is to create a folder for the library:

```sh
mkdir MyLib
cd MyLib
```

<!--more-->

Then we can create a Conan recipe:

```
conan new MyLib/0.1
```

As you might have already figured out. We are creating a package named `MyLib`, and we are setting the version to `0.1`. This command generates a file named `conanfile.py`.

The generated file looks like this:

```py
from conans import ConanFile, CMake, tools


class MylibConan(ConanFile):
    name = "MyLib"
    version = "0.1"
    license = "<Put the package license here>"
    author = "<Put your name here> <And your email here>"
    url = "<Package recipe repository url here, for issues about the package>"
    description = "<Description of Mylib here>"
    topics = ("<Put some tag here>", "<here>", "<and here>")
    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False]}
    default_options = "shared=False"
    generators = "cmake"

    def source(self):
        self.run("git clone https://github.com/memsharded/hello.git")
        self.run("cd hello && git checkout static_shared")
        # This small hack might be useful to guarantee proper /MT /MD linkage
        # in MSVC if the packaged project doesn't have variables to set it
        # properly
        tools.replace_in_file("hello/CMakeLists.txt", "PROJECT(MyHello)",
                              '''PROJECT(MyHello)
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()''')

    def build(self):
        cmake = CMake(self)
        cmake.configure(source_folder="hello")
        cmake.build()

        # Explicit way:
        # self.run('cmake %s/hello %s'
        #          % (self.source_folder, cmake.command_line))
        # self.run("cmake --build . %s" % cmake.build_config)

    def package(self):
        self.copy("*.h", dst="include", src="hello")
        self.copy("*hello.lib", dst="lib", keep_path=False)
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.dylib", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)

    def package_info(self):
        self.cpp_info.libs = ["hello"]
```

Most of the properties of the MylibConan class are self-explanatory. I'm going to explain the ones that are not that obvious.

- `settings` - The default value means that if the os, compiler, build type or cpu architecture change. A different binary will be generated.
- `options` - Allows specifing arbitrary options that can be used while building the package. In this case it could be used to define if a library will be built as a shared library.

There is a `source` method defined. This method can be used to retrieve source code from github or other sources. We will be using code in the current folder, so we won't need to download anything.

The `build` method does what you would expect. It builds the project using cmake.

The `package` method can be used to move all artifacts (libraries, headers) to a single folder.

Lastly, the `package_info` method defines the name that will be used by the consumers of this package.

## Library code

Before we modify `conanfile.py` to fit our needs, let's create a very simple library that does nothing:

```sh
# Inside MyLib folder
mkdir src
cd src
touch MyLib.h
touch MyLib.cpp
```

MyLib.h:

```cpp
class MyLib {
 public:
  void doNothing();
};
```

MyLib.cpp

```cpp
#include "MyLib.h"

void MyLib::doNothing() {
  // Nothing
}
```

Make it a Cmake project:

```sh
touch CMakeLists.txt
```

CMakeLists.txt

```
# Minimum version of CMake required to build this project
cmake_minimum_required(VERSION 3.0)

# Name of the project
project(MyLib)

add_library(MyLib MyLib.cpp)
```

Run a Cmake build:

```sh
mkdir build
cd build
cmake ../src/
make
```

Now that we have our build ready, we can tune `conanfile.py`.

## Conanfile.py

Here is a new version with comments:

```py
from conans import ConanFile, CMake, tools


class MylibConan(ConanFile):
    # Removed a bunch of attributes that are not needed, but you might want to
    # Add them for a real project
    name = "MyLib"
    version = "0.1"
    generators = "cmake"
    # If the source code is going to be in the same repo as the Conan recipe,
    # there is no need to define a `source` method. The source folder can be
    # defined like this
    exports_sources = "src/*"

    def build(self):
        cmake = CMake(self)
        # The CMakeLists.txt file must be in `source_folder`
        cmake.configure(source_folder="src")
        cmake.build()

    def package(self):
        # Copy headers to the include folder and libraries to the lib folder
        self.copy("*.h", dst="include", src="src")
        self.copy("*.a", dst="lib", keep_path=False)

    def package_info(self):
        self.cpp_info.libs = ["MyLib"]
```

To build the package:

```
conan create . src/MyLib
```

If everything goes well you will see a line like this in the output:

```
...
MyLib/0.1@src/MyLib: Package folder /home/me/.conan/data/MyLib/0.1/src/MyLib/package/5ab84d6acfe1f23c4fae0ab88f26e3a396351ac9
...
```

You can see go to that folder to see the contents of the package.

In a future article, I will explain how we can publish this so it can be used by anyone.
