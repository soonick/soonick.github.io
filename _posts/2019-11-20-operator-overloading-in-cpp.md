---
title: Operator overloading in C++
author: adrian.ancona
layout: post
date: 2019-11-20
permalink: /2019/11/operator-overloading-in-cpp/
tags:
  - programming
  - c++
---

Operators are a fundamental part of programming languages. They allow us to perform operations on `operands` by using a symbol. If you have ever written code, you probably know what this snippet does:

```cpp
int a = 3 + 1;
```

Variable `a` will be initialized to 4. It is initialized to this value, because the `+` operator has been used to add the values of 3 and 1. The `=` sign, is also an operator that assigns the value of the addition to the variable `a`.

We use these operators without thinking too much about them, but they are just symbols that perform a certain action, like any function we could define.

It turns out we can override the behavior of an existing operator. That's what this article will focus on.

<!--more-->

## Overloading operators

The language doesn't allow us to overload operators for primitive types, so we can't make `3 + 1` give a different value. This is a good thing, because everybody would be very confused if they saw `3 + 1` is not `4`.

What we can do is define operators for our own custom types. Let's look at an example:

```cpp
#include <iostream>

class Counter {
 public:
  Counter operator+(const Counter& other) {
    Counter result;
    result.value = value + other.value;
    return result;
  }

  int value = 0;
};

int main() {
  Counter one;
  one.value = 1;
  Counter two;
  two.value = 2;

  std::cout << (one + two).value << std::endl;
}
```

Running this code will print `3` to the console. Let's take a closer look at `operator+` function:

```cpp
Counter operator+(const Counter& other) {
  Counter result;
  result.value = value + other.value;
  return result;
}
```

To begin, we need to look at this as any other function. The return type is `Counter` and it takes a single argument of `Counter` type. The name of the function is `operator+`.

One way to overload an operator is to create a member function on a class and add a method prefixed with `operator` and then the operator we want to overload. Even though `+` is a binary operator, it takes a single argument. In the example above we are calling `one + two`. This is equivalent to calling `one.operator+(two)`.

The body of the function is very simple. It creates a new `Counter` and initializes its value to the sum of `one` and `two`.

The same code can be rewritten using an external function:

```cpp
#include <iostream>

class Counter {
 public:
  int value = 0;
};

Counter operator+(const Counter& lhs, const Counter& rhs) {
  Counter result;
  result.value = lhs.value + rhs.value;
  return result;
}

int main() {
  Counter one;
  one.value = 1;
  Counter two;
  two.value = 2;

  std::cout << (one + two).value << std::endl;
}
```

This is useful when the class has already been defined, but we still want to overload an operator for it.

We can also overload unary operators like `++`:

```cpp
#include <iostream>

class Counter {
 public:
  void operator++() {
    value++;
  }

  int value = 0;
};

int main() {
  Counter c;
  std::cout << c.value << std::endl;
  ++c;
  std::cout << c.value << std::endl;
}
```

This code will print `0` and `1` to the console.

One interesting thing about the previous example is that `++c` works, but `c++` doesn't. To define the postfix version we need to have our function accept an `int`:

```cpp
void operator++(int) {
  value++;
}
```

I'm not sure what's the reason for this, but it allows for different implementations of the prefix and postfix versions if desired.

The last operator I want to show is the `[]` operator. This is often used by container types (like `vector`):

```cpp
#include <iostream>

class Counter {
 public:
  int operator[](int index) {
    return squares[index];
  }

 private:
  int squares[3] = {1, 4, 9};
};

int main() {
  Counter c;
  std::cout << c[1] << std::endl;
}
```

The function `operator[]` get's called when we try to perform an array-like access to our custom object. In this example, the function only supports receiving an int, but we could potentially accept any type.

## Conclusion

As you can see, overloading operators is not very complicated. Nevertheless, this functionality should be used with care. If we are going to overload an operator we should make an effort to make obvious what the operator will do for our custom type. In a lot of cases it is a lot clearer to just create a member function and call that function instead.
