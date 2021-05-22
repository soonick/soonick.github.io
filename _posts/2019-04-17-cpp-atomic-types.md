---
title: C++ Atomic types
author: adrian.ancona
layout: post
date: 2019-04-17
permalink: /2019/04/cpp-atomic-types/
tags:
  - c++
  - programming
---

An operation on data is said to be atomic if it is impossible to find the operation half-way done. It's very easy to see when an operation is not atomic when used in a struct:

```cpp
struct Type {
  int a;
  int b;
}

Type data;

void fillType(int a, int b) {
  data.a = a;
  data.b = b;
}
```

<!--more-->

The example above shows a non-atomic function that sets some values in a struct (`fillType`). The operation is not atomic, because two threads calling the same function would leave the data in an inconsistent state. Imagine this scenario:

- `Thread1` calls `fillType` with values `1` and `2`
- `Thread2` calls `fillType` with values `9` and `8`
- `Thread1` sets data.a to `1`
- `Thread2` sets data.a to `9`
- `Thread2` sets data.b to `8`
- `Thread1` sets data.b to `2`

After both threads are done executing, `data.a` will be set to `9` and `data.b` will be set to `2`. This is a state that neither `Thread1` nor `Thread2` expected. This unexpected behavior can be prevented by using a [mutex](/2018/08/mutexes-in-c/).

## Are mutexes necessary for primitive types?

Once I learned how to use mutexes, I started using them every time I had to make an operation on an object atomic. One thing that I wasn't sure was if a mutex is necessary for a primitive type. Could setting a primitive type to a value end up in an incosistent state?

I decided to put this to the test with a little program:

```cpp
#include <thread>
#include <iostream>

// Testing the `unsigned int` type
unsigned int number = 0;

void setToValue(int val) {
  while (true) {
    number = val;
  }
}

int main() {
  // Each thread will set a different byte. If at any point there is more than
  // one byte set, it means the type is not atomic
  std::thread t1(setToValue, 1);
  std::thread t2(setToValue, 1 << 8);
  std::thread t3(setToValue, 1 << 16);
  std::thread t4(setToValue, 1 << 24);

  // Keep printing the value of number
  while (true) {
    std::cout << number << std::endl;
  }

  // I don't join the threads because the program will run until I kill it. At
  // that point, everything will be killed
}
```

I left the program to execute for a couple of minutes and no value got corrupted. The output was always one of the expected values. After doing some research about this, it seems like the result depends on the architecture. Although this experiment didn't fail in my system, it is possible that it fails in other systems, so primitive types shouldn't be trusted to be atomic.

## Atomic types

Because there is no guarantee that operations on primitive types are atomic, C++ provides atomic types. Atomic types are a wrapper on a type that allows only certain operations that are guaranteed to be atomic.

The most common operations on atomic types are:

- `store(T desired)` - Set the value to `desired`
- `load()` - Get the value
- `exchange(T desired)` - Set the value, and return the previous value
- `compare_exchange_strong(T expected, T desired)` - First it checks if the value is set to `expected`. If it is not, it returns false without doing anything else. If the current value is the same as `expected`, it is set to `desired` and the function returns true.
- `compare_exchange_weak(T expected, T desired)` - Does the same as `compare_exchange_strong`, but it is possible that it will return `false` even if the value is as `expected`. The reason this version exists is that it can give better performance in some situations.

Even when I didn't see any failure in my previous test, I'm going to update it, so it is guaranteed to give an expected result regardless of the platform.

```cpp
#include <thread>
#include <iostream>
#include <atomic>

// Testing the `unsigned int` type
std::atomic<unsigned int> number(0);

void setToValue(int val) {
  while (true) {
    number.store(val);
  }
}

int main() {
  // Each thread will set a different byte. If at any point there is more than
  // one byte set, it means the type is not atomic
  std::thread t1(setToValue, 1);
  std::thread t2(setToValue, 1 << 8);
  std::thread t3(setToValue, 1 << 16);
  std::thread t4(setToValue, 1 << 24);

  // Keep printing the value of number
  while (true) {
    std::cout << number.load() << std::endl;
  }

  // I don't join the threads because the program will run until I kill it. At
  // that point, everything will be killed
}
```

This is a very simple use of atomic types, just to get familiar with them. In future articles, I will explore in which situations they are useful and how to use them in those situations.
