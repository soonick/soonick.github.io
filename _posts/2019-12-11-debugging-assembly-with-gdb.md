---
title: Debugging assembly with GDB
author: adrian.ancona
layout: post
date: 2019-12-11
permalink: /2019/12/debugging-assembly-with-gdb/
tags:
  - computer_science
  - programming
  - assembly
  - debugging
---

I wrote a couple of articles about assembly before, and in order to understand what I was doing, I thought it would be useful to take a look at the contents of memory and registers to confirm my understanding was correct. I looked around, and found that GDB can help with this.

I wrote an [introductory article to GDB](/2018/02/introduction-to-gdb/) a few months ago that you can check to get the basics. This article is going to build on top of it.

## Debug information

In my [introduction to assembly](/2019/01/introduction-to-assembly-assembling-a-program/), I used this command to assemble my program:

```bash
nasm -f elf64 -o example.o example.asm
```

<!--more-->

The [elf64 (Executable and linkable format)](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format) parameter specifies the format of the output file. This will generate a file with enough information so the Operating System can execute it, but it doesn't contain any information to help debugging. If we want our executable to contain debug information (information about the file and line number a program is executing) we need to say so when we assemble the program.

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

Let's look at the basics over the same program I used for my introduction to assembly article:

```nasm
section .text
  global _start
_start:
  mov rax, 60
  mov rdi, 0
  syscall
```

If we save this in a file named example.asm, we can generate the executable with these commands:

```bash
nasm -f elf64 -g -F dwarf -o example.o example.asm
ld -o example example.o
```

We can now start gdb with the program loaded:

```bash
$ gdb example
(gdb)
```

We can use the `b` command to set a breakpoint. For now, let's set it at the `_start` symbol:

```
(gdb) b _start
Breakpoint 1 at 0x400080: file example.asm, line 4.
```

Because the executable contains debug information, gdb can tell us in which file and line number the breakpoint was set. We can now run the program and it will stop at our breakpoint:

```
(gdb) run
Starting program: /home/adrian/example

Breakpoint 1, _start () at example.asm:4
4	  mov rax, 60
```

The program stops at the first executable line of our program. We can step line by line using the `s` command:

```
(gdb) s
5	  mov rdi, 0
(gdb) s
6	  syscall
(gdb) s
[Inferior 1 (process 11727) exited normally]
```

Use `q` to quit gdb.

## Inspecting registers

Writing assembly code, you will find yourself moving things in and out of registers very often. It is then natural that debugging a program we might want to see their contents. To see the contents of all registers we can use `info registers` or the abbreviation `i r`. Using the same example program:

```
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

```
(gdb) s
5	  mov rdi, 0
(gdb) i r rax
rax            0x3c	60
```

The first column is the hexadecimal value (`0x3c`) and the second is decimal (`60`)

## Inspecting memory

Let's introduce some variables to our program:

```nasm
section .data
  exit_code dq 0
  sys_call dq 60

section .text
  global _start

_start:
  mov rax, [sys_call]
  mov rdi, [exit_code]
  syscall
```

If we stop gdb at `_start`, we can inspect the variables in the program:

```
(gdb) print (int) sys_call
$1 = 60
```

Note that we need to cast the variable to the correct type or we'll get an error:

```
(gdb) print sys_call
'sys_call' has unknown type; cast it to its declared type
```

Another thing we can do is get the memory address sys_call refers to:

```
(gdb) info address sys_call
Symbol "sys_call" is at 0x402008 in a file compiled without debugging
```

We can also see the data at a memory address using an asterisk (`*`):

```
(gdb) print (int) *0x402008
$4 = 60
```

## Conclusion

This article shows how to use gdb to debug a simple assembly program. Most commands are similar to the ones used for debugging any other programming language, but we also go over how to access registers and memory addresses, which is more commonly needed when working at assembly level.
