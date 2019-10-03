---
title: Virtual functions in C++
author: adrian.ancona
layout: post
date: 2019-10-02
permalink: /2019/10/virtual-functions-in-cpp/
tags:
  - programming
  - c++
---

If you are not familiar with Inheritance, I recommend you read my [short article about inheritance](/2019/09/inheritance-in-cpp/) first.

One of the features of Object Oriented Programming is Polymorphism. Virtual functions in C++ allow developers to achieve run-time polymorphism by overwriting methods of a base class.

In my [article about inheritance](/2019/09/inheritance-in-cpp/), I showed how we can create classes that inherit from a base (or parent) class. Something similar to the following:

```cpp
class Greeter {
 public:
  void talk() {
    std::cout << "hello" << std::endl;
  }
};

class SpanishGreeter : public Greeter {
 public:
  void talk() {
    std::cout << "hola" << std::endl;
  }
};
```

<!--more-->

Polymorphism comes into play when a method receives an object as an argument, and we want this object to behave differently depending on what it is. This is easier to understand with an example.

Let's say we have a program that greets people in their native tongue. The program doesn't want to know how to greet in different languages. Instead, it uses a Greeter that knows how to correctly greet the user:

```cpp
#include <iostream>

class Greeter {
 public:
  void talk() {
    std::cout << "hello" << std::endl;
  }
};

class SpanishGreeter : public Greeter {
 public:
  void talk() {
    std::cout << "hola" << std::endl;
  }
};

class Program {
 public:
  Program(Greeter g) : greeter_(g) {};

  void run() {
    greeter_.talk();
  }

 private:
  Greeter greeter_;
};

int main() {
  Greeter englishGreeter;
  Program p(englishGreeter);
  p.run();
}
```

The example above works as expected, it will print `hello`.

If we wanted to use a different Greeter, we might be surprised that the output is also `hello`:

```cpp
...

int main() {
  SpanishGreeter spanishGreeter;
  Program p(spanishGreeter);
  p.run();
}
```

The reason the output is `hello` is because `Programs`'s constructor expects a `Greeter` not a `SpanishGreeter`. This causes the `spanishGreeter` to be converted to a `Greeter`, and calling the `talk` method on a `Greeter` prints `hello`.

The solution to this is to achieve run-time polymorphism on the `talk` method of `Greeter`. This means that we want children of `Greeter` to be able to define their own behavior for the `talk` method.

## Virtual

Here is where the `virtual` keyword comes to the rescue. Defining a method as virtual in `Greeter` tells the compiler that this method is overwritable by children classes.

The `virtual` keyword gets us almost there, but to achieve run-time polymorphism, we need to make `greeter` a pointer or a reference. If we didn't do this, we would be creating a new `Greeter` on the constructor and the link to the original class would be lost:

```cpp
#include <iostream>

class Greeter {
 public:
  // Add `virtual` here
  virtual void talk() {
    std::cout << "hello" << std::endl;
  }
};

class SpanishGreeter : public Greeter {
 public:
  void talk() {
    std::cout << "hola" << std::endl;
  }
};

class Program {
 public:
  Program(Greeter* g) : greeter_(g) {};

  void run() {
    greeter_->talk();
  }

 private:
  // Make `greeter_` a pointer
  Greeter* greeter_;
};

int main() {
  SpanishGreeter spanishGreeter;
  Program p(&spanishGreeter);
  p.run();
}
```

The program above print `hola` as expected.

## Abstract classes

There are times when we want to declare an interface for a class (methods for a class), but we don't want to define the methods right away. Instead, we want children classes to define this behavior. Classes that contain methods that are not defined are called `Abstract classes`.

For the `Greeter` example above, I decided to use English as the default language, but I could instead make Greeter an Abstract class and leave it to the children to implement the `talk` method. Undefined methods in an Abstract class are called `pure virtual` methods:

```cpp
class Greeter {
 public:
  virtual void talk() = 0;
};
```

Trying to instantiate an abstract class, will result in a compiler error, because some methods are not defined. Abstract classes can still be used as parameters. This means we can rewrite the code above like this:

```cpp
#include <iostream>

class Greeter {
 public:
  virtual void talk() = 0;
};

class SpanishGreeter : public Greeter {
 public:
  void talk() {
    std::cout << "hola" << std::endl;
  }
};

class Program {
 public:
  Program(Greeter* g) : greeter_(g) {};

  void run() {
    greeter_->talk();
  }

 private:
  Greeter* greeter_;
};

int main() {
  SpanishGreeter spanishGreeter;
  Program p(&spanishGreeter);
  p.run();
}
```

The only difference is that `Greeter.talk()` is now a pure virtual method, which makes `Greeter` an Abstract class.
