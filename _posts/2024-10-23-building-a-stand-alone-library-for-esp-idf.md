---
title: Building a Stand-Alone Library for ESP-IDF
author: adrian.ancona
layout: post
date: 2024-10-23
permalink: /2024/10/building-a-stand-alone-library-for-esp-idf/
tags:
  - esp32
  - programming
---

In a previous post, we learned how to [modularize software written with esp-idf](https://ncona.com/2024/08/modularizing-esp32-software/). The article mentions how we can use the `components` folder to create different modules.

In this article, we are going to use that knowledge to build a stand-alone library that can live in an independent git repo and can be consumed by different projects.

## Example project

ESP-IDF doesn't support building libraries by themselves, so the only way we can make sure our library is built is by shipping the library with an example project that depends on our library.

Since we also want our library to be easily consumable by other projects, our repo should follow this layout:

```
library-root/
├─ CMakeLists.txt
├─ src/
│  ├─ library.cpp
│
├─ include/
│  ├─ library.hpp
│
├─ example/
│  ├─ CMakeLists.txt
│  ├─ main/
│     ├─ CMakeLists.txt
│     ├─ example.cpp
```

<!--more-->

The CMakeLists.txt file in our root, will look the same as it was in a `components` folder:

```cmake
idf_component_register(SRCS "src/library.cpp"
                       INCLUDE_DIRS "include")
```

For the `example/CMakeLists.txt` we just need to set the `EXTRA_COMPONENT_DIRS` configuration:

```cmake
cmake_minimum_required(VERSION 3.16)

set(EXTRA_COMPONENT_DIRS "../")

include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(library-example)
```

Everything else stays the same.

We can now write our library's code as we wish. By making sure we use our library in our example, we'll ensure our code compiles correctly. It's also a good idea to write tests, but that's something I'll cover in another post.

To consume the library, we can use a submodule to download the library repo to our project's `components` folder.

## Conclusion

Building a stand-alone library is easy, as long as we know how to do it.

As usual, you can find a complete sample at [my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/building-a-stand-alone-library-for-esp-idf)
