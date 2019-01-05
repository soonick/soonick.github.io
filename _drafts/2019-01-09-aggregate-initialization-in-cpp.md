---
title: Aggregate initialization in C++
author: adrian.ancona
layout: post
date: 2019-01-09
permalink: /2019/01/aggregate-initialization-in-cpp/
tags:
  - programming
  - c++
---

I previously wrote an article about [variable initialization in C++](/2019/01/2019-01-02-variable-initialization-in-cpp), but sadly, initialization of variables in C++ is a complicated subject with a lot of options.

## Aggregate classes

Before talking about aggregate initialization, we need to know what an aggregate is. Aggregate classes have these properties:

- All its data members are public
- Doesn't define any constructors
- Doesn't have virtual functions
- Doesn't inherit from any class
- Doesn't have any in-class initializers

An example could be:

```cpp
class Person {
 public:
  std::string name;
  int age;
};
```

<!--more-->

## Aggregate initialization

Aggregates can be initialized using initializer lists, like this:

```cpp
Person adrian{"Adrian", 32};
```

In this case, the order of the member variables in the definition of `Person` dictates the order of arguments in the initialization. The first argument, will be assigned to `name`, and the second to `age`.

There is a different syntax that can be used:

```cpp
Person carlos{
  .name = "Carlos",
  .age = 25
};
```

I consider this better because it makes it clearer which value is being assigned to each member. Sadly, as with list-intialization, the order needs to be kept.

Another thing to consider is that in any case, it is not necessary to pass all values. These are both valid:

```cpp
Person adrian{"Adrian"};
Person carlos{
  .name = "Carlos"
};
```

In these cases, age will be value initialized to `0`.

## Conclusion

I discovered aggregate initialization by reading some code and stumbling into aggregate initialization syntax. I think aggregates only work on very specific cases, so I don't expect to use this knowledge very frequently. The good thing, is that I won't be surprised if I see code that uses it.
