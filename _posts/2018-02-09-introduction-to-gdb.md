---
id: 4887
title: Introduction to GDB
date: 2018-02-09T14:01:30+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4887
permalink: /2018/02/introduction-to-gdb/
tags:
  - c++
  - debugging
  - programming
---
GDB is the GNU project debugger. It can be used to see what a program is doing or what it was doing when it crashed. GDB can be used with a variety of languages. Because I&#8217;m learning C++, I&#8217;m going to explain it in the context of C++.

## Adding debugging symbols

One of the stages of the compilation of a C++ program is to generate an object file (file.o). This object file contains what is called a [symbol table](https://en.wikipedia.org/wiki/Symbol_table), which contains each identifier in the code with information associated with it (type, constness, etc&#8230;).

If we want to be able to use GDB in one of our programs we need to add debugging information to this table ([debug symbols](https://en.wikipedia.org/wiki/Debug_symbol)). To add debug symbols to our binary we use the -g flag:

<!--more-->

```
g++ -g main.cpp -o program
```

## A program to debug

To make it easy to understand what we are doing. Lets create a simple program to debug.

main.cpp:

```cpp
#include <iostream>
#include "math_stuff.h"

void printSomeNumbers() {
  for (int i = 0; i < 10; i++) {
    std::cout << i << '\n';
  }
}

int main()
{
  std::cout << "Start of the program\n";

  printSomeNumbers();
  int num = math_stuff::addNumbers(4, 5);
  std::cout << math_stuff::printNumberPlus5(num) << '\n';

  std::cout << "End of the program\n";
}
```

math_stuff.h

```cpp
namespace math_stuff {
  int addNumbers(int a, int b);
  int printNumberPlus5(int number);
}
```

math_stuff.cpp

```cpp
namespace math_stuff {
  int addNumbers(int a, int b) {
    return a + b;
  }

  int printNumberPlus5(int number) {
    return number + 3;
  }
}
```

To compile this program with debugging symbols we can use:

```
g++ -g main.cpp math_stuff.cpp -o program
```

## Debugging a program

Lets say there is an issue in our program and we want to debug it. We know there is something wrong in line 16 of main.cpp, so let&#8217;s set a breakpoint.

We start by opening our program with GDB:

```
gdb program
```

Once in GDB we can add a breakpoint (b is short for breakpoint):

```
b main.cpp:16
```

And run the program (r is short for run):

```
r
```

The program will execute until the line where we set the breakpoint:

```
(gdb) r
Starting program: /home/adrianancona/repos/c++/program
Start of the program
0
1
2
3
4
5
6
7
8
9

Breakpoint 1, main () at main.cpp:16
16    std::cout << math_stuff::printNumberPlus5(num) << '\n';
```

GDB stops before executing line 16. One thing we might want to do here is see the current value of num (p is short for print):

```
p num
```

Will output something like this:

```
$1 = 9
```

You can use p to print the result of any valid expression. For example, we can see what printNumberPlus5 returns:

```
p math_stuff::printNumberPlus5(num)
```

By looking at the output, we can see that printNumberPlus5 is not working as expected

```
$2 = 12
```

It should be printing 14 (because num is 9, and 9 + 5 = 14), not 12.

We can step into the function at the current breakpoint (s is short for step):

```
s
```

And we will see the first line of the function:

```
math_stuff::printNumberPlus5 (number=9) at math_stuff.cpp:7
7       return number + 3;
```

It&#8217;s adding 3 instead of 5. We found the bug!

There are more things we can do while we are here. We could for example see the call stack to find how we got where we are (bt is short for backtrace):

```
bt
```

Output:

```
#0  math_stuff::printNumberPlus5 (number=9) at math_stuff.cpp:7
#1  0x00000000004008a8 in main () at main.cpp:16
```

It happens often that seeing just the current line is not enough to figure out what the problem is. We can tell GDB to give us a little more context (l is short for list):

```
l 7
```

7 is the line number were we last stopped. The command will show lines sorrounding the given line in the current file (by default 10 lines):

```
2     int addNumbers(int a, int b) {
3       return a + b;
4     }
5
6     int printNumberPlus5(int number) {
7       return number + 3;
8     }
9   }
```

We can step out of the current function using the finish command:

```
finish
```

This takes us to the next line in our main function:

```
Run till exit from #0  math_stuff::printNumberPlus5 (number=9) at math_stuff.cpp:7
0x00000000004008a8 in main () at main.cpp:16
16    std::cout << math_stuff::printNumberPlus5(num) << '\n';
1: num = 9
Value returned is $4 = 12
```

Since we are done debugging we can continue the program execution (c is short for continue):

```
c
```

This will continue the execution of the program until it reaches another endpoint, or (in our case) until the program ends.

This are some of the most common use cases for debugging a simple program. I&#8217;ll cover more advanced cases in another post.
