---
title: Concurrency in computer systems
author: adrian.ancona
layout: post
date: 2022-01-12
permalink: /2022/01/concurrency-in-computer-systems
tags:
  - computer_science
  - design_patterns

---

In this article we are going to learn what is concurrency in computer systems. To understand it better, we'll see what are the problems that occur when there is concurrency and what are some ways to prevent those problems.

## What is concurrency?

Concurrency referes to the ability of a computer system to do different things at the same time.

We see concurrency in action in our computers when there are multiple programs executing at the same time. We can be playing some music in our computer and at the same time browsing the internet, for example.

At a high level, there are two ways of doing concurrency:

- Time slicing
- Parallel execution

For hardware that supports parallel execution, time slicing can be done on top of it.

<!--more-->

## Time slicing

To understand time slicing, let's imagine we have a computer with a single processor core and a single thread of execution. i.e. It can only do one thing at one time.

This imaginary computer allows us to run multiple programs by using time slicing. It also has a very simple scheduling mechanism, it allows each program to execute 4 instructions and then it switches to the next program. It does the same for all programs that are waiting for processor time and keeps doing this in a round robin manner as long as the system is running.

Lets say we have this program (each line represents an instruction):

```
- Assign 1 to variable a
- Print a
- Increase a by 2
- Go back to the second instruction
```

If we are running only this program, our computer will start by printing `1`, then `3`, then `5` and so on. This table shows which process the computer is running:

| Time | Running process |
| ---- | --------------- |
| 0s   | P1              |
| 1s   | P1              |
| 2s   | P1              |
| 3s   | P1              |
| ...  | ...             |

Now, let's say that we have another program:

```
- Assign 2 to variable a
- Print a
- Increase a by 2
- Go back to the second instruction
```

This program, if executed by itself will printi `2`, then `4`, then `6` and so on. If we start running both programs in our imaginary computer at the same time, we will see something like this:

| Time | Running process | Output |
| ---- | --------------- | ------ |
| 0s   | P1              |        |
| 1s   | P1              | 1      |
| 2s   | P1              |        |
| 3s   | P1              |        |
| 4s   | P2              |        |
| 5s   | P2              | 2      |
| 6s   | P2              |        |
| 7s   | P2              |        |
| 8s   | P1              |        |
| 9s   | P1              | 3      |
| 10s  | P1              |        |
| ...  | ...             | ...    |

Both programs get to make progress, but since the processing power of the computer is split between the programs, their execution will take longer than if they were running by themselves.

## Parallel processing

To show how parallel processing works, let's change our imaginary computer a little. This time our computer can execute two threads at the same time.

The computer will schedule to Thread 1, then to Thread 2 in a round robin manner.

If we execute both our programs we'll see something like this:

| Time | Thread 1 process | Thread 2 process | Output |
| ---- | ---------------- | ---------------- | ------ |
| 0s   | P1               | P2               |        |
| 1s   | P1               | P2               | 1 2    |
| 2s   | P1               | P2               |        |
| 3s   | P1               | P2               |        |
| 4s   | P1               | P2               |        |
| 5s   | P1               | P2               | 3 4    |
| ...  | ...              | ...              | ...    |

In this case, since each program is executing in their own thread, they make progress a lot faster. With time slicing, `3` was printed at second `9`, while with parallelism it was printed at second `5`.

The output column is actually a little innacurate, but it helps us illustrate the differences in execution time.

## The problem with concurrency

Concurrency allows our computers to run multiple things at the same time. This is great, but it comes with some challenges that developers need to take into account when writing software; namely, dealing with shared resources.

A computer has a finite number of resources: memory, disk, etc. These resources are used by any program running on that computer, so if care is not taken, they can interfere with each other.

> Modern operating systems make sure resources used by a process can't be accessed by other processes, so the problem really only happens when we have multiple threads in a single process

The most common problem in concurrency are data races. This happens when two threads try to access a shared resource (most commonly memory) at the same time.

To illustrate this problem, let's imagine a program that stores a number in memory. The program is connected to the internet and every time it receives a new request, it increases that number. The program uses concurrency, so it can process many requests at the same time.

The code we execute on each request is:

```
- Read value from memory into variable a
- Increase a by 1
- Write new value to memory
```

Variable `a` is local to each thread, so they can't interfere with each other there. The `memory` location where the value is persisted between requests is shared between all threads, so we need to be more careful with that one.

Let's see what happens when we receive two requests to increase the value in memory:

