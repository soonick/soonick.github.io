---
title: Concurrent data structures
author: adrian.ancona
layout: post
date: 2019-12-04
permalink: /2019/12/concurrent-data-structures/
tags:
  - programming
  - c++
---

A concurrent data structure, is a data structure (e.g. list, stack) that can be used by multiple threads concurently and it will always show a consistent state to each thread.

## Consistency

The definition above mentions that the data structure will always show a consistent state. To understand this, let's analyze a data structure that is not concurrent and can end in an inconsistent state.

Let's say we are building an application that draws a single rectangle. The dimensions of this rectangle can be modified by users around the world, they just need to visit a website and enter the new dimensions.

<!--more-->

Under the covers the rectangle is an instance of a `Rectangle` class, and all user requests result in a call to `setDimensions`:

```cpp
class Rectangle {
 private:
  int width;
  int height;

 public:
  void setDimensions(int w, int h) {
    width = w;
    height = h;
  }
}
```

If our program doesn't do anything to prevent multiple threads from accessing our rectangle, it could end in an inconsistent state if two requests are received at the same time.

```
User1: width=5, height=10
User2: width=2, height=2
```

A possible way this could go:

```
Time | Thread1 (User1)    |    Thread2 (User2)
  0  |  width = 5         |
  1  |                    |     width = 2
  2  |                    |     height = 2
  3  |  height = 10       |
```

The end result would be a rectangle with `width = 2` and `height = 10`, which matches none of the users' desired values. This is an inconsistent state.

## Mutexes

Inconsistency could be avoided by having the caller of `setDimensions(int w, int h)`, use a [mutex](/2018/08/mutexes-in-c/) to protect the rectangle. Something like this:

```cpp
void processRequest(int width, int height) {
  std::lock_guard<std::mutex> g(rectangleMutex);
  rectangle.setDimensions(width, height);
}
```

Even though this works, it is error prone. In the future developers might add a call to `rectangle.setDimensions` somewhere else in the code and forget to grab the mutex.

A better approach is to make rectangle thread-safe, so it is impossible to get it in an inconsistent state.

## Thread-safe Rectangle

We can easily make our data structure thread-safe just by moving the `mutex` inside the data structure:

```cpp
class Rectangle {
 private:
  int width;
  int height;
  std::mutex mutex;

 public:
  void setDimensions(int w, int h) {
    std::lock_guard<std::mutex> g(mutex);
    width = w;
    height = h;
  }
}
```

By doing this we make sure that all calls to `setDimensions` are safe. If we need to add more methods to our data structure we can follow a similar approach:

```cpp
class Rectangle {
 private:
  int width;
  int height;
  std::mutex mutex;

 public:
  void setDimensions(int w, int h) {
    std::lock_guard<std::mutex> g(mutex);
    width = w;
    height = h;
  }

  std::pair<int, int> getDimensions() {
    std::lock_guard<std::mutex> g(mutex);
    return {width, height};
  }
}
```

We need to lock the mutex even when we are only reading, or we could end up reading in the middle of a write and return an invalid value.

## Concurrency

Concurrency goes beyond thread-safety. In the example above we achieve thread-safety by making sure that only one thread is operating on our object at the same time. Building a concurrent data structure means looking for oportunities for doing things concurrently as well as safely.

One optimization that we can apply to `Rectangle` is allowing reads to happen at the same time. Because reads don't modify data, they can't get the object in an inconsistent state. We can easily achive this if we use a [`shared_mutex`](/2019/03/read-write-mutex-with-shared_mutex/) instead of a normal `mutex`:

```cpp
class Rectangle {
 private:
  int width;
  int height;
  std::shared_mutex mutex;

 public:
  void setDimensions(int w, int h) {
    std::lock_guard<std::shared_mutex> g(mutex);
    width = w;
    height = h;
  }

  std::pair<int, int> getDimensions() {
    std::shared_lock<std::shared_mutex> g(mutex);
    return {width, height};
  }
}
```

## Achieving concurrency

Creating a thread-safe data structure can be relatively simple if we lock the whole data structure every time a method is called. Creating a data structure that allows threads to actually perform useful work in parallel (instead of just waiting) can be a lot more complicated.

Here is a list of things to consider when building a concurrent data structure:

- Lock mutexes for the shortest time necessary
- Using multiple mutexes might help achieve greater concurrency
- Exceptions should not cause data inconsistency

Let's try to apply these principals to a data structure.

## A concurrent stack

A stack is very simple to implement if we don't care about thread-safety. Let's try to design a stack that is thread-safe and allows some degree of concurrency.

Our stack will expose 3 methods:
- push - Inserts an element at the top of the stack
- pop - Removes the element at the top of the stack and returns its value
- empty - Returns true if the stack is empty

We will implement our stack using a linked list. The linked list will start as a `nullptr`:

```cpp
ll -> nullptr
```

After pushing our first element, the new element will become the top of the stack and it will point to the previous top (nullptr):

```cpp
ll -> new_element -> nullptr
```

We can keep adding elements like this:

```cpp
ll -> newer_element -> new_element -> nullptr
```

Popping an element will return the element at the top of the stack and will make the next element the new top:

```cpp
returned: newer_element
ll -> new_element -> nullptr
```

