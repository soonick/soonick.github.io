---
id: 4684
title: C++ Header files 
date: 2017-12-28T03:57:55+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4684
permalink: /2017/12/c-header-files/
tags:
  - design_patterns
  - programming
  - c++
---
I&#8217;m writing C++ in the title of this article because I&#8217;m currently in a journey to learn C++. I believe the same concepts apply to C.

Writing about C++ is a little harder than writing about other languages because I keep stumbling into circular references where I need to understand A in order to understand B, but it&#8217;s very hard to understand A without understanding B.

I&#8217;m going to try to start with this article where I&#8217;ll explain why C++ has header files (files with .h extension) and how to use them.

## Code separation

Before we start looking into header files, lets first look at how code is split and included in languages where there are no header files. This little example is in node.js:

<!--more-->

hi.js:

```js
function hi() {
  console.log('hi');
}

exports.hi = hi;
```

main.js:

```js
var a = require('./hi.js');
a.hi();
```

This code can be executed using:

```js
node main.js
```

This node example shows that it is very easy to include code from another file. There is no need to create a separate file to define the api and you can decide exactly what methods you want to export. Lets try to do the same with C++:

hi.cpp

```cpp
#include <iostream>

void hi() {
  std::cout << "hi";
}
```

main.cpp:

```cpp
#include "hi.cpp"

int main() {
  hi();
}
```

You can compile the code:

```bash
g++ main.cpp
```

And then run it:

```bash
./a.out
```

This works as expected, it prints &#8220;hi&#8221; to the screen. A noticeable difference is that in node we namespaced the included functionality to a variable but in C++ there is no such namespace. Everything in hi.cpp is now visible in main.cpp.

## Namespacing

The obvious problem with the example above is name collision. Imagine there is another file named hello.cpp with this content:

```cpp
#include <iostream>

void hi() {
  std::cout << "hello";
}
```

And we modified main.cpp to look like this:

```cpp
#include "hi.cpp"
#include "hello.cpp"

int main() {
  hi();
}
```

If we try to compile this, we will get a compiler error: &#8220;redefinition of &#8216;hi'&#8221;.

Although this scenario might look trivial (we can just change the name of the function in hello.cpp), this could happen with third party libraries. Third party libraries can use any name for their functions, and we have no control over that. Sadly there is no easy solution for this. The suggestion is to namespace all libraries you write.

hello.cpp

```cpp
#include <iostream>

namespace hello {
  void hi() {
    std::cout << "hello";
  }
}
```

hi.cpp

```cpp
#include <iostream>

namespace hi {
  void hi() {
    std::cout << "hi";
  }
}
```

main.cpp

```cpp
#include "hi.cpp"
#include "hello.cpp"

int main() {
  hi::hi();
  hello::hi();
}
```

Of course, there could also be collisions with namespace names. If this happens you are in trouble. You can potentially work around it, but the way to do it is really annoying.

hello.cpp

```cpp
#include <iostream>

void hi() {
  std::cout << "hello";
}
```

hi.cpp

```cpp
#include <iostream>

void hi() {
  std::cout << "hi";
}
```

main.cpp

```cpp
#include <iostream>

namespace hello {
  #include "hello.cpp"
}

#include "hi.cpp"

int main() {
  hi();
  hello::hi();
}
```

The ugly thing about this code is that even though we don&#8217;t use iostream in main.cpp we had to include it because hello.cpp uses it. If hello.cpp included a lot of libraries we would have to manually add all those libraries too. To avoid this, try to come up with unique namespace names.

## Header files

This article is about header files, but I haven&#8217;t really used any of them. Can we live without them?

In simple examples like the ones above, we got away without using header files, but it is not recommended for production software. Lets look into a couple of reasons that might encourage you to use header files even when you might not necessarily need them.

## Header files to declare an API

Header files are often used to expose an API without exposing the whole implementation. To understand this better, we need to know what a declaration is.

When I was learning about programming languages back in school, I learned two stages of defining a variable: Declaration and initialization.

