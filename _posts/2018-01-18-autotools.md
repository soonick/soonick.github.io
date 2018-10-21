---
id: 4680
title: Autotools
date: 2018-01-18T06:56:34+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4680
permalink: /2018/01/autotools/
tags:
  - automation
  - linux
  - productivity
  - programming
  - c++
---
A few days ago I was listening to a talk about the new features of C++ and I heard the presenter mention autools. I felt pretty dumb not knowing what he was talking about so I&#8217;m writing this post to make me feel less dumb.

## Make

It all started with [Stuart Feldman&#8217;s](https://en.wikipedia.org/wiki/Stuart_Feldman) make. Make is a tool that generates files based on other files. In a _makefile_ you can specify a list of files you want to generate and how to generate those files (based on other files). The most common use for make is to generate executables based on source code.

Make allows people to generate executables easily based on source code. People in possession of the code don&#8217;t need to know the steps to build the executable because these steps are already recorded in the makefile. Another advantage of make is that it allows for faster builds by keeping tracks of source files that haven&#8217;t changed since last time a build was run and skipping unnecessary steps. This is specially useful for large codebases that take long time to compile.

<!--more-->

A makefile looks something like this:

```makefile
main: main.o hello.o hi.o
    g++ -o main main.o hi.o hello.o

main.o: main.cpp hello.h hi.h
    g++ -c main.cpp

hello.o: hello.cpp hello.h
    g++ -c hello.cpp

hi.o: hi.cpp hi.h
    g++ -c hi.cpp

clean:
    rm main main.o hello.o hi.o
```

The example above is a Makefile for one of the examples of [my article about header files](https://ncona.com/2017/12/c-header-files/). We can now build the project:

```
make
```

Running the _make_ command by itself is the same as running _make all_. This command will build all targets present in the Makefile in the current folder. Lets look at one of our targets. The first line defines the name of our recipe and it&#8217;s dependencies:

```
main: main.o hello.o hi.o
```

The way to read that line is: main depends on main.o, hello.o and hi.o. If we look at the makefile we will find recipes for each of them, for example:

```
main.o: main.cpp hello.h hi.h
```

In this case we can see that main.o also has dependencies. This time, the dependencies are not rules but files. main.o depends on main.cpp, hello.h and hi.h. If those files are present and modified (I&#8217;ll explain more about what modified means) then the recipe will be executed:

```
    g++ -c main.cpp
```

In this case the recipe is a single line that compiles main.cpp. One thing to notice here is that this command generates a file named _main.o_, which is the name of the recipe. This relationship is necessary for make to work correctly.

I mentioned above that make will check if the files are modified. What this means is that make keeps a list of all the files in the project and when was the last time they were changed. If I ran make two times in a row, the first time it would compile and link all the files, but the second time it would just check the modification date and notice that the files haven&#8217;t changed, so it wouldn&#8217;t do anything:

```bash
$ make
make: 'main' is up to date.
```

If for example, hello.cpp was modified, then make would run the hello.o recipe and then the main recipe, but it would not run hi.o or main.o because they don&#8217;t depend on hello.cpp.

## Portability

If you need to build the same program on a different platform, the Makefile needs to be tweaked to work on that platform. A maintainer of some GNU packages named David J. MacKenzie was doing this often enough that he decided to create a script to automatically generate the correct Makefile based on the platform. From his work, Autoconf was built. Thanks to autoconf, most modern programs can be built with a simple combination regardless of the platform:

```
./configure && make
```

There are two main tools in Autotools: Autoconf and Automake. Autoconf will take care of the configure script and Automake will take care of the Makefile. Without these tools we would need to generate configure scripts and Makefiles manually for all platforms we want to maintain. This tools help us not worry about the build system and focus on writing software.

## Using autotools

Now that we know how make works and why we would want to use autotools, let&#8217;s make our little example program more portable. Instead of having a Makefile, we are going to create a file named Makefile.am:

```
bin_PROGRAMS = main
main_SOURCES = main.cpp hello.cpp hi.cpp hello.h hi.h
```

In this automake file we define the binary file we want to create and the source files necessary to create that binary.

We also need to create a configure.ac file:

```
AC_INIT([hello], [1.0], [bug-automake@gnu.org])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
AC_PROG_CXX
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([
 Makefile
])
AC_OUTPUT
```

Now we can run:

```
autoreconf --install
```

To generate our configure and make files. Once we have these files, we can build our program the standard UNIX way:

```
./configure && make
```