The `empty` method will return true if the head is `nullptr`, otherwise it will return false.

Let's start with a simple implementation that is not thread-safe:

```cpp
template <typename T>
class Stack {
 public:
  void push(T in) {
    // `in` is a copy of the given argument, so this function has complete
    // ownership. That makes it safe to use std::move
    head_ = std::make_shared<Node>(std::move(in), head_);
  }

  T pop() {
    // Nothing to pop
    if (empty()) {
      throw StackEmpty();
    }

    auto ret = head_;
    head_ = ret->next;
    return std::move(ret->value);
  }

  bool empty() {
    return head_ == nullptr;
  }

 private:
  // The wrapper class
  class Node {
   public:
    Node(T v, std::shared_ptr<Node> n) {
      value = std::move(v);
      next = n;
    }

    T value;
    std::shared_ptr<Node> next;
  };

  class StackEmpty : public std::runtime_error {
   public:
    StackEmpty() : std::runtime_error("") {}
  };

  // shared_ptr, so we don't have to worry about allocating and deallocating
  // memory manually
  std::shared_ptr<Node> head_;
};
```

The `Stack` above implements the methods we need, but it's not thread-safe. Let's try to find problems that could come up if it was used by multiple threads.

The `empty` method is the simplest. The only thing it does is verify if the `head_` is `nullptr`. It is possible that someone pops an item at the same time `empty` is called, but since it doesn't modify any data it can't corrupt the data structure; It will always return either true or false. I think this method is safe.

The `push` method does modify data, so there is potential for data corruption. Although the example above is written on a single line, there are actually a few things going on:

- Move `in` (move constructor)
- Copy `head_` (copy constructor)
- Create a new `Node`
  - Set `value` to `in` (move constructor)
  - Set `next` to `n` (copy constructor)
- Set `head_` to the newly created node

Most of these steps could fail, and we have to make sure our data structure doesn't get in a bad state if they do. If we look at the steps from top to bottom, we can see that if something fails before `head_` is set to the new node, everything will be fine. For example, if we fail to create a node and throw an exception, the destructor will cleanup the new node and our data structure will not have changed.

The step of setting `head_` to the newly created node can't fail. If it fails it could leave `head_` pointing to some corrupted data, which is something we don't want. Luckily the only thing the program does in the last step is copy a shared_ptr, which can't fail, so we don't have to worry about exceptions.

One thing we need to keep in mind is what would happen if multiple threads call this method at the same time. If we have two threads create a new node at the same time, they will both set the `next` field to the current head. Then `head_` would be set to one of these values. This effectively means, one push would be lost. To prevent this from happening, we'll use a mutex.

Finally, the `pop` method, consists of a few steps too:

- Check if the stack is empty
- Copy `head_` to a variable named `ret`
- Set `head_` to `ret->next`
- Return `ret->value` (move)

If the stack is empty, we will simply throw an exception before doing any work. If the next step fails, our data structure is still valid. Then we set `head_` to a new value. This step involves a copy of a `shared_ptr`, which can't fail, so we don't have to worry about exceptions. On the other hand, we are modifying `head_`, which if done at the same time by multiple threads could lead to corrupted data, so we need to protect this with a mutex.

Lastly, we are calling the move constructor of `T`, which could potentially throw an exception. The good thing is that at this point our data structure is safe, so we don't need to worry about this.

Let's see this in code:

```cpp
template <typename T>
class Stack {
 public:
  void push(T in) {
    std::lock_guard<std::mutex> g(m);
    head_ = std::make_shared<Node>(std::move(in), head_);
  }

  T pop() {
    std::shared_ptr<Node> ret;

    // Create a scope so our lock_guard get's destroyed as soon as we don't
    // need it anymore
    {
      std::lock_guard<std::mutex> g(m);
      // Nothing to pop
      if (empty()) {
        throw StackEmpty();
      }

      ret = head_;
      head_ = ret->next;
    }

    return std::move(ret->value);
  }

  bool empty() {
    return head_ == nullptr;
  }

 private:
  class Node {
   public:
    Node(T v, std::shared_ptr<Node> n) {
      value = std::move(v);
      next = n;
    }

    T value;
    std::shared_ptr<Node> next;
  };

  class StackEmpty : public std::runtime_error {
   public:
    StackEmpty() : std::runtime_error("") {}
  };

  std::shared_ptr<Node> head_;

  std::mutex m;
};
```

On the `pop` method we need to hold the lock while we check if the stack is empty, otherwise we might see it as not empty but another thread might set it to nullptr.

If we look back at the principles I listed above:

- **Lock mutexes for the shortest time necessary** -  We are only locking the mutex when modyfing `head_`.
- **Multiple mutexes might help achieve greater concurrency** - There is a single variable we need to lock, so this doesn't apply.
- **Exceptions should not cause data inconsistency** - We went over our data structure step by step analzing what would happen if an exception was thrown in each step.

Both `push` and `pop` write to `head_`, so in this case it doesn't make sense to use a `shared_mutex`.

## Conclusion

A stack is one of the simplest examples for making a data structure concurrent. There are other examples that are harder to implement but can bring great performance gains to your application vs using a single lock for the whole data structure. There is a lot of content out there on this topic.
