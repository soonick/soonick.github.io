---
title: Debugging assembly with GDB
author: adrian.ancona
layout: post
tags:
  - computer_science
  - programming
  - assembly
  - debugging
---

I wrote a couple of articles about assembly in the last weeks, and in order to understand what I was doing, I thought it would be useful to take a look at the contents of memory and registers to confirm my understand was correct. I looked around, and found that GDB can help with this.

I wrote an [introductory article to GDB](/2018/02/introduction-to-gdb/) a few months ago that you can look at to get the basics. This article is going to build on top of it.

## Debug information

In my introductory article, I used this command to assemble my program:

```bash
nasm -f elf64 -o example.o example.asm
```

The [elf64 (Executable and linkable format)](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format) parameter specifies the format of the output file. This will genearte a file will enough information so the Operating System can execute it, but it doesn't contain any information to help debugging. If we want our executable to contain debug information (information about the file and line number a program is executing) we need to say so when we assemble the program.

To see what are the formats for debug information available in your version of nasm, you can use:

```
nasm -f elf64 -y
```

The output when I ran it, was:

```
valid debug formats for 'elf64' output format are ('*' denotes default):
    dwarf     ELF64 (x86-64) dwarf debug format for Linux/Unix
  * stabs     ELF64 (x86-64) stabs debug format for Linux/Unix
```

The `dwarf` format is supposed to be an improvement over stabs, so I'm going to use that format:

```bash
nasm -f elf64 -g -F dwarf -o example.o example.asm
```

## Debugging with GDB

Let's look at the basics over the same program I used for the introduction:

```nasm
section .text
  global _start
_start:
  mov rax, 60
  mov rdi, 0
  syscall

```

If we save this in a a file named examble.asm, we generate the executable with these commands:

```bash
nasm -f elf64 -g -F dwarf -o example.o example.asm
ld -o example example.o
```

We can now start gdb with the program loaded:

```bash
$ gdb example
GNU gdb (Ubuntu 7.11.1-0ubuntu1~16.5) 7.11.1
Copyright (C) 2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from example...done.
(gdb)
```

We can use the `b` command to set a breakpoint. For now, let's set it at the `_start` symbol:

```gdb
(gdb) b _start
Breakpoint 1 at 0x400080: file example.asm, line 4.
```

Because the executable contains debug information, gdb can tell us in which file and line number the breakpoint was set. We can now run the program and it will stop at our breakpoint:

```gdb
(gdb) run
Starting program: /home/adrian/example

Breakpoint 1, _start () at example.asm:4
4	  mov rax, 60
```

The program stops at the first executable line of our program. We can step line by line using the `s` command:

```gdb
(gdb) s
5	  mov rdi, 0
(gdb) s
6	  syscall
(gdb) s
[Inferior 1 (process 11727) exited normally]
```

Use `q` to quit gdb.

## Inspecting registers

Writing assembly code, you will find yourself moving things in and out of regiters very often. It is then natural that debugging a program we might want to see their contents. To see the contents of all registers we can use `info registers` or the abbreviation `i r`. Using the same example program:

```gdb
(gdb) run
Starting program: /home/adrian/example

Breakpoint 1, _start () at example.asm:4
4	  mov rax, 60
(gdb) i r
rax            0x0	0
rbx            0x0	0
rcx            0x0	0
rdx            0x0	0
rsi            0x0	0
rdi            0x0	0
rbp            0x0	0x0
rsp            0x7fffffffdd10	0x7fffffffdd10
r8             0x0	0
r9             0x0	0
r10            0x0	0
r11            0x0	0
r12            0x0	0
r13            0x0	0
r14            0x0	0
r15            0x0	0
rip            0x400080	0x400080 <_start>
eflags         0x202	[ IF ]
cs             0x33	51
ss             0x2b	43
ds             0x0	0
es             0x0	0
fs             0x0	0
gs             0x0	0
```

By printing the registers we can see that the breakpoint takes effect before executing the line: `mov rax, 60`. In many cases we probably only want to see a specific register. To do this we just need to add the register name to the command: `i r <register>`:

```gdb
(gdb) s
5	  mov rdi, 0
(gdb) i r rax
rax            0x3c	60
```

The first column is the hexadecimal value (`0x3c`) and the second is decimal (`60`)

## Inspecting memory

print variable address in gdb:
info address exit_code

print variable value in gdb:
print exit_code



http://dbp-consulting.com/tutorials/debugging/basicAsmDebuggingGDB.html
