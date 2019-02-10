---
id: 5218
title: Mutexes in C++
date: 2018-08-23T05:34:23+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=5218
permalink: /2018/08/mutexes-in-c/
tags:
  - c++
  - design_patterns
  - linux
  - programming
---
## Why use Mutexes?

Mutexes are a technique for concurrency management. They are called Mutex because of their MUTual EXclusion property (Only one thread can be doing work at a given time).

Mutexes are used to prevent race conditions on shared data between threads. Lets look at a stack backed by an array. At some point it could look like this:

[<img src="/images/posts/head.jpg" />](/images/posts/head.jpg)

If we want to insert a value on this stack we need to follow these steps:

1 &#8211; Get the index of the head
  
2 &#8211; Increment the index of the head by one
  
3 &#8211; Save a value in the head

If two threads need to insert a value into this stack at the same time, one of the inserted values could get lost:

<!--more-->

[<img src="/images/posts/threads.jpg" />](/images/posts/threads.jpg)

In the image above, one thread is trying to push 7 to the stack, while another thread is trying to push 4. The end result is that only one of the values is inserted (we don&#8217;t know which one), and the other is lost.

## How do Mutexes work?

When a thread is about to enter a critical section (Do something that can cause race conditions), it needs to grab a lock of the Mutex. Only one thread can hold the lock at a time. If two threads try to grab the lock at the same time, only one will get it and the other will wait until the other thread releases it before proceeding.

[<img src="/images/posts/mutexes.jpg" />](/images/posts/mutexes.jpg)

This solves the problem of a race condition, by making sure one operation is performed before the other.

You might be asking yourself: _What about a race condition grabbing the lock?_. This is avoided at the hardware level by using [compare-and-swap](https://en.wikipedia.org/wiki/Compare-and-swap). Basically, it can atomically check that the lock has one value (available) and then set it to unavailable. I&#8217;m not going to cover how this is done at the hardware level in this post.

The other thing that might be concerning about the picture above is the _waiting_ happening in T2. This part is implemented by the Operating System. When a thread is waiting for a Mutex it won&#8217;t be scheduled to do work until the Mutex is released. When the Mutex is finally released, the thread will be woken up and will be able to grab the lock.

## C++

Using Mutexes is pretty easy. Here is a naive example:

```cpp
#include <iostream>
#include <thread>
#include <mutex>

int value = 0;
std::mutex mutex;

void setValue(int v) {
  mutex.lock();
  value = v;
  mutex.unlock();
}

int main() {
  std::thread t1(setValue, 1);
  std::thread t2(setValue, 2);

  t1.join();
  t2.join();

  std::cout << value << "\n";
}
```

The example above shows how you can lock a Mutex before accessing shared data and unlock it when you are done. One important thing to notice here is that we have to explicitly unlock the Mutex, otherwise it will never be made available again an the program will be waiting forever. To make things trickier, if the section of code protected by the Mutex threw and exception, the Mutex would never be unlocked.

To prevent problems caused by not unlocking a Mutex, C++ provides _std::lock_guard_. It works by locking the provided Mutex on creation and unlocking it on it&#8217;s destructor (when it goes out of scope).

The previous example refactored to use std::lock_guard:

```cpp
#include <iostream>
#include <thread>
#include <mutex>

int value = 0;
std::mutex mutex;

void setValue(int v) {
  std::lock_guard<std::mutex> g(mutex);
  value = v;
}

int main() {
  std::thread t1(setValue, 1);
  std::thread t2(setValue, 2);

  t1.join();
  t2.join();

  std::cout << value << "\n";
}
```

We saved ourselves the need to call unlock and made the code safer because the Mutex will be unlocked even if an exception is thrown.
