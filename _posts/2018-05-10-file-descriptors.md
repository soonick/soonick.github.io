---
id: 5014
title: File descriptors
date: 2018-05-10T05:15:35+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=5014
permalink: /2018/05/file-descriptors/
tags:
  - linux
  - programming
---
I&#8217;ve heard a few times during my career references to file descriptors without knowing much about them. Today I&#8217;m going to try to understand what they are.

File descriptors are a Unix concept. They refer to a way of referencing a file or other resources (stdin, stdout, etc&#8230;). They are referenced by unsigned integers. Some old versions of Unix used to limit the number of file descriptors per process to 20 (0 to 19), but nowadays, there is no actual limit on the number of file descriptors a process can have.

Each running process is assigned a file descriptors table. The table for a process can be found at /proc/PID/fd. We can see the file descriptors used by a process like this:

<!--more-->

```
ls /proc/1490/fd -l
lr-x------ 1 adrianancona adrianancona 64 Apr 26 10:37 0 -> /dev/null
lrwx------ 1 adrianancona adrianancona 64 Apr 26 10:37 1 -> socket:[422586]
lrwx------ 1 adrianancona adrianancona 64 Apr 26 10:37 2 -> socket:[422586]
lr-x------ 1 adrianancona adrianancona 64 Apr 26 10:37 10 -> pipe:[422595]
l-wx------ 1 adrianancona adrianancona 64 Apr 26 10:38 100 -> /home/adrianancona/.config/chromium/Default/Download Service/EntryDB/LOG
...
```

Process 1490 is a chromium process. We can see that file descriptor 100 references a file in _~/.config/chromium_. File descriptor 10 is a pipe, 1 and 2 are sockets and 0 is a device.

File descriptors 0, 1 and 2 have special meaning:

  * 0 &#8211; stdin
  * 1 &#8211; stdout
  * 2 &#8211; stderr

We can see in the example above that stdin references the null device (_/dev/null_). This happens for all daemon processes (processes detached from a terminal).

Another interesting thing to look at is the permissions column. We can see that the log file is opened in write-only mode (l-wx). There are three possible values:

  * lr-x &#8211; read-only mode
  * l-wx &#8211; write-only mode
  * lrwx &#8211; read-write mode

We can write a program to see how file descriptors are created for a process:

```cpp
#include <iostream>
#include <string>

int main() {
  std::string input;

  std::cout << "Type something to finish: ";
  std::cin >>  input;
}
```

We can then compile and run this program:

```
$ # Compile
$ g++ descriptors.cpp -o descriptors
$ # Run
$ ./descriptors
Type something to finish:
```

The program will wait there until an input is given. We can open another terminal to see the file descriptors used by this program:

```
$ # Find the PID
$ ps -a | grep descriptors
16140 pts/4    00:00:00 descriptors
$ # List the file descriptors
$ ls -l /proc/16140/fd
total 0
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:30 0 -> /dev/pts/4
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:30 1 -> /dev/pts/4
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:29 2 -> /dev/pts/4
```

Although this program is not doing anything with files, the 3 default file descriptors are created. They all reference _/dev/pts/4_. pts devices are [pseudo-terminals](https://en.wikipedia.org/wiki/Pseudoterminal) (Terminals provided by a terminal emulator).

Let&#8217;s modify our program to open some files:

```cpp
#include <iostream>
#include <string>
#include <fstream>

int main() {
  std::string input;

  std::ofstream file1;
  std::ofstream file2;
  std::ofstream file3;

  std::cout << "No descriptors created yet";
  std::cin >>  input;

  file1.open("file1");
  file2.open("file2");

  std::cout << "Two file descriptors open";
  std::cin >>  input;

  file1.close();

  std::cout << "One file descriptor at this point";
  std::cin >>  input;

  file3.open("file3");

  std::cout << "The file descriptor for the closed file is recycled";
  std::cin >>  input;
}
```

Here are the different file descriptors at different points in the execution:

```
total 0
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:58 0 -> /dev/pts/4
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:58 1 -> /dev/pts/4
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:57 2 -> /dev/pts/4
~/repos/apue $ ls -l /proc/18233/fd
total 0
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:58 0 -> /dev/pts/4
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:58 1 -> /dev/pts/4
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:57 2 -> /dev/pts/4
l-wx------ 1 adrianancona adrianancona 64 Apr 27 16:58 3 -> /home/adrianancona/repos/apue/file1
l-wx------ 1 adrianancona adrianancona 64 Apr 27 16:58 4 -> /home/adrianancona/repos/apue/file2
~/repos/apue $ ls -l /proc/18233/fd
total 0
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:58 0 -> /dev/pts/4
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:58 1 -> /dev/pts/4
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:57 2 -> /dev/pts/4
l-wx------ 1 adrianancona adrianancona 64 Apr 27 16:58 4 -> /home/adrianancona/repos/apue/file2
~/repos/apue $ ls -l /proc/18233/fd
total 0
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:58 0 -> /dev/pts/4
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:58 1 -> /dev/pts/4
lrwx------ 1 adrianancona adrianancona 64 Apr 27 16:57 2 -> /dev/pts/4
l-wx------ 1 adrianancona adrianancona 64 Apr 27 16:58 3 -> /home/adrianancona/repos/apue/file3
l-wx------ 1 adrianancona adrianancona 64 Apr 27 16:58 4 -> /home/adrianancona/repos/apue/file2
```

One thing to notice from the output is that file descriptor 3 is freed when file1 is closed and then reused by file3. We can also see that by default ofstream opens files in write-only mode.

Looking at the file descriptors in /proc/PID/fd, helps us get a more tangible have of what they are. These file descriptors that reference other files have the correct owner (the user who started the program) and permissions to keep the integrity of the system.

I think with this I will be able to better understand when people talk about this subject at work.
