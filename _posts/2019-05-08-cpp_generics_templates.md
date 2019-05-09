---
title: C++ Generics / Templates
author: adrian.ancona
layout: post
date: 2019-05-08
permalink: /2019/08/cpp_generics_templates/
tags:
  - c++
  - programming
---

A while ago I discovered [generics in Java](/2014/06/java-generics/). Today, I'm going to explore how to do the same with C++.

Generics in C++ are known as templates. We use the keyword `template` to tell the compiler that we are about to define one:

```cpp
template <typename T>
class Hello {};
```

In the example above, you can also see that `typename` is used to define the type. You might also see the keyword `class` used interchangeably (There are some scenarios where they are not interchangeable, but I'm not going to cover those in this article):

```cpp
template <class T>
class Hello {};
```

<!--more-->

I'll use `typename` in my examples, so it isn't confused with a class definition.

## Simple example

A very simple example of a template could be used to store an instance of a type:

```cpp
template <typename T>
class OneElement {
 public:
  void set(T element) {
    element_ = element;
  }

  T get() {
    return element_;
  }

 private:
  T element_;
};
```

The template could be used like this:

```cpp
int main() {
  OneElement<int> myElement;
  myElement.set(5);

  std::cout << "The element has: " << myElement.get();
}
```

## Multiple types

You can use more than a single type in a template, you just need to use different names for each type:

```cpp
template <typename A, typename B>
class TwoElements {
 public:
  void setFirst(A first) {
    first_ = first;
  }

  void setSecond(B second) {
    second_ = second;
  }

  A getFirst() {
    return first_;
  }

  B getSecond() {
    return second_;
  }

 private:
  A first_;
  B second_;
};
```

And can be used like this:

```cpp
int main() {
  TwoElements<int, std::string> myElements;
  myElements.setFirst(3);
  myElements.setSecond("Tacos");

  std::cout << "I ate " << myElements.getFirst() << " "
            << myElements.getSecond() << std::endl;
}
```

## Conclusion

Creating simple templates is not very complicated. We just need to tell the compiler we want to create a template and name the types we are going to use. Templates can become pretty complicated in some occasions, but I'll not cover those scenarios here.
