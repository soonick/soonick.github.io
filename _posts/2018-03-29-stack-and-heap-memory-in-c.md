---
id: 4949
title: Stack and heap memory in C++
date: 2018-03-29T03:52:19+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4949
permalink: /2018/03/stack-and-heap-memory-in-c/
tags:
  - c++
  - programming
---
Since I&#8217;ve been working in C++, I&#8217;ve noticed the necessity to get familiar with concepts about computer architecture and how the operating system works. One thing that has been bothering me for a few weeks is hearing people talk about the heap and stack memory, while I don&#8217;t really know what those things mean.

I decided to write this post to try to explain to myself what is the difference between stack memory and heap memory and hopefully understand why people keep talking about them.

## The names

[Stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) and [Heap](https://en.wikipedia.org/wiki/Heap_(data_structure)) are both names of data structures. This can lead to some confusion, because although the stack is called like that because it works similar to a stack (I&#8217;ll explain more about this), the heap is not related at all to the heap data structure. The exact origin of the heap word in this context is unknown to me, but from a little research it seems like it&#8217;s use is based on the English language definition for that word:

```
An untidy collection of things piled up haphazardly
```

Which actually describes pretty well what a heap of memory is.

<!--more-->

## High level

There are a few interesting high level details that are worth knowing about the heap and the stack before we give a closer look. Let&#8217;s start with the stack.

The stack is a portion of memory (lives in RAM) that is allocated to a thread when it is created (each thread has it&#8217;s own stack). The stack is not very smart. It grows and shrinks similar to a stack (The data structure); things can be added to the top and are removed by moving the stack pointer downwards. The stack space is allocated in RAM when the thread is created and it doesn&#8217;t change it&#8217;s size. If you try to store more information than fits in the stack, you will get a stack overflow and the application will crash.

The heap is a portion of memory that is allocated to the process when it is started. You can add information to the heap on demand and it can be accessed by all threads in the same process. If you try to store more information in the heap than it can hold, the Operating System will look for free space in RAM and give it to you. This means that you can store a lot more information in the heap than in the stack.

Both the stack and the heap live in RAM, this means that they both enjoy the same random access and speed properties of RAM. The stack is generally faster because finding available memory in RAM (allocating memory) can be an expensive operation. The stack only needs to do this when a thread is created, because it has a predefined size and it grows and shrinks by moving a pointer up or down the stack. The heap grows as the application requires more data, and memory allocations happen a lot more often.

## Closer look at the stack

As I mentioned before, a stack is allocated for each thread in a process. We can find out the stack size in a Linux system using _ulimit_:

```
$ ulimit -s
8192
```

That means, each thread will be given 8192Kb(8Mb) of stack space on creation.

Lets write a little program to look a little at how things are stacked in the stack:

```cpp
#include <iostream>

void anotherFunction() {
  int a = 1;
  int b = 2;
  int c = 3;

  std::cout << "Variable a in anotherFunction has address: " << &a << "\n";
  std::cout << "Variable b in anotherFunction has address: " << &b << "\n";
  std::cout << "Variable c in anotherFunction has address: " << &c << "\n";
}

void function() {
  int a = 1;
  int b = 2;
  int c = 3;

  std::cout << "Variable a in address: " << &a << "\n";
  std::cout << "Variable b in address: " << &b << "\n";
  std::cout << "Variable c in address: " << &c << "\n";
}

int main() {
  int a = 1;
  int b = 2;
  int c = 3;

  std::cout << "Variable a is in memory address: " << &a << "\n";
  std::cout << "Variable b is in memory address: " << &b << "\n";
  std::cout << "Variable c is in memory address: " << &c << "\n";

  function();
  anotherFunction();
}
```

The output of this program will change every time, because a stack allocation will be done every time it is run. A sample output looks like this:

```cpp
Variable a is in memory address: 0x7fffeb1a7c8c
Variable b is in memory address: 0x7fffeb1a7c90
Variable c is in memory address: 0x7fffeb1a7c94
Variable a in address: 0x7fffeb1a7c5c
Variable b in address: 0x7fffeb1a7c60
Variable c in address: 0x7fffeb1a7c64
Variable a in anotherFunction has address: 0x7fffeb1a7c5c
Variable b in anotherFunction has address: 0x7fffeb1a7c60
Variable c in anotherFunction has address: 0x7fffeb1a7c64
```

There are a few things we can learn about the output of this program. All variables used in the program are allocated in the stack, because of that reason, we can see that the memory addresses are contiguous. The first int we created was given address `0x7fffeb1a7c8c` and the next one was given address `0x7fffeb1a7c90`. From the output we can see that the size of an int in this system is 4 bytes.

Another interesting thing about the output is that variables created inside function() have lower address than those of main. This makes me think that the stack grows towards lower memory addresses. More interesting is that variables declared in a single function seem to grow towards higher memory addresses.

One more thing that we can see is that the memory addresses used by `function` and `anotherFunction` are the same, which shows that when `function` returned, all the memory addresses it was using were given back to the stack (the stack pointer was moved up), and when `anotherFunction` was called the same addresses were allocated (the stack pointer was moved down).

## Closer look at the heap

Let&#8217;s use a similar program to look at how the heap works:

```cpp
#include <iostream>

void anotherFunction() {
  int *a = new int(1);
  int *b = new int(2);
  int *c = new int(3);

  std::cout << "Variable a in anotherFunction has address: " << a << "\n";
  std::cout << "Variable b in anotherFunction has address: " << b << "\n";
  std::cout << "Variable c in anotherFunction has address: " << c << "\n";
}

void function() {
  int *a = new int(1);
  int *b = new int(2);
  int *c = new int(3);

  std::cout << "Variable a in address: " << a << "\n";
  std::cout << "Variable b in address: " << b << "\n";
  std::cout << "Variable c in address: " << c << "\n";
}

int main() {
  int *a = new int(1);
  int *b = new int(2);
  int *c = new int(3);

  std::cout << "Variable a is in memory address: " << a << "\n";
  std::cout << "Variable b is in memory address: " << b << "\n";
  std::cout << "Variable c is in memory address: " << c << "\n";

  function();
  anotherFunction();
}
```

This time we use _new int()_ to allocate in the heap instead of the stack. The output looks like this:

```cpp
Variable a is in memory address: 0x24d4c20
Variable b is in memory address: 0x24d4c40
Variable c is in memory address: 0x24d4c60
Variable a in address: 0x24d5090
Variable b in address: 0x24d50b0
Variable c in address: 0x24d50d0
Variable a in anotherFunction has address: 0x24d50f0
Variable b in anotherFunction has address: 0x24d5110
Variable c in anotherFunction has address: 0x24d5130
```

We can see based on the memory addresses that they also seem to increase at a constant rate with every new variable declaration. This might be an artifact of how the heap does the allocation. The most visible change is that in this case `function` and `anotherFunction` don't share the same memory addresses, because we actually never released the addresses (memory addresses allocated with new, need to be de-allocated with delete). When a variable is put in the stack it gets deallocated automatically when the scope where it was defined exits.

Lets look at what happens when we actually deallocate the memory we are not using anymore:

```cpp
#include <iostream>

void anotherFunction() {
  int *a = new int(1);
  int *b = new int(2);
  int *c = new int(3);

  std::cout << "Variable a in anotherFunction has address: " << a << "\n";
  std::cout << "Variable b in anotherFunction has address: " << b << "\n";
  std::cout << "Variable c in anotherFunction has address: " << c << "\n";

  delete a;
  delete b;
  delete c;
}

void function() {
  int *a = new int(1);
  int *b = new int(2);
  int *c = new int(3);

  std::cout << "Variable a in address: " << a << "\n";
  std::cout << "Variable b in address: " << b << "\n";
  std::cout << "Variable c in address: " << c << "\n";

  delete a;
  delete b;
  delete c;
}

int main() {
  int *a = new int(1);
  int *b = new int(2);
  int *c = new int(3);

  std::cout << "Variable a is in memory address: " << a << "\n";
  std::cout << "Variable b is in memory address: " << b << "\n";
  std::cout << "Variable c is in memory address: " << c << "\n";

  function();
  anotherFunction();

  delete a;
  delete b;
  delete c;
}
```

The output looks like this:

```cpp
Variable a is in memory address: 0x2227c20
Variable b is in memory address: 0x2227c40
Variable c is in memory address: 0x2227c60
Variable a in address: 0x2228090
Variable b in address: 0x22280b0
Variable c in address: 0x22280d0
Variable a in anotherFunction has address: 0x22280d0
Variable b in anotherFunction has address: 0x22280b0
Variable c in anotherFunction has address: 0x2228090
```

It&#8217;s very interesting to see that the allocator reuses the memory address that were just released, which results in _function_ and _anotherFunction_ sharing the same memory addresses.

## Conclusion

It is good to understand a little better how stack and heap allocation work. The abstraction is done well enough that I don't think is very necessary to possess this knowledge in order to write good programs. In most cases you will allocate to the heap (using new) because you need to share resources between threads or different function scopes.
