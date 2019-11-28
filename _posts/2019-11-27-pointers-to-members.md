---
title: Pointers to members in C++
author: adrian.ancona
layout: post
date: 2019-11-27
permalink: /2019/11/pointers-to-members-in-cpp/
tags:
  - programming
  - c++
---

A few days ago I was looking at some code and I found something I didn't understand. It looked something like this:

```cpp
void someFunction(int SomeClass::*value) {
  ...
```

I had never seen and `*` used after `::`, so I had to do some research to find what that means. It turns out that is a pointer to a class member. In this post I'm going to explain how these work and when they might be useful.

## Pointers to members

Pointers to members are pretty uncommon, so it will be very rarely that you will need to use them.

<!--more-->

Let's see how we can create a pointer to a member:

```cpp
#include <iostream>

class SomeClass {
 public:
  int someField;
};

int main() {
  // Create a pointer to member
  int SomeClass::*thePointer = &SomeClass::someField;

  // Create an object of type SomeClass
  SomeClass object;
  object.someField = 5;

  // Use a member of SomeClass using a pointer to member
  std::cout << object.*thePointer << std::endl;
}
```

The example above is a contrived example to illustrate the use of pointers to members. Running it will print `5` to the console.

Let's look at the declaration of the pointer to member:

```cpp
int SomeClass::*thePointer = &SomeClass::someField;
```

This can be further split in two parts:

```cpp
// Declares a pointer named `thePointer`.
// It points to a member of SomeClass.
// The member must be an int
int SomeClass::*thePointer;

// Make thePointer point to a specific member of SomeClass.
// In this case `someField`
thePointer = &SomeClass::someField;
```

The next section creates an object. And assigns 5 to `someField`. I don't think this requires explanation:

```cpp
SomeClass object;
object.someField = 5;
```

Lastly, we use the pointer we created to access the member of the object:

```cpp
std::cout << object.*thePointer << std::endl;
```

As is usual, to access a member of an object, we use a dot (`.`). The difference is that after the dot we use `*` to signal the compiler that what follows is a pointer to a member. Since `thePointer` points to `&SomeClass::someField`, the result is the same as if `object.someField` was used.

As you can probably imagine, we can change where the pointer points to:

```cpp
#include <iostream>

class SomeClass {
 public:
  int someField;
  int anotherField;
};

int main() {
  // Create a pointer to member
  int SomeClass::*thePointer;

  // Create an object of type SomeClass
  SomeClass object;
  object.someField = 5;
  object.anotherField = 6;

  // Print someField
  thePointer = &SomeClass::someField;
  std::cout << object.*thePointer << std::endl;

  // Print anotherField
  thePointer = &SomeClass::anotherField;
  std::cout << object.*thePointer << std::endl;
}
```

The output is:

```
5
6
```

## When to use pointers to members

I suggest not using them unless they are strictly necessary. They are a somewhat obscure feature and a lot of people might not know how they work.

It's a little hard to show examples where this feature is used, but I'll try.

Let's imagine we have a `Shape` class that describes the dimensions of the shape:

```cpp
struct Shape {
  int height;
  int width;
  int depth;
};
```

Let's say we have a bunch of these shapes:

```cpp
std::vector<Shape> shapes = {
  {5, 2, 2},
  {9, 2, 7},
  {3, 3, 1},
  {7, 4, 2}
};
```

We want to know a few things about these shapes:

- If we put them on top of each other, how high would the new shape be?
- If we put them next to each other how long would it go?
- If we put them in a line, how deep would it be?

A simple way to achieve this is to create 3 functions:

```cpp
int getHeight(const std::vector<Shape>& shapes) {
  int total = 0;
  for (const auto& shape : shapes) {
    total += shape.height;
  }

  return total;
}

int getWidth(const std::vector<Shape>& shapes) {
  int total = 0;
  for (const auto& shape : shapes) {
    total += shape.width;
  }

  return total;
}

int getDepth(const std::vector<Shape>& shapes) {
  int total = 0;
  for (const auto& shape : shapes) {
    total += shape.depth;
  }

  return total;
}
```

That's one way to solve the problem, but those 3 functions look very similar. Using a pointer to member we could reduce the duplicated code:

```cpp
int getDimensionSum(const std::vector<Shape>& shapes, const int Shape::*field) {
  int total = 0;
  for (const auto& shape : shapes) {
    total += shape.*field;
  }

  return total;
}
```

We can then use the new function like this:


```cpp
int main() {
  std::vector<Shape> shapes = {
    {5, 2, 2},
    {9, 2, 7},
    {3, 3, 1},
    {7, 4, 2}
  };

  std::cout << "Height: " << getDimensionSum(shapes, &Shape::height) << std::endl;
  std::cout << "Width: " << getDimensionSum(shapes, &Shape::width) << std::endl;
  std::cout << "Depth: " << getDimensionSum(shapes, &Shape::depth) << std::endl;
}
```

# Conclusion

Hopefully my example is clear enough that you can imagine yourself using pointers to members. That being said, keep in mind that a lot of people are not familiar with this feature, so I recommend avoiding it if possible.
