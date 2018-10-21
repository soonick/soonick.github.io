---
id: 4682
title: C++ types, pointers and references
date: 2018-01-04T05:57:37+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4682
permalink: /2018/01/c-types-pointers-and-references/
tags:
  - c++
  - programming
---
Writing a post about types in most high level languages I&#8217;m used to wouldn&#8217;t be very interesting, but I&#8217;ve recently started learning C++ and I realized that I need to understand memory a little better to be able to write and read C++ programs effectively.

There is a collection of types that should not cause many surprises. .

## Integer types

| char | 1 byte |
| short | 2 bytes |
| int | 4 bytes |
| long | 8 bytes |
| long long | 16 bytes |

## Floating point types

| float | 14 bytes |
| double | 18 bytes |
| double double | 116 bytes  |

> *The sizes above are for GNU C compiler, but might vary for different compilers
  
> *All numeric types can be modified with the unsigned keyword. This affects the minimum and maximum possible values that can be hold and the way arithmetic operations work on them, but not their size in bytes.

<!--more-->

Those are the most important basic types in C++. There are of course also arrays but I won&#8217;t cover them here since I want to focus on how pointers and references work in this article.

## Pointers

C++ has the concept of pointers, which other higher level programming languages don&#8217;t have. In order to understand pointers correctly we need to first understand a little how memory works.

In most modern computers, memory is divided in slots of 1 byte (8 bits). Each of these slots has a memory address associated with it. Something like this:

[<img src="/images/posts/adresses.jpg" />](/images/posts/adresses.jpg)

There are many memory addresses in a modern computer, so the addresses are usually shown in hexadecimal to make the address number look a little smaller. Lets look at an example:

```cpp
#include <iostream>

int main() {
  short a = 5;
  short b = 0;
  short c;
  std::cout << &a << ":" << a << "\n";
  std::cout << &b << ":" << b << "\n";
  std::cout << &c << ":" << c << "\n";
}
```

The output is something like this:

```
0x7fff5490493e:5
0x7fff5490493c:0
0x7fff5490493a:3185
```

The first part (before the colon) is the memory address. You can get the memory address of a variable using &.

There are a few interesting things we can see here. We can see that the memory address is a pretty high number and is printed in hexadecimal (e.g. 0x7fff5490493e). We can also see that c printed 3185 as value even though we didn&#8217;t assign that value to it. Since we didn&#8217;t assign any value to c, it will grab whichever value happened to be lying in the memory address it happened to be assigned. You should not use variables without initializing them first, because you never know what you will get.