Declaration (I&#8217;m going to use this variable in this context):

```cpp
int i;
```

Initialization (I want this variable to start with this value):

```cpp
int i = 1;
// or
int j;
j = 1;
```

Hopefully everything makes sense so far.

C++ has two stages for defining an identifier: declaration, definition. These two stages apply not only to variables, but also to functions. Explaining the difference is a little easier using functions, so I&#8217;ll do that.

When we declare a function we say what is going to be the interface (return type and arguments):

```cpp
int addNumbers(int num1, int num2);
```

We just declared a function but we haven&#8217;t defined it. We can define it by specifying the body:

```cpp
int addNumbers(int num1, int num2) {
  return num1 + num2;
}
```

The declaration doesn&#8217;t have a body but the definition does. But why would would we ever want to have a function without a body? Header files usually include an interface we want to expose. When we expose an interface we don&#8217;t have to provide anything but the api contract. Lets look at an example:

little-library.h

```cpp
int publicMethod(int arg1, int arg2);
```

little-library.cpp

```cpp
int privateMethod(int arg) {
  return arg + 1;
}

int publicMethod(int arg1, int arg2) {
  return privateMethod(arg1) - privateMethod(arg2);
}
```

This library could be used like this:

```cpp
#include "little-library.h"

int main() {
  publicMethod(1, 2);
}
```

In the example above we can see that our library cpp file contains two methods, but our header file only contains the declaration of publicMethod. This prevents users of our library from accessing privateMethod, since it doesn&#8217;t exist in little-library.h. With a clear API, the library can become more complex, but the consumers don&#8217;t need to know about this complexity.

## Header files for performance

C++ is a compiled language, which means that every time you make a change to your project you need to compile it before you can run the program again. For small projects, the compile time can be insignificant.

```
time g++ main.cpp

real    0m0.273s
user    0m0.210s
sys 0m0.039s
```

Not even a second for the examples above. For large projects, compilation can take several minutes. The trick here is that compilation is done in a few steps, two of them being the compilation stage and the linking stage. When you tell the compiler to compile a file, it will generate an object file from the source code and then it will link all the object files to generate an executable file.

If you have a project with multiple source files (cpp), you can compile them all first and then link them together. After you make a modification to one of your source files, you only need to compile that file instead of having to compile all the files. This can be a lot faster than compiling all the files in large projects.

You might be thinking: So, I have to remember the files I modify and then compile only those files? Usually you don&#8217;t. I&#8217;m not going to talk about the tool you can use for compiling only the files you modify in this article (make), instead I will show you the manual process to illustrate how it works.

Lets assume we have a project that looks like this:

hello.h

```cpp
namespace hello {
  void hi();
}
```

hello.cpp

```cpp
#include <iostream>
#include "hello.h"

namespace hello {
  void hi() {
    std::cout << "hello";
  }
}
```

hi.h

```cpp
namespace hi {
  void hi();
}
```

hi.cpp

```cpp
#include <iostream>
#include "hi.h"

namespace hi {
  void hi() {
    std::cout << "hi";
  }
}
```

main.cpp

```cpp
#include "hi.h"
#include "hello.h"

int main() {
  hi::hi();
  hello::hi();
}
```

We can compile (skipping the linking stage) all the source files with the following command:

```bash
g++ -c main.cpp hi.cpp hello.cpp
```

This will generate three files: main.o, hi.o and hello.o. Then you can link the files with this command:

```bash
g++ main.o hi.o hello.o
```

The linking step is a lot faster than the compile step above:

```
time g++ main.o hi.o hello.o

real    0m0.027s
user    0m0.012s
sys 0m0.007s
```

This little performance gain can make a huge difference in large projects.

## Include guards

When you compile a source code file, the preprocessor will insert all included files inline in the source file being compiled. If you have a file like this one:

```cpp
#include "hi.h"

int main() {
  hi::hi();
}
```

The first thing the preprocessor will do is transform it into something like this:

```cpp
namespace hi {
  void hi();
}

int main() {
  hi::hi();
}
```

This can become a problem if the same file gets included more than once. This happens very often with transitive dependencies. Lets look at an example:

one.h

```cpp
class One {
};
```

two.h

```cpp
#include "one.h"

class Two {
};
```

main.cpp

```cpp
#include "one.h"
#include "two.h"
```

I know this example looks a little dumb, but similar situations are often encountered in real projects. The preprocessor will translate main.cpp into something like this:

```cpp
class One {
};
class One {
};
class Two {
};
```

And the compilation would give an error: &#8220;redefinition of &#8216;One'&#8221;. This could be a surprise to the developer, because they are not aware of how two is implemented. In their mind, they only included one once. To prevent this from happening we can use include guards in our header files:

one.h

```cpp
#ifndef ONE_H
#define ONE_H

class One {
};

#endif
```

two.h

```cpp
#ifndef TWO_H
#define TWO_H

#include "one.h"

class Two {
};

#endif
```

This prevents the preprocessor from including the same content twice. The result would be something like this:

```cpp
class One {
};
class Two {
};
```

You should add include guards to all your header files to prevent problems for your consumers.
