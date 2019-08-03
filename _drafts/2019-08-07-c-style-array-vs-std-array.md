---
title: C-style arrays vs std::array
author: adrian.ancona
layout: post
date: 2019-08-07
permalink: /2019/08/c-style-arrays-vs-std-array/
tags:
  - programming
  - c++
---

In this post I'm going to talk about the advantages of using std::array vs a c-style array whenever it is possible to do so.

## C-style arrays

Let's start by remembering what a c-style array is.

In C and C++ we can create an array of ints like this:

```cpp
int arr[3];
```

<!--more-->

If we want to have a function that receives an array, we need to also pass the size of the array:

```cpp
void printArray(int* in, int size) {
  for (int i = 0; i < size; i++) {
    std::cout << in[i] << std::endl;
  }
}

int main() {
  int arr[3] = {1, 2, 3};
  printArray(arr, 3);
}
```

The reason the size needs to either be known at compile time, or be passed as an argument, is because there is no way to dynamically get the size of a c-style array. The size of the array can't be deduced by the program, because it is not stored anywhere for us. When the array is created, the operating system allocates n (in this case 3) contiguous addresses in memory, and it expects the programmer to keep track of the size.

Having the size as a different argument is error prone, because it is possible for the programmer to pass an incorrect size, and cause the program to crash.

## std::array

`std::array` is a thin layer of abstraction on top of c-style arrays. The most noticeable benefit, is that it keeps track of its size.

To create an `std::array` that can carry 3 ints:

```cpp
std::array<int, 3> arr;
```

It can be used in a function like this:

```cpp
void printArray(const std::array<int, 3>& in) {
  for (int i = 0; i < in.size(); i++) {
    std::cout << in[i] << std::endl;
  }
}

int main() {
  std::array<int, 3> arr{1, 2, 3};
  printArray(arr);
}
```

In this case, printArray, accepts only arrays with 3 integers. If anything else is passed to the function, the program will fail to compile. This gives us type safety, but it would be annoying to have to rewrite the same function if we wanted to accept arrays of different sizes. To solve this problem we can use templates:

```cpp
template <int Size>
void printArray(const std::array<int, Size>& in) {
  for (int i = 0; i < in.size(); i++) {
    std::cout << in[i] << std::endl;
  }
}

int main() {
  std::array<int, 3> arr{1, 2, 3};
  printArray<3>(arr);
}
```

## Dynamic arrays

Since the size of an `std::array` is specified as a template parameter, it has the disadvantage, that it can't be set at runtime. For c-style arrays, we can do this:

```cpp
int main() {
  int size;
  std::cin >> size;

  auto arr = new int[size];
}
```

For `std::array` this is not possible. To achieve type safety on a dynamic size container, we need to use a vector or another higher level container.
