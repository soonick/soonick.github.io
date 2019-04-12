---
title: Using Condition Variables in C++
author: adrian.ancona
layout: post
date: 2019-04-10
permalink: /2019/04/using-condition-variables-in-cpp/
tags:
  - c++
  - programming
---


In a previous article, I showed how to use [mutexes](/2018/08/mutexes-in-c/) to prevent race conditions. Condition Variables use mutexes to allow exclusive access to data, but also allow threads to wait for something to happen before they start to do work.

Understanding when Condition Variables are useful is easier with an example. Let's say we are building a queue system. To keep it simple we will start with 1 producer and 1 consumer. We can make this system safe with a mutex:

<!--more-->

```cpp
#include <queue>
#include <thread>
#include <iostream>
#include <mutex>

std::queue<int> dataQueue;
std::mutex queueMutex;

void producerFunction() {
  // This function will keep generating data forever
  int sleepSeconds;
  int newNumber;
  while (true) {
    // Wait from 1 to 3 seconds before generating data
    sleepSeconds = rand() % 3 + 1;
    std::this_thread::sleep_for(std::chrono::seconds(sleepSeconds));

    // Add a number to the queue
    newNumber = rand() % 100 + 1; // Random number from 1 to 100
    std::lock_guard<std::mutex> g(queueMutex);
    dataQueue.push(newNumber);

    std::cout << "Added number to queue: " << newNumber << std::endl;
  }
}

void consumerFunction() {
  // This function will consume data forever
  while (true) {
    int numberToProcess = 0;

    // We only need to lock the mutex for the time it takes us to pop an item
    // out. Adding this scope releases the lock right after we poped the item
    {
      std::lock_guard<std::mutex> g(queueMutex);
      if (!dataQueue.empty()) {
        numberToProcess = dataQueue.front();
        dataQueue.pop();
      }
    }

    // Only process if there are numbers
    if (numberToProcess) {
      std::cout << "Processing number: " << numberToProcess << std::endl;
    }
  }
}

int main() {
  std::thread producer(producerFunction);
  std::thread consumer1(consumerFunction);

  producer.join();
  consumer1.join();
}
```

This is the output of a sample run:

```bash
Added number to queue: 87
Processing number: 87
Added number to queue: 16
Processing number: 16
Added number to queue: 36
Processing number: 36
Added number to queue: 93
Processing number: 93
```

Because the producer adds at most 1 element to the queue every second, the consumer can process elements right away. The code is technically correct, but it has one issue that makes it not something we want to use in production. Let's take a closer look at the consumer loop:

```cpp
// This function will consume data forever
while (true) {
  int numberToProcess = 0;

  // We only need to lock the mutex for the time it takes us to pop an item
  // out. Adding this scope releases the lock right after we poped the item
  {
    std::lock_guard<std::mutex> g(queueMutex);
    if (dataQueue.size()) {
      numberToProcess = dataQueue.front();
      dataQueue.pop();
    }
  }

  // Only process if there are numbers
  if (numberToProcess) {
    std::cout << "Processing number: " << numberToProcess << std::endl;
  }
}
```

This loop runs forever, but, what happens when there is no data to consume? Even when there is no data to consume, the loop will keep executing repeatedly. The code will keep locking and unlocking the mutex wasting CPU cycles by doing this. A better approach would be to just wait for data to be present, so CPU is not wasted. Let's look at how to do this with Condition Variables:

