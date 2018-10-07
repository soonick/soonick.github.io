---
id: 5213
title: Passing by reference to a thread in C++
date: 2018-08-09T05:07:21+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=5213
permalink: /2018/08/passing-by-reference-to-a-thread-in-c/
categories:
  - C/C++
tags:
  - design patterns
  - programming
---
Today I discovered that there are some interesting behaviors when you use a function that takes a reference as an entry point for a thread.

```cpp
#include <iostream>
#include <thread>

struct container {
  int numThings;
};

void setThings(container& cont)
{
  cont.numThings = 3;
}

int main()
{
  container c;
  std::thread t(setThings, c);

  t.join();

  std::cout << c.numThings;
}
```

<!--more-->

The code above works with some compilers but not with others. When it works, the result that is printed is __. What happens is that when the thread is started the arguments are first copied into the thread and then passed into the function. This copy is done to avoid threads from reading memory addresses that are not valid (The memory address could become invalid if the caller of the thread has returned already).

The intent of this code was to have the thread modify the container. This is possible by using _std::ref_:

```cpp
#include <iostream>
#include <thread>

struct container {
  int numThings;
};

void setThings(container& cont)
{
  cont.numThings = 3;
}

int main()
{
  container c;
  std::thread t(setThings, std::ref(c));

  t.join();

  std::cout << c.numThings;
}
```

In this case the value printed is _3_, as expected. std::ref wraps c in a _reference_wrapper<container>_. The reason we are able to pass a _reference_wrapper<container>_ to setThings instead of a _container&_ is because it defines and implicit conversion from reference_wrapper<T> to T&.

The behavior above is good, because it makes you explicitly decide when you want to pass by reference to a thread, which could be dangerous in some situations.

There are other cases, where you won&#8217;t get a compiler error:

```cpp
#include <iostream>
#include <thread>

void talk(const std::string& words)
{
  std::cout << words;
}

void doInThread(int param) {
  char buffer[10];
  sprintf(buffer, "%i", param);
  std::thread t(talk, buffer);
  t.detach();
}

int main()
{
  doInThread(1);
  doInThread(2);
  doInThread(3);
}
```

The output of this program varies depending on the order in which threads are executed, but there are some scenarios where something totally unexpected happens. The output comes like this: _333_. This shouldn&#8217;t be possible, because only one thread is told to print 3.

The problem comes from the buffer variable. This variable is a _char*_. When doInThread exits, the memory from that pointer is released and is free to use again. Because we call doInThread 3 times in a row, the same memory is being assigned and released on each call. The last value it is assigned is 3.

The tricky thing is when we create our thread, all arguments are copied to the thread context. In this case, the _char*_ is copied to the thread. In the thread context, the _char*_ is converted to std::string and used by the talk function. The copying of the _char*_ happens right away, but the conversion to _std::string_ can happen some time in the future. In the case where we get _333_ the conversion is not done until after the buffer is the to 3, so all threads end up converting to the same value.

This scenario feels to me like hard to avoid, so it is probably a good idea to keep and eye on this automatic conversions when using threads. It&#8217;s safer to do the explicit conversion before to be sure:

```
std::thread t(talk, std::string(buffer));
```