When a variable type holds more than a single byte, it will use the adjacent memory slots to hold the whole value. Since short can hold 16 bits it requires two memory slots to hold its value. If you look at all the memory addresses above you will notice that they are all one byte apart. Another interesting thing (although I don&#8217;t know why) is that the variable we declared last ended up getting the lowest memory address.

Now that we know how a variable holds a value in memory we can take a look at pointers. Pointers are variables like any other and hold values like any other. The difference is that the value that a pointer holds is a memory address. Lets look at an example:

```cpp
#include <iostream>

int main() {
  short a = 5;
  short *p = &a;

  std::cout << &a << ":" << a << "\n";
  std::cout << &p << ":" << p << "\n";
}
```

Prints:

```
0x7fff5182893e:5
0x7fff51828930:0x7fff5182893e
```

A few interesting things to see here. Pointers have a type and an *. We define our pointer like this:

```cpp
short *p;
```

We can assign to this pointer the address of a variable of the same type as the pointer (&a). In the output we can see that the value of p is the memory address of a.

We can use the pointer to access to the value the pointer points to by using the dereferencing operator *:

```cpp
#include <iostream>

int main() {
  short a = 5;
  short *p = &a;

  std::cout << &a << ":" << a << "\n";
  std::cout << &p << ":" << p << ":" << *p << "\n";
}
```

Prints:

```
0x7fff5f18893e:5
0x7fff5f188930:0x7fff5f18893e:5
```

Hopefully this all makes sense so far. Let&#8217;s now take a look at references, which are somewhat similar to pointers.

## References

A reference is actually very similar to a pointer internally, but the compiler does the dereferencing and referencing for us automatically (Without needing to use * or &) based on the context. Because they are so similar to pointers, the designers of C++ decided to reuse the & operator to declare a reference:

```cpp
#include <iostream>

int main() {
  short a = 5;
  short &b = a;
  short c = a;

  std::cout << &a << ":" << a << "\n";
  std::cout << &b << ":" << b << "\n";
  std::cout << &c << ":" << c << "\n";
}
```

Prints:

```
0x7fff5514893e:5
0x7fff5514893e:5
0x7fff5514892e:5
```

You can see that a and b point to the same memory address, while c points to a different one. You can also see that this is done by using the & operator on the left side of the definition (short &b = a;). Using & on the right side (short b = &a;) would give an error because you would be trying to assign a short pointer to a short.

Because of this automatic referencing a dereferencing, the address of a reference can&#8217;t be modified.

```cpp
int main() {
  short a = 5;
  short b = 1;
  short &c = a;
  c = &b; // error: assigning to 'short' from incompatible type 'short *'; remove &
}
```

We now understand how references work. But why would we use them when they can be so confusing? The answer is performance. In C++ when you pass a variable as an argument to a function, the variable is cloned and a clone is used inside the function. This takes time and uses extra memory. Lets look at it:

```cpp
#include <iostream>

void func(short b) {
  std::cout << "val: " << b << "   address: " << &b << "\n";
}

int main() {
  short a = 5;
  std::cout << "val: " << a << "   address: " << &a << "\n";

  func(a);
}
```

Prints:

```
val: 5   address: 0x7fff5a6dc93e
val: 5   address: 0x7fff5a6dc91c
```

We can see that a new memory address was used inside the function. If we really cared about performance we could use a pointer instead:

```cpp
#include <iostream>

void func(short *b) {
  std::cout << "val: " << *b << "   address: " << b << "\n";
}

int main() {
  short a = 5;
  std::cout << "val: " << a << "   address: " << &a << "\n";

  func(&a);
}
```

Prints:

```
val: 5   address: 0x7fff4fcdd93e
val: 5   address: 0x7fff4fcdd93e
```

This gives us the desired effect, but we had to make a few changes to our code for this to work. In the function definition we had to change it to accept a pointer (using \*). Then we had to use \* to get the value and remove the & to get the address. In the function call we also had to use & to pass the address instead of the value.

If we had used a reference we could have achieved the same effect only by adding & to the function parameter. The function body would be a lot easier to read:

```cpp
#include <iostream>

void func(short &b) {
  std::cout << "val: " << b << "   address: " << &b << "\n";
}

int main() {
  short a = 5;
  std::cout << "val: " << a << "   address: " << &a << "\n";

  func(a);
}
```

Performance penalties are not only paid when passing arguments to a function, they could also be paid when returning from a function:

```cpp
#include <iostream>

int addOne(int num) {
  int res = num + 1;

  std::cout << &res << "\n";

  return res;
}

int main() {
  int res = addOne(2);
  std::cout << &res << "\n";
}
```

The program above uses two memory addresses. This can be seen in the output:

```
0x7fff541aa918
0x7fff541aa93c
```

You might see a lot of programs in the wild receive a return value as a parameter:

```cpp
#include <iostream>

void addOne(int &res, int num) {
  res = num + 1;
}

int main() {
  int res;
  addOne(res, 2);
  std::cout << res << ":" << &res << "\n";
}
```

In this case, the memory allocation is done in main and that memory address is used inside addOne to store the result. This is a very common and accepted practice for returning values from a function, specially values that can be considerably big (usually objects).

It might be tempting to instead of receiving a reference as an argument, you return a reference. This might seem more readable, but it will result in an incorrect program. The following code is wrong:

```cpp
#include <iostream>

int & addOne(int num) {
  int res = num + 1;
  return res;
}

int main() {
  int res = addOne(2);
  std::cout << res << ":" << &res << "\n";
}
```

If you compile this program you will get a warning: &#8220;reference to stack memory associated with local variable &#8216;res&#8217; returned [-Wreturn-stack-address]&#8221;. Unfortunately, it is just a warning, so the compilation will complete successfully and you will be able to run the program and see the result:

```
3:0x7fff53cef93c
```

The worst thing about this code is that the result looks correct, but there is no guarantee that this will always be the case. After the function exits your code will declare the memory address as available, so there is nothing impeding other programs (or the same program) from reusing that memory address and putting any value in there.

> In my examples above I passed an int by reference to a function. This can be done, but usually shouldn&#8217;t be done for primitive types. Leave the passing by reference to parameters that are objects

## Constants

Constants are pretty straight forward in most cases. If you declare a variable as a constant, then the compiler won&#8217;t let you change it in the future. Lets look at some examples.

```cpp
int main() {
  const int a = 5;
  a = 7;
}
```

If you try to compile the code above, you will get an error similar to: &#8220;cannot assign to variable &#8216;a&#8217; with const-qualified type &#8216;const int'&#8221;.

Because a constant can not be modified once it is defined, it has to be initialized to a value.

```cpp
int main() {
  const int a;
}
```

The program above will throw the error: &#8220;default initialization of an object of const type &#8216;const int'&#8221;.

These two examples hopefully are very easy to understand. Constants can be used in other contexts that are not that intuitive. One of those contexts is pointers:

```cpp
#include <iostream>

int main() {
  int a = 5;
  int b = 9;
  const int *p = &a;
  p = &b;
}
```

The code above works with no problems. Even though it might look like we are declaring a pointer with a constant value, what we are really doing is declaring a pointer to a constant int. This works even if a is not a constant. What will happen is that a can be modified if you refer to it as a, but you won&#8217;t be able to modify it using the pointer *p:

```cpp
#include <iostream>

int main() {
  int a = 5;
  const int *p = &a;
  a = 7; // Valid
  *p = 9; // Error
}
```

Only the line `*p` = 9 will cause an error here.

It is possible to create constant pointers, but the const keyword goes after the *:

```cpp
#include <iostream>

int main() {
  int a = 5;
  int b = 5;
  int * const p = &a;
  p = &b;
}
```

The code above will throw this error: &#8220;cannot assign to variable &#8216;p&#8217; with const-qualified type &#8216;int *const'&#8221;. Which basically means that p is constant and you can&#8217;t modify its value (which is an address).

Function parameters can also be declared as const. What this means is that the variable will be treated as if it was a constant inside that function, even if it is not:

```cpp
#include <iostream>

void something(const int s) {
  std::cout << s;
}

int main() {
  int a = 1;
  const int b = 2;
  something(a);
  something(b);
}
```

This code works correctly even when a is not a constant, because the function still treats it as a constant (it does not modify it). On the contrary, the following code would fail because we are trying to modify the const parameter.

```cpp
#include <iostream>

void something(const int s) {
  s++; // s is declared as const so this is invalid
  std::cout << s;
}

int main() {
  int a = 1;
  const int b = 2;
  something(a);
  something(b);
}
```

When a parameter is passed by reference, the compiler won&#8217;t allow you to accidentally pass a const to a function that can modify it&#8217;s value (it checks that the parameter is declared as const):

```cpp
#include <iostream>

void something(int &s) {
  std::cout << s;
}

int main() {
  const int a = 2;
  something(a);
}
```

The code above will throw this error: &#8220;candidate function not viable: 1st argument (&#8216;const int&#8217;) would lose const qualifier&#8221;. If you wanted to accept the constant you just need to make the parameter constant:

```cpp
#include <iostream>

void something(const int &s) {
  std::cout << s;
}

int main() {
  const int a = 2;
  something(a);
}
```

## Conclusion

After writing this article I feel a lot more comfortable writing and reading some of the code I&#8217;m working on. There are some parts that are not completely intuitive yet, but at least I can come back to this article when I&#8217;m not sure why the compiler is giving me an error or warning I don&#8217;t understand.
