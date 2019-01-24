---
title: Assembly - Addressing modes and common instructions
author: adrian.ancona
layout: post
tags:
  - computer_science
  - programming
  - assembly
---

In a previous article I showed [how to assemble a program](/2019/01/introduction-to-assembly-assembling-a-program/) using nasm. In this article I'm going to explore different ways to access data and explore some instructions.

## Variables

The .data section (These are called segments: code segment and data segment)

The format to define initialized data:

[variable-name]    define-directive    initial-value   [,initial-value]...

```viml
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

When we define a variable, the variable name will be replaced with the assigned memory address. If we want to access the value in that memory address we need to use brackets `[]`

Defining multiple (arrays):
some_data dq 1, 10, 100, 1000

strings:
hello db 'hello'

null terminated string:
hello db 'hello', 0














## Instructions

Instructions are how we tell the computer to do something. The exact number of instructions on the x64 architecture is hard to find, but it might be somewhere close to one thousand. I'm obviously not cover all of them.

An instruction consists of an `opcode` and optionally 1 or more `operands`:

```
mov rax, 60
```

The code above is a single instruction. The opcode is `mov` and it receives 2 operands `rax` and `60`. What this instruction does is move the value `60` to the `rax` register.

## Addressing modes

One of the most fundamental things about assembly is knowing which addressing mode to use. An addressing mode is a way to specify which values are going to be use as operands for and instruction.

### Immediate mode

The example I showed above, uses the `immediate addressing mode`:

```
mov rax, 60
```

This mode is very simple because there is no indirection. The `rax` register will be set to `60`. Te value `60` is called an immediate constant. Immediate constants can be specified in decimal, binary, octal or hexadecimal. These instructions all do the same:

```
mov rax, 60 ; decimal
mov rax, 0b111100 ; binary
mov rax, 0o74 ; octal
mov rax, 0x3C ; hexadecimal
```

### Register mode

This mode is also very easy to understand. Information will be copied from one registry to the other:

```
mov rax,rbx
```

In this case, the value of `rax` will be set to whichever value is currently in `rbx`.

### Register indirect mode

Things get a little more complicated very quickly:

```
mov rax,(%rbx)
```

In this case we are still setting `rax`. To find the value that is being set, we first need to go to `rax`. `rax` will contain a memory address. Then we need to go to that memory address to find the value.

##### Picture of the memory stuff

This is called `XXX addressing mode`











 If you have a memory address in a register and you want to use the data in that memory address, you can use:

```
(%rax)
```

You can also use a memory address in a register as a starting point, but then move up or down in memory:

```
```

Register indirect mode. In this scenario, the register contains a memory address. The contents of that memory address are going to be used in the operation:

```
[rax]
```

## Machine language

Modern computers work by performing a sequence of operations in a given order. The operations the computer can perform are very simple, but can be combined to do very complex tasks. Some examples of the operations a computer can perform are:

- Logical operations (AND, OR, etc..)
- Matematical operations
- Move data from one location to another

How a computer does these operations and how we can instruct it to do so, varies depending on the CPU design. The most common option for teaching assembly is the x86 architecture, because it's the most commonly used. An example machine instruction in x86 is:

```asm
00110010 00001100 00100101 00010010 00000000 00000000 00000000
```

https://en.wikibooks.org/wiki/X86_Assembly/Machine_Language_Conversion

These 56 bits tell an x86 CPU to take an action. More specifically, it tells it to XOR CL (The lowest 8 bits of the counter register) with the contents of address `00010010`



http://cs.lmu.edu/~ray/notes/nasmtutorial/
https://0xax.github.io/asm_1/
