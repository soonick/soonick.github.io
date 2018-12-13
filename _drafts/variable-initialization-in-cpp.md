---
title: Variable initialization in C++
author: adrian.ancona
layout: post
date: 2018-12-26
permalink: /2018/12/variable-initialization-in-cpp/
tags:
  - programming
  - c++
---

In a previous article I wrote a little about the [difference between declaration and definition](/2017/12/c-header-files/) of a variable. As a refresher. This is a declaration:

```
int add(int a, int b);
```

This is a definition:

```
int add(int a, int b) {
  return a + b;
}
```

A declaration is somehow incomplete until it is defined.

<!--more-->

## Initialization

An initialization is when you provide a value to a variable. In C++ there are many ways to initalize a variable and I'm going to try to explain some of them in this article.

There are three main ways of initalizing a variable:

```cpp
int main() {
  // Expression
  int a = 1;

  // Expression list
  int b(2);

  // Initializer list
  int c{3};
}
```

In the code above, three variables were initialized: a to 1, b to 2 and c to 3.

## Expression

The expression is the simplest way to initialize a variable. When this is done, the value on the right side of the equal sign is copied to the variable on the left side. If the compiler deems it possible, the initialization might be done at compile time.

## Expression list

An expression list can be used to initialize objects using their constructor, for example:

```cpp
#include <vector>

int main() {
  std::vector<int> vec(10, 5);
}
```

In the example above we are initializing the vector `vec` with a size of `10`, and all values set to `5`.

## Initializer list

Initializer lists are the newest way of initializing a variable introduced in C++11.

They look similar to expression lists, but behave a little different:

```cpp
#include <vector>

int main() {
  std::vector<int> vec{10, 5};
}
```

In the example above we are creating a vector with two items on it (10 and 5). Let's see how this works.

If we declare a type with a constructor that takes 1 or 2 ints as arguments, the compiler will use the constructors available:

```cpp
#include <iostream>

struct Hello {
  Hello(int v) : a(v) {}
  Hello(int v1, int v2) : a(v1), b(v2) {}

  int a;
  int b;
};

int main() {
  Hello hello{1};
  Hello hello2{1, 2};

  std::cout << hello.a << "-" << hello.b << std::endl;
  std::cout << hello2.a << "-" << hello2.b << std::endl;
}
```

The output is:

```
1-0
1-2
```

These examples should be somewhat clear. Two instances of Hello were created using an initializer list, that in turn used the constructor to inizialize the variables.

But, how does the vector work? How is it able to receive an arbitrary number of ints without having to write a constructor for each?

https://stackoverflow.com/questions/4178175/what-are-aggregates-and-pods-and-how-why-are-they-special





Narrowing conversions
