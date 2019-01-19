---
title: Lock hierarchies to avoid deadlocks
author: adrian.ancona
layout: post
date: 2019-01-16
permalink: /2019/01/lock-hierarchies-to-avoid-deadlocks/
tags:
  - programming
  - c++
---

In a previous post I explained [how mutexes work](/2018/08/mutexes-in-c/) and the problem of race conditions.

In this post I introduce another common problem with mutexes, which is deadlocks. Deadlocks are situations when a program can't make any progress because it is waiting for a mutex that will never be available. This might sound stupid, but it's something that actually happens very often.

A naive example could be this:

```cpp
#include <thread>
#include <mutex>

std::mutex mutexA;
std::mutex mutexB;

void doSomething() {
  std::lock_guard<std::mutex> gA(mutexA);
  std::this_thread::sleep_for(std::chrono::seconds(1));
  std::lock_guard<std::mutex> gB(mutexB);
}

void doSomethingElse() {
  std::lock_guard<std::mutex> gB(mutexB);
  std::this_thread::sleep_for(std::chrono::seconds(1));
  std::lock_guard<std::mutex> gA(mutexA);
}

int main() {
  std::thread t1(doSomething);
  std::thread t2(doSomethingElse);

  t1.join();
  t2.join();
}
```

<!--more-->

The example above will cause a deadlock. If you take a close look, you will find that two threads are being started:

### t1

- Locks mutexA
- Waits for 1 second
- Locks mutexB

### t2

- Locks mutexB
- Waits for 1 second
- Locks mutexA

The reason the program deadlocks is that after 1 second has passed, `t1` will try to grab `mutexB`, but won't be able to do it, because it is being locked by `t2`. At the same time `t2` will try to grab `mutexA`, but will fail, because `t1` is holding that mutex. Both threads will wait forever for each other, so the program will never exit.

Although in this example, the problem is very obvious, when working on larger applications, it is not easy to spot problems like this.

## std::lock

One way to fix this problem is using `std::lock`:

```cpp
#include <thread>
#include <mutex>

std::mutex mutexA;
std::mutex mutexB;

void doSomething() {
  std::lock(mutexA, mutexB);
  std::lock_guard<std::mutex> gA(mutexA, std::adopt_lock);
  std::lock_guard<std::mutex> gB(mutexB, std::adopt_lock);
}

void doSomethingElse() {
  std::lock(mutexB, mutexA);
  std::lock_guard<std::mutex> gA(mutexA, std::adopt_lock);
  std::lock_guard<std::mutex> gB(mutexB, std::adopt_lock);
}

int main() {
  std::thread t1(doSomething);
  std::thread t2(doSomethingElse);

  t1.join();
  t2.join();
}
```

`std::lock` makes sure the mutexes are always locked in the same order (regardless of the order of the arguments), avoiding deadlocks this way. Even though we are using `std::lock` we still want to use `std::lock_guard` to make sure the mutexes are released at the end of the scope. The `std::adopt_lock` option allows us to use lock_guard on an already locked mutex.

This approach is very easy to implement when we are locking mutexes in the same function, but there are scenarios where this can't be done. For example:

```cpp
#include <thread>
#include <mutex>

std::mutex mutexA;
std::mutex mutexB;

void doSomethingWithMutexA() {
  std::lock_guard<std::mutex> gA(mutexA);
}

void doSomethingWithMutexB() {
  std::lock_guard<std::mutex> gB(mutexB);
}

void doSomething() {
  std::lock_guard<std::mutex> gA(mutexA);
  std::this_thread::sleep_for(std::chrono::seconds(1));
  doSomethingWithMutexB();
}

void doSomethingElse() {
  std::lock_guard<std::mutex> gB(mutexB);
  std::this_thread::sleep_for(std::chrono::seconds(1));
  doSomethingWithMutexA();
}

int main() {
  std::thread t1(doSomething);
  std::thread t2(doSomethingElse);

  t1.join();
  t2.join();
}
```

In this case doSomething locks `mutexA` and then calls a function that needs to lock `mutexB`. Since the locking happens in two different functions, we can't use `std::lock` in this scenario. Because there is another thread locking `mutexB` and then waiting for `mutexA`, the two threads block each other forever.

## Lock hierarchies

The issue shown above can, in some cases be mitigated by using lock hierarchies. A lock hierarchy consists of designing your application in a way that mutexes can only be locked in a specific order. This restriction might not be realistic for some applications, but in the cases where it applies, it helps us prevent deadlocks.

Before we start writing code, we can design a simple hierarchy for our application. In the example above, we have two mutexes. We can decide that we want `mutexA` to be lower in the hierarchy than `mutexB`.

The next step is to enforce this in code. The easiest way to do this is to create a mutex type that is aware of the hierarchy:

