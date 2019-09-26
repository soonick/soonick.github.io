---
title: Inheritance in C++
author: adrian.ancona
layout: post
date: 2019-09-25
permalink: /2019/09/inheritance-in-cpp/
tags:
  - programming
  - c++
---

Inheritance is a feature of Object Oriented Programming that allows programmers to create classes based on other classes. A class that inherits from another class will have the same behavior as the parent class unless it is overwritten.

Let's say we have a class:

```cpp
class Greeter {
 public:
  void talk() {
    std::cout << greeting_ << std::endl;
  }

 protected:
  std::string greeting_ = "hello";
};
```

<!--more-->

If an object of this class is created and the `talk()` method is called, `hello` will be printed.

We can now create a child class based on `Greeter`:

```cpp
class SpanishGreeter : public Greeter {
 public:
  SpanishGreeter() {
    greeting_ = "hola";
  }
};
```

Above, we can see that to inherit from a class, we use the format:

```cpp
class class-name : access-specifier parent-class {
```

`SpanishGreeter` inherits from `Greeter`. This means that it has the same methods and properties as `Greeter`. The only difference between these classes is that `SpanishGreeter`'s greeting is `hola` instead of `hello`. This means that calling `talk()` on `SpanishGreeter` will print `hola`.

In its simplest form, this is inheritance in C++.

## Access scope

If you are not familiar with access scopes, this is a good time to get to know them. In `Greeter` you can see the keywords `public` and `proteted` being used:

```cpp
class Greeter {
 public:
  void talk() {
    std::cout << greeting_ << std::endl;
  }

 protected:
  std::string greeting_ = "hello";
};
```

There are 3 access modifiers: `public`, `protected` and `private`. In general, one rule I like to follow is: `Everything should be private unless it can't`. So, the important thing is to find when something can't be private.

Here is a short description for each of them:

- `private` - Can only be seen by the class
- `protected` - Can be seen by the class and children classes
- `public` - Can be seen by anyone

Looking at `Greeter`, we decided to make `talk()` public, because that method could be called from any code that instantiates the class. The `greeting_` property, on the other hand is an implementation detail that doesn't need to be known by callers. Making `greeting_` protected makes it possible to overwrite its value on children classes; If it was private it wouldn't be possible to modify it from `SpanishGreeter`.

## Object construction

The constructor for the highest class in the hierarchy is executed first. For the example above, the constructor for `Greeter` is executed and then constructor for `SpanishGreeter`. This allows children classes to overwrite things in their constructor without those changes being reverted by the parent class.

## Access specifier

I already showed the way to have a class inherit from another class, but I didn't explain the access-specifier part:

```cpp
class class-name : access-specifier parent-class {
```

Although `public` inheritance is the most common, it's good to understand what the other inheritance types are:

- `public` - public and protected methods and properties of the parent class, become public and protected for the child class respectively.
- `protected` - public and protected methods and properties of the parent class, become protected for the child class.
- `private` - public and `protected` methods and properties of the parent class, become private for the child class.

I haven't really seen `protected` or `private` used on the wild, but they are there in case they are needed.
