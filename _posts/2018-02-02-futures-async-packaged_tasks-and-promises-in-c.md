---
id: 4906
title: Futures, async, packaged_tasks and promises in C++
date: 2018-02-02T06:01:29+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4906
permalink: /2018/02/futures-async-packaged_tasks-and-promises-in-c/
tags:
  - c++
  - design_patterns
  - programming
---
If you are unfamiliar with threads in C++ I recommend you take a look at [my article about threads](https://ncona.com/2018/01/introduction-to-c-threads/) before reading this one.

## Futures

Futures are a concept of concurrent programming. A future is a way to access a result from an asynchronous operation. As a simple example:

```cpp
std::future<int> fut = functionThatReturnsFuture();
int val = fut.get();
```

The code above should be very easy to read. We execute a function and it returns a future. Then we use this future to get a value. The interesting thing about this code is that _functionThatReturnsFuture_ can be (and most likely is) an asynchronous operation. When we call _fut.get()_, our code will wait for that asynchronous operation to complete. When the operation completes, it will return an int value that will then be assigned to val.

<!--more-->

This allows us to write code that does things in parallel in a pretty readable way:

```cpp
std::future<int> fut = doSomething();
std::future<int> fut2 = doSomethingElse();
std::future<int> fut3 = oneMoreThing();

int val = fut.get();
int val2 = fut2.get();
int val3 = fut3.get();
```

The code above is executing three functions concurrently. We can then use get() to wait for all the values and use them as we wish.

## Async

Async executes a function asynchronously and returns a future. The future can then be used to get the result of executing that function. Let&#8217;s see it in action:

```cpp
#include <iostream>
#include <future>

int addNumbers(int a, int b) {
  return a + b;
}

int main() {
  std::cout << "Start of the program\n";
  auto fut = std::async(addNumbers, 1, 2);
  std::cout << "Calculating the sum asynchronously\n";
  std::cout << "The result is: " << fut.get() << "\n";
  std::cout << "End of the program\n";
}
```

The output:

```
Start of the program
Calculating the sum asynchronously
The result is: 3
End of the program
```

In the example above, we use _std::async_ to get a future. When we need the result, we just call _get()_ on the future and use it.

## Packaged tasks

packaged_task provides a little more control over the execution of a function. Lets look at an example:

```cpp
#include <iostream>
#include <future>

int addNumbers(int a, int b) {
  return a + b;
}

int main() {
  std::cout << "Start of the program\n";
  std::packaged_task<int(int, int)> pt(addNumbers);
  std::cout << "Created the packaged_task\n";

  std::future<int> fut = pt.get_future();
  std::cout << "Got the future, but haven't executed the task\n";

  std::thread t(std::move(pt), 1, 2);
  t.join();
  std::cout << "Started the task in a thread\n";

  std::cout << "The result is: " << fut.get() << "\n";

  std::cout << "End of the program\n";
}
```

The output:

```
Start of the program
Created the packaged_task
Got the future, but haven't executed the task
Started the task in a thread
The result is: 3
End of the program
```

The example above achieves the same as the async example, but in a few more steps. This is useful mostly when you need to specify exactly in which thread you want the task to run. If you don&#8217;t need this freedom, you can use async for simplicity.

## Promises

Promises provide one more level of control over how values are shared between threads. For both async and packaged_task, the returned value of the function being executed was the value we acquired from the future. Promises give us the freedom to set the promise value whenever and however we need. Lets see the same example using a promise:

```cpp
#include <iostream>
#include <future>

void addNumbers(int a, int b, std::promise<int> p) {
  p.set_value(a + b);
}

int main() {
  std::cout << "Start of the program\n";
  std::promise<int> pr;
  std::cout << "Created the promise\n";

  std::future<int> fut = pr.get_future();
  std::cout << "Got the future\n";

  std::thread t(addNumbers, 1, 2, std::move(pr));
  t.join();
  std::cout << "Executing in thread\n";

  std::cout << "The result is: " << fut.get() << "\n";

  std::cout << "End of the program\n";
}
```

The output:

```
Start of the program
Created the promise
Got the future
Executing in thread
The result is: 3
End of the program
```

The example above is very similar to the one for packaged_task. The difference is that instead of the value of the future being set from the return value of the function, the function specifically sets the value.

## Conclusion

In this article I quickly showed three different ways of passing information between threads. Async being the simplest one and promises being the most flexible one. You should whenever possible use the simplest tool but keep the other options in mind if you have more advanced needs.
