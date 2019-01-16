---
title: Introduction to assembly - Assembling a program
author: adrian.ancona
layout: post
date: 2019-01-30
permalink: /2019/01/introduction-to-assembly-assembling-a-program/
tags:
  - computer_science
  - programming
  - assembly
---


I have been working on learning C++ for some time now. I can write and read most code, but there are still a lot of things I don't understand. One thing that I have noticed about good C++ developers is that they usually know a lot about compilers and the operating system in which they are working. Following their example, I'm going to try to learn about those subjects too.

I'm writing an article about assembly because I have found in some occasions, C++ code being explained in reference to the generated assembly code. Although I had an assembly class in college, I don't really rememeber anything, so I will have to start from the bottom.

In this article I'm going to be using the x64 (also known as x86-64) architecture, since it's the architecture most commonly used by modern home computers and servers (for example Intel Core i7).

<!--more-->

## CPU registers

Before we can write any code in assembly, it is necessary to get a little familiar with how CPUs work. A foundational part of this is getting to know the registers.

Registers are a space in the CPU that can be used to hold data. In an x64 CPU, each register can hold 64 bits.

The most common registers are the general-purpose registers. They are called general-purpose because they can be used to store any kind of data. x64 defines 16 of these registers: `rax`, `rbx`, `rcx`, `rdx`, `rsi`, `rdi`, `rbp`, `rsp`, `r8`, `r9`, `r10`, `r11`, `r12`, `r13`, `r14` and `r15`

There is another kind of registers called special-purpose registers. These registers have a specific pupose. To give an example, `rip` is called the instruction pointer; it always points to the next instruction to be executed by the program. Another example is `rflags`; this register contains various flags that change depending on the result of an operation; the flags tell you things like if the result was zero, there was a carry or an overflow, etc. There are more special purpose registers, but I won't explore them in this article.

## Intel vs AT&T

There are two ways to write assembly; Intel syntax, used mostly in the windows world and AT&T syntax, used everywhere else. I mostly use Linux, so I will learn the AT&T syntax.

Here is an example instruction in Intel:

```nasm
mov $1, %rax
```

And the same instruction in AT&T:

```nasm
mov rax, 1
```

Both instructions set the registry `rax` to the value `1`. We can see in the Intel case that the value `1` is prefixed with `$` and the registry name is prefixed with `%`. The order of the parameters is also different.

In the rest of the article I will use only AT&T syntax.

## Installing an assembler

Assembly is a low level language where we tell the computer exactly which instructions to execute, but the code we write in a text editor has to be transformed into a binary file that the OS and processor can execute. An assembler takes care of this step.

Nasm is one of the most popular assemblers out there. It has great support for `x64` and works in multiple platforms. To install nasm in Ubuntu, you can do:

```bash
sudo apt-get install nasm
```

You can verify it installed correctly:

```bash
$ nasm -v
NASM version 2.11.08
```

## Assembling a program

The general format for assembling a program is:

```bash
nasm -f <format> -o <output file> <source file>
```

The `format` is the platform for which the program will be assembled (windows, linux, etc). To see the list of supported formats you can use:

```bash
nasm -hf
```

Since I'm using Linux, I'll use something like this to assemble my programs:

```bash
nasm -f elf64 -o example.o example.asm
```

There is one more step before our program is ready to run. We need to link it. Linking a program is helpful to combine many object files together and is necessary to create the executable we need. For linking a program, I'll use GNU linker (`ld`):

```bash
ld -o <executable name> <object file>
```

We can try these steps with an empty file and see what happens:

```bash
touch example.asm
nasm -f elf64 -o example.o example.asm
ld -o example example.o
```

If you run those commands, you will notice that the assembly step finishes successfully, but there is an error in the linking step:

```
ld: warning: cannot find entry symbol _start; not setting start address
```

An assembly program needs a `_start` entry point. Let's modify our example so it works:

```nasm
section .text
  global _start
_start:
```

This is the tiniest program that can be linked successfully, but it does nothing. Not only, it does nothing, but it fails to execute:

```bash
$ ./example
bash: ./example: cannot execute binary file: Exec format error
```

Adding an instruction to our program fixes this problem:

```nasm
section .text
  global _start
_start:
  mov rax, 1
```

But we get a segmentation fault:

```bash
$ ./example
Segmentation fault (core dumped)
```

The reason we get a segmentation fault is that the program doesn't end correctly. In higher level programming languages, the `runtime` (the compiler) takes care of this. In assembly, this needs to be done by the programmer. To do this, we need to use syscall `60` (sys_exit). The interface for `sys_exit` is:

```
%rdi int error_code
```

What this means is that is takes a single int argument in the `rdi` register. This argument is the exit code for the program. A successful program should finish with code 0.

Let's make our program end successfully:

```nasm
section .text
  global _start
_start:
  mov rax, 60
  mov rdi, 0
  syscall
```

Looking at the program, you'll notice that we first have to move the value `60` (The id of `sys_exit`) to the `rax` register. This is necessary to execute any system call. The next step is to populate the correct registers with the arguments that system call needs. In this case, it only needs the exit code in `rdi`. Finally, execute the system call.

This program can be executed, and although it doesn't do anything, it will end successfully:

```bash
$ ./example
$ echo $?
0
```

We have now successfully assembled our first program. In future posts I will explore how to do more interesting stuff with assembly.
