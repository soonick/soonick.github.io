---
id: 4858
title: Introduction to C++ threads
date: 2018-01-27T03:10:27+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4858
permalink: /2018/01/introduction-to-c-threads/
categories:
  - C/C++
tags:
  - linux
  - programming
---
I&#8217;m getting started with concurrency in C++ and threads seem to be a good way to get familiar with the basics.

## Processes

When a user starts executing a program, the program becomes a [process](https://en.wikipedia.org/wiki/Process_(computing)). A process is a set of instructions (the code) and state (memory, registers) that is managed by the operating system. The operating system tells the processor which process it should be running.

In a system with a single core, only one process can be executed at one point in time. Since there are a lot of processes running in a modern system, the operating system will take care of deciding which processes should be serviced by the CPU.

Processes can create other processes by using [Fork](https://en.wikipedia.org/wiki/Fork_(system_call)). When a process forks, they become independent of each other. They own their own instructions and state.

<!--more-->

## Threads

A process can contain multiple [threads](https://en.wikipedia.org/wiki/Thread_(computing)). Because multiple threads live in the same process, they share their state (memory, address space). Because threads share state, switching between different threads in the same process is faster than switching between different processes.

Multiple threads in a single process can be executed in parallel if the hardware allows it (multiple CPU cores). This can make a program significantly faster. Because multiple threads can run simultaneously sharing state, it is important to be aware of problems that can happen when multiple threads access or modify state at the same time.

## std::thread

Now that we know what a thread is, lets look at how we can have a program use multiple threads:

```cpp
#include <iostream>
#include <thread>

void someFunction()
{
  for (int i = 0; i < 5; ++i) {
    std::cout << "i = " << i << "\n";
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
  }
}

int main()
{
  std::thread littleThread(someFunction);
  std::thread anotherLittleThread(someFunction);

  std::cout << "Started the threads\n";

  littleThread.join();
  anotherLittleThread.join();

  std::cout << "End of the program\n";
}
```

To compile this program I used the following command:

```
g++ threads.cpp -std=c++11 -pthread
```

When we execute this program a new process with a single thread is started. This thread will start executing the main function. The first thing the main function does is start two new threads that will execute _someFunction_ independently. A thing to keep in mind here is that as soon as a thread is started its execution begins. This means there is no garantee that &#8220;Started the threads&#8221; will be printed before _littleThread_ or _anotherLittleThread_ prints anything.

The calls to join() make the main thread wait for _littleThread_ and _anotherLittleThread_ before it continues. Because of this, this program guarantees that printing &#8220;End of program&#8221; is the last thing it will do.

The only thing _someFunction_ does is execute a loop that will print the value of i. The call to _std::this\_thread::sleep\_for(std::chrono::milliseconds(10));_ sleeps the thread for 10 miliseconds before continuing.

Because the main thread and the two threads we created can be executed in parallel, there is no guarantee about what the output of this program will be. Here is one of the outputs I got after running it:

```
i = i = 00
Started the threads

i = 1
i = 1
i = 2
i = 2
i = 3
i = 3
i = i = 44

End of the program
```

It is also possible to pass arguments to threads. These arguments will be passed by value by default:

```cpp
#include <iostream>
#include <thread>

void add(int a, int b)
{
  std::cout << "Sum = " << a + b << "\n";
}

int main()
{
  std::cout << "We'll make the addition in another thread\n";

  std::thread sumThread(add, 3, 6);
  sumThread.join();

  std::cout << "End of the program\n";
}
```

This program executes the sum in another thread. The output will always be the same:

```
We'll make the addition in another thread
Sum = 9
End of the program
```

## Exceptions

When an exception occurs in a single threaded program and it is not caught, the program will be aborted without continuing it&#8217;s execution.

```cpp
#include <iostream>
#include <thread>

int main()
{
  std::cout << "Beginning of the program\n";
  throw "hello";
  std::cout << "End of the program\n";
}
```

The output of this program is:

```
Beginning of the program
terminate called after throwing an instance of 'char const*'
Aborted (core dumped)
```

In a multi-threaded program, the same thing happens:

```cpp
#include <iostream>
#include <thread>

void ohNo()
{
  throw "hello";
}

int main()
{
  std::cout << "Start of the program\n";

  std::thread a(ohNo);
  a.join();

  std::cout << "End of the program\n";
}
```

Output:

```
Start of the program
terminate called after throwing an instance of 'char const*'
Aborted (core dumped)
```

If an exception happens in a thread, the whole process is aborted.

## Shared state

You might have noticed that the output from my first program looked a little strange:

```
i = i = 00
Started the threads

i = 1
i = 1
i = 2
i = 2
i = 3
i = 3
i = i = 44

End of the program
```

This happened because both threads were writing to the same stream concurrently. Both threads tried to write &#8220;i = 0&#8221; at the same time, which caused:

```
i = i = 00
```

This is something very important to keep in mind when writing multi-threaded programs. If two threads are writing to the same resource at the same time the result is undefined (undefined is something we want to avoid in all our programs). There are multiple techniques to help prevent these kind of problems but I will cover them in another article.

## Next

In this post I covered the most basic thing we can do with a thread, which is start it&#8217;s execution and wait for it to finish. I will cover other important parts in other articles, namely: Techniques to avoid issues due to concurrent writes and ways to get values back from threads.
