---
title: Variadic templates / functions in C++
author: adrian.ancona
layout: post
tags:
  - c++
  - programming
---

A variadic function is a function that can take a variable number of arguments.

I have used variadic functions in previous posts, but I have not explained how they work. This post will cover that.

## C-style variadic functions

C++ supports the C-like syntax for writing variadic fuctions.

Let's say we want to write a function that adds numbers together. If we wanted to write a function that adds two numbers, we could do it easily:

```cpp
int add(int a, int b) {
  return a + b;
}
```

<!--more-->

What happens if we want to add three numbers together? Instead of writing a different function for each number of arguments, we can write a variadic function:

```cpp
int add(int numbers...) {
  va_list args;
  va_start(args, numbers);

  int total = 0;
  for (int i = 0; i < numbers; i++) {
    total += va_arg(args, int);
  }

  va_end(args);

  return total;
}
```

The example above shows the C syntax for writing variadic functions. It is not beautiful and comes with performance and type safety problems.

Another big issue is that there is no way to know how many arguments were passed to the function, the only way to do it, is by having the caller of the function pass the number of arguments as the first argument. For example:

```cpp
add(3, 1, 2, 3); // Outputs 6
```

The first `3` serves to tell the function to expect another 3 arguments. This is error prone, and if the caller makes a mistake, the result would be undefined:

```cpp
add(4, 1, 2, 3); // Output is undefined
```

To get access to the arguments we need to call `va_start` with a `va_list`:

```cpp
va_list args;
va_start(args, numbers);
```

Each call to `va_start` must be later matched with a `va_end`:

```cpp
va_end(args);
```

What happens if we fail to call `va_end` might vary by compiler, but you should expect the worse.

To get the arguments, we need to use `va_arg`. Every time it is called, it will return the next argument. Calling it after all arguments have been read, results in an invalid value being returned. That's the reason passing the wrong count as first argument has undefined behavior:

```cpp
total += va_arg(args, int);
```

Instead of going deeper into the quirks of variadic functions, I will explain the improvements that C++ brings.

## C++ variadic templates (parameter pack)

If you don't know what templates are, you might want to take a look at my [article about templates](/2019/08/cpp_generics_templates/).

C++ uses a very different approach to variadic functions. It allows us to write type safe functions, but they are a little hard to reason about (at least in the beginning).

Let's see some code, and I'll explain how it works:

```cpp
template <typename T>
T add(T i) {
  return i;
}

template <typename T, typename ...Args>
T add(T i, Args... numbers) {
  return i + add(numbers...);
}

int main() {
  std::cout << add(1, 2, 3) << std::endl;
}
```

The output of the example above, is `6`.

The first fuction should be easy to understand if you are familiar with templates:

```cpp
template <typename T>
T add(T i) {
  return i;
}
```

This function looks useless, but is necessary for our variadic function to work. It tells the compiler that if it sees a call to `add` with a single argument, it should create a function that takes that argument and returns it. For example, if it was called with an int, it will create:

```cpp
int add(int i) {
  return i;
}
```

The next function is where things get interesting:

```cpp
template <typename T, typename ...Args>
T add(T i, Args... numbers) {
  return i + add(numbers...);
}
```

Let's start with the template definition. Everything looks normal until `...Args`. This is called a template parameter pack and must be declared as the final type of the template.

The template parameter pack, packs together multiple arguments of any type (they can be different types) as long as the compiler can find valid functions for all the types (I'll explain more about this later).

Notice that the template also declares a type T. This is necessary if we want to do something useful with the arguments.

We could write a function like this one, but it wouldn't be very useful:

```cpp
template <typename ...Args>
void sayHello(Args... stuff) {
  std::cout << "hello";
}
```

The next thing to inspect is the function signature:

```cpp
T add(T i, Args... numbers) {
```

Here, we are telling the compiler to create a function that takes one argument of type T (any type) and 0 or more other arguments of any type. The `Args...` part is called a pack expansion.

The body of the function calls `add` again (recursively) with all the packed parameters expanded:

```cpp
return i + add(numbers...);
```

Let's see how the compiler makes sense of this.

In the snippet above, I called `add(1, 2, 3)`. What the compiler sees is: `add(int, int, int)`, but can't find a function with that signature. It settles with `add(T i, Args... numbers)`. Because this is a template, it will create a function based on the template. Something like this:

```cpp
int add(int i, Args... numbers) {
  return i + add(numbers...);
}
```

Since the first argument is 1, we could say that the function will return:

```cpp
1 + add(numbers...);
```

Where `numbers...` contains `2` and `3`. These numbers happen to be ints too, so the same function can be called again with `2` and `3`:

```cpp
2 + add(numbers...);
```

Here is where something interesting happens. `numbers...` contains only 3, so `add(numbers...)` could be replaced with `add(3)`. Remember the first function we declared?:

```cpp
int add(int i) {
  return i;
}
```

Since `add(3)` matches this signature, it will call this function, which simply returns the given argument. That means:

```
2 + add(numbers...) == 2 + add(3) == 2 + 3 == 5
```

And

```cpp
1 + add(numbers...) == 1 + 5 == 6
```

And that's how the program arrives to the final result: `6`.

One important thing to note, is that this only works because we declared our base case:

```cpp
template <typename T>
T add(T i) {
  return i;
}
```

Without this function, the compiler wouldn't know what to do.

Because we are using templates, the arguments don't need to strictly be `int`s. We could call `add` like this:

```cpp
add(1.1, 2, 3);
```

The call above returns `6.1` as expected, but you might be surprised to see that the following:

```cpp
add(1, 2.1, 3);
```

Will return `6` instead of `6.1`.

If we follow the same logic as before, we will notice, that the first call in the recursion chain will be:

```cpp
int add(int i, Args... numbers) {
  return i + add(numbers...);
}
```

So the result will always be an int. The same logic explains why something like `add(1, 2, "hello")` fails to compile with this error:

```sh
a.cpp:10:12: error: invalid conversion from ‘const char*’ to ‘int’ [-fpermissive]
   return i + add(numbers...);
          ~~^~~~~~~~~~~~~~~~~
```

## Conclusion

If you are familiar with recursion, it shouldn't be too hard to wrap your head around how variadic templates work in C++. They might not be the easiest to implement, but they provide type safety and compile time checks that makes it hard to use them incorrectly.
