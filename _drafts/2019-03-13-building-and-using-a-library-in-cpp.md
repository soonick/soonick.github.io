---
title: Building and using a library in C++
author: adrian.ancona
layout: post
date: 2019-03-13
permalink: /2019/03/building-and-using-a-library-in-cpp/
tags:
  - c++
  - programming
  - dependency_management
---

In a previous article I wrote an article explaining [how header files work in C++](/2017/12/c-header-files/). Among other things, the article explains how you can split your code in multiple files and link them together to create a single executable. One of the advantages of doing this, is that it allows code to be better organized, by separating different responsibilites in different files.

In this article I want to go one step further and explain how to create a library that can be reused by multiple projects.

<!--more-->

## C++ library

In programming, a library refers to a reusable piece of functionality that is self-contained and can be used by other programs. In contrast to an executable file, a library can't be used by itself. It provides some functionality, but nohing is executing it yet.

Libraries in C++ usually have a`.a` extension, but as usual, in C++ things are not as simple. The first problem is that the `.a` file is usually not enough to use the library, you also need the corresponding header file so programs can use the library. Another problem is that a library has to be compiled for a specific platform, so it is possible that a `.a` file can't be used with your program because they have been compiled for different platforms.

## Building a library

To create a simple library we need a single `cpp` file:

MyLibrary.cpp:

```cpp
#include "MyLibrary.h"

int MyLibrary::addFive(int number) {
  return number + 5;
}
```

To compile the library we can use:

```bash
g++ -c -o MyLibrary.o MyLibrary.cpp
```

The `-c` flag tells the compiler to not link the library. If we omit that flag, the compiler will complain that `main` doesn't exist. Once we have the object file, we need to use `ar` command to create a library out of it:

```bash
ar rcs MyLibrary.a MyLibrary.o
```

The library we just created is called a `static` library, these libraries generally have a `.a` extension. A static library is a self-contained library that is linked with the binary at compile time.

Before our library can be used, we need to create a header that defines its interface:

```cpp
#pragma once

class MyLibrary {
 public:
  static int addFive(int number);
};
```

The header file is necessary so users of the library can include this file and have the interface available to them.

## Using a library

Now that we have our library, we use it in a program:

```cpp
#include "MyLibrary.h"

int main() {
  return MyLibrary::addFive(-5);
}
```

We can now compile this program:

```bash
g++ -c -o main.o main.cpp
```

And link it with our library:

```
g++ -o main main.o MyLibrary.o
```

This is all it takes. We now have an executable file that uses a library we created.

# Conclusion

The example in this article is very small so it's not easy to see the benefits right away. The benefits become a lot clearer when you need to use a library that is made of multiple files. When this time comes, you will be happy that you don't need to get all the files and compile the large library in order to use it.