```cpp
class HierarchicalMutex {
  std::mutex theMutex;
  int level;
  int previousLevel;

  // A thread_local variable is a global variable in the current thread
  static thread_local int threadLevel;

  // Check if a mutex with a higher level has already been locked in this thread
  void isLockValid() {
    if (threadLevel >= level) {
      throw std::runtime_error("Higher level mutex already locked");
    }
  }

  // When locking a mutex, update the global value on the thread and save the
  // previousLevel, so we can restore it when the mutex in unlocked
  void updateLevels() {
    previousLevel = threadLevel;
    theadLevel = level;
  }

 public:
  // We use a explicit constructor, to force the user to set a level for the
  // mutex
  explicit HierarchicalMutex(int l) {
    level = l;
    previousLevel = 0;
  }

  // A user-defined mutex must implement `lock`, `unlock` and `try_lock`
  void lock() {
    isLockValid();
    theMutex.lock();
    updateLevels();
  }

  // Move thead level to the value of the mutex that was locked before
  void unlock() {
    threadLevel = previousLevel;
    theMutex.unlock();
  }

  // try_lock only locks the mutex if it is not currently locked. If it is locked
  // it returns false. If it is not locked, it locks the mutex and returns true
  bool try_lock() {
    isLockValid();

    if (!theMutex.try_lock()) {
      return false
    }

    updateLevels();
    return true;
  }
}
```

The class above will allow us to create a hierarchy of mutexes that will be enforced at runtime. To use it we have to define the levels in our hierarchy. We decided before, that we wanted `mutexA` to be lower than `mutexB`:

```cpp
HierarchicalMutex mutexA(1000);
HierarchicalMutex mutexB(10000);
```

The values `1000` and `10000` are arbitrary. It is usually a good idea to leave a gap between the mutex levels in case we want to add a mutex in the future, we don't have to update the levels in all mutexes.

Let's now rewrite our program using `HierarchicalMutex` and see what happens:

```cpp
#include <thread>
#include <mutex>

class HierarchicalMutex {
  std::mutex theMutex;
  int level;
  int previousLevel;

  // A thread_local variable is a global variable in the current thread
  static thread_local int threadLevel;

  // Check if a mutex with a higher level has already been locked in this thread
  void isLockValid() {
    if (threadLevel >= level) {
      throw std::runtime_error("Higher level mutex already locked");
    }
  }

  // When locking a mutex, update the global value on the thread and save the
  // previousLevel, so we can restore it when the mutex in unlocked
  void updateLevels() {
    previousLevel = threadLevel;
    threadLevel = level;
  }

 public:
  // We use a explicit constructor, to force the user to set a level for the
  // mutex
  explicit HierarchicalMutex(int l) {
    level = l;
    previousLevel = 0;
  }

  // A user-defined mutex must implement `lock`, `unlock` and `try_lock`
  void lock() {
    isLockValid();
    theMutex.lock();
    updateLevels();
  }

  // Move thead level to the value of the mutex that was locked before
  void unlock() {
    threadLevel = previousLevel;
    theMutex.unlock();
  }

  // try_lock only locks the mutex if it is not currently locked. If it is locked
  // it returns false. If it is not locked, it locks the mutex and returns true
  bool try_lock() {
    isLockValid();

    if (!theMutex.try_lock()) {
      return false;
    }

    updateLevels();
    return true;
  }
};

// Initialize thread level to 0
thread_local int HierarchicalMutex::threadLevel = 0;

HierarchicalMutex mutexA(1000);
HierarchicalMutex mutexB(10000);

void doSomethingWithMutexA() {
  std::lock_guard<HierarchicalMutex> gA(mutexA);
}

void doSomethingWithMutexB() {
  std::lock_guard<HierarchicalMutex> gB(mutexB);
}

void doSomething() {
  std::lock_guard<HierarchicalMutex> gA(mutexA);
  std::this_thread::sleep_for(std::chrono::seconds(1));
  doSomethingWithMutexB();
}

void doSomethingElse() {
  std::lock_guard<HierarchicalMutex> gB(mutexB);
  std::this_thread::sleep_for(std::chrono::seconds(1));
  doSomethingWithMutexA();
}

int main() {
  std::thread t1(doSomething);
  std::thread t2(doSomethingElse);

  t1.join();
  t2.join();
}
```

The output of this program is:

```
terminate called after throwing an instance of 'std::runtime_error'
  what():  Higher level mutex already locked
Aborted (core dumped)
```

This time, instead of having the program stuck forever, the program will notice the violation of the lock hierarchy and quit. In a more complicated program you would probably want to take a look at the `core` generated from the crash to figure out what code let to it. To actually solve the deadlock, we would need to redesign the program, so it doesn't violate the hierarchy.

## Conclusion

In this post I introduced two ways for avoiding deadlocks. There are many situations were these techniques won't apply, but where it is possible, this might save you from some headaches. I'll try to cover more concurrency techniques in future posts.