```cpp
#include <queue>
#include <thread>
#include <iostream>
#include <mutex>
#include <condition_variable>

std::queue<int> dataQueue;
std::mutex queueMutex;
std::condition_variable queueConditionVariable;

void producerFunction() {
  // This function will keep generating data forever
  int sleepSeconds;
  int newNumber;
  while (true) {
    // Wait from 1 to 3 seconds before generating data
    sleepSeconds = rand() % 3 + 1;
    std::this_thread::sleep_for(std::chrono::seconds(sleepSeconds));

    // Add a number to the queue
    newNumber = rand() % 100 + 1; // Random number from 1 to 100
    std::lock_guard<std::mutex> g(queueMutex);
    dataQueue.push(newNumber);

    std::cout << "Added number to queue: " << newNumber << std::endl;

    // Notify one thread that the condition variable might have changed. Notice
    // the notification is sent while still holding the lock
    queueConditionVariable.notify_one();
  }
}

void consumerFunction() {
  // This function will consume data forever
  while (true) {
    int numberToProcess = 0;

    // We only need to lock the mutex for the time it takes us to pop an item
    // out. Adding this scope releases the lock right after we poped the item
    {
      // Condition variables need a unique_lock instead of a lock_guard because
      // the mutex might be locked and unlocked multiple times. Creating the
      // unique_lock like this, locks the mutex
      std::unique_lock<std::mutex> g(queueMutex);

      // This call to `wait` will first check if the contion is met. i.e. If
      // the queue is not empty.
      // If the queue is not empty, the execution of the code will continue
      // If the queue is empty, it will unlock the mutex and wait until a signal
      // is sent to the condition variable. When the signal is sent, it will
      // acquire the lock and check the condition again.
      queueConditionVariable.wait(g, []{ return !dataQueue.empty(); });

      // We don't need to check if the queue is empty anymore, because the
      // Condition Variable does that for us
      numberToProcess = dataQueue.front();
      dataQueue.pop();
    }

    // Only process if there are numbers
    if (numberToProcess) {
      std::cout << "Processing number: " << numberToProcess << std::endl;
    }
  }
}

int main() {
  std::thread producer(producerFunction);
  std::thread consumer1(consumerFunction);

  producer.join();
  consumer1.join();
}
```

I added comments to explain the changes. The code works the same way, but CPU is not being wasted on this version.

On the example above, the producer is slow and the consumer is fast, so the call to `wait` will always result in the consumer thread waiting. This also means that there will always be at most one item in the queue.

Even if there was more than one element in the queue, the consumer would still consume them as fast as possible. This is true, because the call to `wait` will first check the condition, and if it's true, it will start consuming right away, without waiting to be notified. This can be seen with an example:

```cpp
#include <queue>
#include <thread>
#include <iostream>
#include <mutex>
#include <condition_variable>

std::queue<int> dataQueue;
std::mutex queueMutex;
std::condition_variable queueConditionVariable;

void producerFunction() {
  // This function will keep generating data forever
  int sleepSeconds;
  int newNumber;
  int otherNumber;
  while (true) {
    // Wait from 1 to 3 seconds before generating data
    sleepSeconds = rand() % 3 + 1;
    std::this_thread::sleep_for(std::chrono::seconds(sleepSeconds));

    // Add a number to the queue
    newNumber = rand() % 100 + 1; // Random number from 1 to 100
    otherNumber = rand() % 100 + 1; // Random number from 1 to 100
    std::lock_guard<std::mutex> g(queueMutex);
    dataQueue.push(newNumber);
    dataQueue.push(otherNumber);

    std::cout << "Added numbers to queue: " << newNumber << ", " << otherNumber
              << std::endl;

    // Notify one thread that the condition variable might have changed
    queueConditionVariable.notify_one();
  }
}

void consumerFunction() {
  // This function will consume data forever
  while (true) {
    int numberToProcess = 0;

    // We only need to lock the mutex for the time it takes us to pop an item
    // out. Adding this scope releases the lock right after we poped the item
    {
      // Condition variables need a unique_lock instead of a lock_guard, because
      // the mutex might be locked and unlocked multiple times. By default, this
      // line will lock the mutex
      std::unique_lock<std::mutex> g(queueMutex);

      // This call to `wait` will first check if the contion is met. i.e. If
      // the queue is not empty.
      // If the queue is not empty, the execution of the code will continue
      // If the queue is empty, it will unlock the mutex and wait until a signal
      // is sent to the condition variable. When the signal is sent, it will
      // acquire the lock and check the condition again.
      queueConditionVariable.wait(g, []{ return !dataQueue.empty(); });

      // We don't need to check if the queue is empty anymore, because the
      // Condition Variable does that for us
      numberToProcess = dataQueue.front();
      dataQueue.pop();
    }

    // Only process if there are numbers
    if (numberToProcess) {
      std::cout << "Processing number: " << numberToProcess << std::endl;
    }
  }
}

int main() {
  std::thread producer(producerFunction);
  std::thread consumer1(consumerFunction);

  producer.join();
  consumer1.join();
}
```

This time, the producer adds 2 numbers intead of 1. Regardless, we can see in the output that the queue is quickly consumed by our consumer thread:

```bash
Added numbers to queue: 87, 78
Processing number: 87
Processing number: 78
Added numbers to queue: 94, 36
Processing number: 94
Processing number: 36
Added numbers to queue: 93, 50
Processing number: 93
Processing number: 50
```
