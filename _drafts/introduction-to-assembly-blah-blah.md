---
title: Introduction to assembly - Blah Blah
author: adrian.ancona
layout: post
tags:
  - computer_science
  - programming
  - assembly
---

In a previous article I showed [how to assemble a program](/2019/01/introduction-to-assembly-assembling-a-program/) using nasm. In this article I'm going to explore different ways to access data and explore some instructions.

## Instructions

Instructions are how we tell the computer to do something. The exact number of instructions on the x64 architecture is hard to find, but it might be somewhere close to one thousand. I'm obviously not cover all of them.

An instruction consists of an `opcode` and optionally 1 or more `operands`:

```
mov rax, 60
```

The code above is a single instruction. The opcode is `mov` and it receives 2 operands `rax` and `60`. What this instruction does is move the value `60` to the `rax` register.

## Addressing modes

One of the most fundamental things about assembly is knowing which addressing mode to use. An addressing mode is a way to specify which values are going to be use as operands for and instruction.

The example I showed above, uses the `immediate addressing mode`:

```
mov rax, 60
```

This mode is very simple because there is no indirection. The `rax` register will be set to `60`. Te value `60` is called an immediate constant. Another simple addressing mode is the `register addressing mode`:

```
mov rax,rbx
```

In this case, the value in a registry is used. `rax` will be set to whichever value is currently in `rbx`. Things get a little more complicated very quickly:

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