| Time | Running process | Value in memory |
| ---- | --------------- | --------------- |
| 0s   | T1 (a = 0)      | 0               |
| 1s   | T1 (a = a + 1)  | 0               |
| 2s   | T2 (a = 0)      | 0               |
| 3s   | T2 (a = a + 1)  | 0               |
| 4s   | T2 (a = 1)      | 1               |
| 5s   | T1 (a = 1)      | 1               |

`T1` read the value from memory and increased the local variable. Before it could save it to the shared memory, `T2` started executing. It read `0` from shared memory, increased it and wrote the new value. When `T2` finished executing, `T1` continued execution and was finally able to write `1` to memory.

The end result in memory is `1` while we actually should have `2`, since we received 2 requests. This is what we called a data race.

## Solving data races

The solution to this problem is very obvious. Let `T1` finish before we start executing `T2`. The problem with this solution is that in the real world threads might never shutdown, so waiting for it to finish might mean that no other thread is ever executed.

Since waiting for a thread to finish is not an option, we need to find another way to achieve what we want: don't modify the value in memory while another thread is using it.

In computer systems we call this [Mutual Exclusion](https://en.wikipedia.org/wiki/Mutual_exclusion) or Mutex.

Mutual Exclusion refers to a mechanism to ensure that only one thread is accessing a shared reasource at a given time.

To make Mutual Exclusion work, we need to identify the parts of our code that need to be executed by only a single thread at a given time. In our example, all the code needs to use Mutual Exclusion. From the time we read to the time we write we need to make sure nobody else reads and nobody else writes to that memory location.

Now that we know we want Mutual Exclusion, how do we use it? Most programming languages provide locks (also called mutexes) that can be used to make sure only one thread is executing at some given time. Let's change our program to use a lock:

```
- Grab lock
- Read value from memory into variable a
- Increase a by 1
- Write new value to memory
- Release lock
```

At the beginning of our program we added a `Grab lock` instruction. This instruction will try to grab the lock. If the lock is already grabbed by another thread, it will wait until it's free again. If it successfully grabs the lock, it will keep executing. When the thread is done doing the work, it relases the lock so other threads can continue executing.

Using locks comes with its own set of challenges and possible problems. If we forget to release the lock no other thread will ever be able to execute.

Let's see what happens now that we have a lock:

| Time | Running process    | Value in memory | Note                                                    |
| ---- | ------------------ | --------------- | ------------------------------------------------------- |
| 0s   | T1 (grab lock)     | 0               |                                                         |
| 1s   | T1 (a = 0)         | 0               |                                                         |
| 2s   | T1 (a = a + 1)     | 0               |                                                         |
| 3s   | T2 (grab lock)     | 0               | T2 fails to grab the lock because it's being used by T1 |
| 4s   | T1 (a = 1)         | 1               |                                                         |
| 5s   | T1 (realease lock) | 1               |                                                         |
| 6s   | T2 (a = 1)         | 1               | Since T1 relased the lock, T2 can continue executing    |
| 7s   | T2 (a = a + 1)     | 1               |                                                         |
| 8s   | T2 (a = 2)         | 2               |                                                         |
| 9s   | T2 (realease lock) | 2               |                                                         |

This time we get the expected result: `2`

## How locks work

It seems like a lock solves our problem, but what prevents data races to happen when grabbing the lock? To understand this we need to get a little closer the operating system and eventually the hardware.

Most implementations of locks rely on [semaphores](https://en.wikipedia.org/wiki/Semaphore_(programming)), more specifically, binary semaphores.

A binary semaphore holds a variable that can be set to `0` or `1`. `1` means there is one slot available to be grabbed and `0` means the semaphore is already in use. The value of this variable can only be modified by using two functions:

- `wait` - Waits for the semaphore value to be set to `1`. Once the value is set to `1`, it will set it to `0`.
- `signal` - Changes the value of the semaphore from `0` to `1`.

These functions make it possible to create a lock, but the question remains. How does the semaphore ensure two threads calling `wait` at the same time don't see the semaphore as available?

The key to this issue resides on the hardware itself. Most modern CPUs have an instruction called `test-and-set`. This instruction `atomically` checks that a memory address is set to an expected value and sets that value to something else.

The `atomicity` of this operation is the important part. The CPU guarantees that while `test-and-set` is being executed the memory address can't be accessed by anybody else. How the CPU does this depends on the architecture of the CPU itself.

Once we have this operation, we can call `testAndSet(1, 0)` in a loop until it succeeds.

## Conclusion

There is a lot to be said about concurrency in computer systems, and this article is far from covering it all.

We now know a little more about how computers handle concurrency and how it can be problematic in some scenarios. We also explored a mechanism we can use to prevent one of the most common problems when writing concurrent software.

To have a strong foundation we got close to the hardware to understand how data races are avoided at this level.
