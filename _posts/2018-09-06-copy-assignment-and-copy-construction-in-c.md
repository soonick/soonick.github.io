---
id: 5275
title: Copy assignment and copy construction in C++
date: 2018-09-06T06:12:39+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=5275
permalink: /2018/09/copy-assignment-and-copy-construction-in-c/
tags:
  - c++
  - programming
---
If you have written C++, you have most likely already used copy-assignment. Variables are copy assigned by using the equal sign:

```cpp
#include <iostream>

int main() {
  std::string first = "tacos";
  std::string second;

  second = first;

  std::cout << &first << std::endl;
  std::cout << &second << std::endl;
}
```

One of the outputs from the program above is:

```
0x7ffc36841b70
0x7ffc36841b90
```

<!--more-->

This shows that _second_ points to a different address than _first_. What happened here is that the copy-assignment operation for _std::string_ was called when the program executed:

```
second = first;
```

The copy-assignment operation for a string allocates a memory address the same size of the string being copied, and copies the contents of the first string into the second.

Even though most scenarios might be straight forward, there are some scenarios that could lead to problems. Lets say we have this program:

```cpp
#include <iostream>

class Container {
 public:
  Container() {
    number = new int(0);
  }

  void setNumber(int value) {
   *number = value;
  }

  int getNumber() {
    return *number;
  }

 private:
  int* number;
};

int main() {
  Container first;
  first.setNumber(5);

  Container second;
  second = first;
  second.setNumber(2);

  std::cout << first.getNumber() << std::endl;
  std::cout << second.getNumber() << std::endl;
}
```

What should be the output in this case? Is a new pointer created with a copy of the value, or is the pointer copied and points to the original address? In this case the output is:

```
2
2
```

The pointer is copied but the address the pointer references is the same. This is the default behavior, but the correctness depends on what the object is used for.

## Custom copy assignment functionality

Because it is possible that the intended behavior is different than the default, C++ allows developers to define their own behavior. To do this the class needs to implement the _operator=_ function. Lets implement ours so a new address is allocated on copy instead of using the same one:

```cpp
#include <iostream>

class Container {
 public:
  Container() {
    number = new int(0);
  }

  // Other is the element on the right hand of the equal sign
  Container& operator=(const Container& other) {
    // Allocate a new number
    number = new int(0);

    // This is the element on the left sign of the equal sign.
    // It is a convention to return *this on this function
    return *this;
  }

  void setNumber(int value) {
    *number = value;
  }

  int getNumber() {
    return *number;
  }

 private:
  int* number;
};

int main() {
  Container first;
  first.setNumber(5);

  Container second;
  second = first;
  second.setNumber(2);

  std::cout << first.getNumber() << std::endl;
  std::cout << second.getNumber() << std::endl;
}
```

This new version will create a new pointer instead of reusing the one from the element at the right side of the equal sign. The output is:

```
5
2
```

There is problem with the implementation above. Consider what would happen if you assign a variable to itself:

```cpp
#include <iostream>

class Container {
 public:
  Container() {
    number = new int(0);
  }

  // Other is the element on the right hand of the equal sign
  Container& operator=(const Container& other) {
    // Allocate a new number
    number = new int(0);

    // This is the element on the left sign of the equal sign
    return *this;
  }

  void setNumber(int value) {
   *number = value;
  }

  int getNumber() {
    return *number;
  }

 private:
  int* number;
};

int main() {
  Container first;
  first.setNumber(5);
  std::cout << first.getNumber() << std::endl;

  first = first;
  std::cout << first.getNumber() << std::endl;
}
```

This example gives the output:

```
5
0
```

As you can see, the value of first was changed and this shouldn&#8217;t have happened. In general it is a good practice to do nothing on self assignment. This can be easily fixed:

```cpp
#include <iostream>

class Container {
 public:
  Container() {
    number = new int(0);
  }

  // Other is the element on the right hand of the equal sign
  Container& operator=(const Container& other) {
    if (this == &other) return *this;

    // Allocate a new number
    number = new int(0);

    // This is the element on the left sign of the equal sign
    return *this;
  }

  void setNumber(int value) {
   *number = value;
  }

  int getNumber() {
    return *number;
  }

 private:
  int* number;
};

int main() {
  Container first;
  first.setNumber(5);
  std::cout << first.getNumber() << std::endl;

  first = first;
  std::cout << first.getNumber() << std::endl;
}
```

The result now is what you would expect:

```
5
5
```

## Copy constructor

You might have noticed that in the examples above I do this:

```cpp
  Container first;
  Container second;
  second = first;
```

instead of this:

```cpp
  Container first;
  Container second = first;
```

The reason I did this is because the first case is a copy assignment while the second is a copy construction. The difference is that in the first case you already have an object and you are replacing its content with another object. In the second case, a new object is being constructed with the contents of another object.

Here is our container with both a copy constructor and a copy assignment:

```cpp
#include <iostream>

class Container {
 public:
  Container() {
    number = new int(0);
  }

  // This takes care of the copy construction
  // Other is the element on the right hand of the equal sign
  Container(const Container& other) {
    number = new int(0);
  }

  // Other is the element on the right hand of the equal sign
  Container& operator=(const Container& other) {
    if (this == &other) return *this;

    // Allocate a new number
    number = new int(0);

    // This is the element on the left sign of the equal sign
    return *this;
  }

  void setNumber(int value) {
   *number = value;
  }

  int getNumber() {
    return *number;
  }

 private:
  int* number;
};

int main() {
  Container first;
  first.setNumber(1);
  Container second = first;
  second.setNumber(2);
  Container third;
  third.setNumber(3);

  std::cout << first.getNumber() << std::endl;
  std::cout << second.getNumber() << std::endl;
  std::cout << third.getNumber() << std::endl;
}
```

As you can see the copy construction is taken care by a constructor that receives a single argument of the same type. Self assignment is not possible in the constructor, so we don&#8217;t need to worry about that scenario.
