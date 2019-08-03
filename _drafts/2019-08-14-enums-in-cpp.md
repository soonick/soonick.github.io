---
title: Enums in C++
author: adrian.ancona
layout: post
date: 2019-08-14
permalink: /2019/08/enums-in-cpp/
tags:
  - programming
  - c++
---

Enumerations are useful when we want to have a custom type, that can only have a limited number of values. For example:

```cpp
enum Mode {
  EASY,
  MEDIUM,
  HARD
};
```

We can create variables of type enum that can only have one of the previously defined values:

```
Mode userMode = EASY;
```

<!--more-->

Trying to set it to something else, would cause a compilation error.

Enums make code easy to understand, and are very cheap, because an int is used to represent the values.

There is not a whole lot to say about enumerations, but there are a couple of things that could be surprising.

## Scope

If we find that we have two enums with values named the same, the compiler will complain. This is not valid, because `HARD` is used in two enums:

```cpp
enum Mode {
  EASY,
  MEDIUM,
  HARD
};

enum texture {
  HARD,
  SOFT
};
```

Enum values, are global by default, which is most of the time not the desired behavior. To avoid this issue, we can use `enum class`:

```cpp
enum class Mode {
  EASY,
  MEDIUM,
  HARD
};

enum class texture {
  HARD,
  SOFT
};
```

To disambiguate, we precede a value by the enumeration class it belongs to:

```cpp
Mode userMode = Mode::EASY;
```

## Explicit values

Although, it shouldn't be needed in most cases, it is possible that you want to control which integer is an enum value translated to. It can be done like this:

```cpp
enum class Mode {
  EASY = 1,
  MEDIUM = 5,
  HARD = 10
};
```

In general, the value underneath and enum, should be completely opaque, but one instance where it might be useful to know the exact value, could be if we are using it for logging:

```cpp
Mode userMode = Mode::MEDIUM;
std::cout << (int)userMode;
```

In this case, when we look at the logs, we want to know what the number in the logs actually means.
