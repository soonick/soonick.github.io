---
title: Variable initialization in C++
author: adrian.ancona
layout: post
date: 2019-01-02
permalink: /2019/01/variable-initialization-in-cpp/
tags:
  - programming
  - c++
---


In a previous article I wrote a little about the [difference between declaration and definition](/2017/12/c-header-files/) of a variable. As a refresher, this is a declaration:

```cpp
int add(int a, int b);
```

This is a definition:

```cpp
int add(int a, int b) {
  return a + b;
}
```

A declaration is somehow incomplete until it is defined.

<!--more-->

## Initialization

An initialization is when you provide a value to a variable. In C++ there are many ways to initalize a variable. I'm going to try to explain some of them in this article.

There are three main ways of initalizing a variable:

```cpp
int main() {
  // Expression
  int a = 1;

  // Expression list
  int b(2);

  // Initializer list
  int c{3};
}
```

In the code above, three variables were initialized: a to 1, b to 2 and c to 3.

## Expression

The expression is the simplest way to initialize a variable. When this is done, the value on the right side of the equal sign is copied to the variable on the left side. If the compiler deems it possible, the initialization might be done at compile time.

## Expression list

An expression list can be used to initialize objects using their constructor, for example:

```cpp
#include <vector>

int main() {
  std::vector<int> vec(10, 5);
}
```

In the example above we are initializing the vector `vec` with a size of `10`, and all values set to `5`.

## Initializer list

Initializer lists were introduced in C++11 and are the newest way of initializing a variable. They use curly braces `{}` instead of parentheses `()`.

Initializer lists can be a little confusing because they can be used in a many ways. For example, you can initialize an int using an initializer list:

```cpp
int c{3};
```

The code above, initializes an `int` variable named `c`, with the value `3`.

Initializer lists can also be used to call constructors. For example:

```cpp
#include <iostream>

struct Hello {
  Hello(int v) : a(v) {}
  Hello(int v1, int v2) : a(v1), b(v2) {}

  int a;
  int b;
};

int main() {
  Hello hello{1};
  Hello hello2{1, 2};

  std::cout << hello.a << "-" << hello.b << std::endl;
  std::cout << hello2.a << "-" << hello2.b << std::endl;
}
```

The output is:

```
1-0
1-2
```

In the example above, the curly braces work exactly the same as if we had used parentheses. This can be a problem with a few clases, for example:

```cpp
int main() {
  std::vector<int> a(10, 5);
  std::vector<int> b{10, 5};

  std::cout << a.size() << "-" << a[1] << std::endl;
  std::cout << b.size() << "-" << b[1] << std::endl;
}
```

The output of this program is:

```
10-5
2-5
```

As you can see, the output is not the same. `a` is a vector of size `10` where all elements are `5`. `b` is a vector of size `2`; the first element is `10` and the second is `5`. So, how did that happen?

What happened here is that `std::vector` has a constructor that takes an initializer list, and if curly braces are used, this constructor will be used instead of the constructor that receives two elements. It's probably easier to see with an example:

```cpp
class IntContainer {
 public:
  IntContainer(std::initializer_list<int> list) {
    size = list.size();
    ints = new int[size];

    auto it = list.begin();
    for (int index = 0; index < size; ++index, ++it) {
      ints[index] = *it;
    }
  }

  IntContainer(int s, int v) {
    size = s;
    ints = new int[s];

    for (int index = 0; index < size; ++index) {
      ints[index] = v;
    }
  }

  void printValues() {
    std::cout << "Values:" << std::endl;
    for (int i = 0; i < size; ++i) {
      std::cout << "\t" << ints[i];
    }
    std::cout << std::endl;
  };

 private:
  int size;
  int *ints;
};

int main() {
  IntContainer cont1(10, 5);
  IntContainer cont2{10, 5};

  cont1.printValues();
  cont2.printValues();
}
```

The output of that program is:

```
Values:
	5	5	5	5	5	5	5	5	5	5
Values:
	10	5
```

Although this behavior might be a little confusing, it is useful to have constructors that take initializer lists for a container type like `vector`, so we can succinctly add multiple values to the container.

## Conclusion

Now that we know the different ways to initialize a variable in C++, it is good to keep in mind the behavior of initializer lists to not fall into the trap of expecting a constructor to be called, but we end up with a different behavior.
