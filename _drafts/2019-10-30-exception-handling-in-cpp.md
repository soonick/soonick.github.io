---
title: Exception handling in C++
author: adrian.ancona
layout: post
date: 2019-10-30
permalink: /2019/10/exception-handling-in-cpp/
tags:
  - c++
  - programming
---

In this post I'm going to talk about how to use exceptions for error handling in C++.

## Exceptions

They are called exceptions, because they happen in exceptional scenarios. A program should in most cases run without exceptions, but sometimes unexpected things happen and we might want to do something in those scenarios.

Exceptions happen when there is either a developer error (Dereferencing a null pointer) or an environment error (Trying to write to a disk that is full). They should not happen for user created errors (incorrect input by user), if those errors are common.

When an error such as dereferencing a null pointer occurs, an Exception object is created. The Exception object contains information about the error, and the state of the program at the time this happened. The exception will then be `thrown` and left for the runtime to handle.

<!--more-->

## Exception handling

When an exception is thrown, the runtime will look for an `exception handler` through the function stack. If the exception is not handled, the program will crash.

## Advantages

One of the main advantages of using exceptions is separating normal code from exceptional scenarios. Imagine we have this code that doesn't use exceptions:

```cpp
void createReport() {
  const auto data = getData();
  if (data == nullptr) {
    std::cout << "Error getting data" << std::endl;
  }

  const auto report = generateReport(data);
  if (report == nullptr) {
    std::cout << "Error generating report " << std::endl;
  }

  const auto sent = sendMail(report);
  if (!sent) {
    std::cout << "Error sending report" << std::endl;
  }
}
```

And compare it with this code that uses exceptions:

```cpp
void createReport() {
  try {
    const auto data = getData();
    const auto report = generateReport(data);
    const auto sent = sendMail(report);
  } catch (DatabaseException& ex) {
    std::cout << "Error getting data" << std::endl;
  } catch (ReportException& ex) {
    std::cout << "Error generating report " << std::endl;
  } catch (EmailException& ex) {
    std::cout << "Error sending report" << std::endl;
  }
}
```

The amount of code for both examples is almost the same. The most important difference is that the version that uses exceptions shows the most common scenario clearly grouped together. Exceptional cases are separated at the end of the function and don't distract us from understanding what the code intended to do.

## Throwing exceptions

Any function can create and throw an Exception if something unexpected happens. An Exception is nothing but a class that inherits from std::exception. In C++ it is possible to `throw` any object, but it is recommended to only throw objects that inherit from `std::exception`.

The `std::exception` class defines a virtual method `what()` that returns a `char*` with a message describing the exception.

```cpp
void func() {
  throw std::runtime_error("This function always throws an exception");
}
```

As shown in the example above. Throwing an exception is usually very easy. `runtime_error` is one of the types of exceptions defined in the standard. It can be found in [`<stdexcept>`](https://en.cppreference.com/w/cpp/header/stdexcept).

## Catching exceptions

Catching an exception is as easy as throwing it. It is recommended to catch exceptions by reference and only catch them if you are going to handle them, otherwise, let them be caught by another function in the stack.

```cpp
int main() {
  try {
    func();
  } catch(std::runtime_error& ex) {
    std::cout << "Exception was thrown: " << ex.what() << std::endl;
  }
}
```

## Exception specifications

C++ 11 introduced the keywords `noexcept` and `throw` as part of a function definition. These keywords were intended to tell users if a function could throw an exception. They turned out to be problematic so they are now discouraged. You might see them in old code, but you should probably not be using them.
