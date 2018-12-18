I have been working on learning C++ for some time now. I can write and read code most of the time, but there are still a lot of things I don't understand. One thing that I have noticed about good C++ developers is that they usually know a lot about compilers and the operations system in which they are working. Following that example, I'm going to try to learn about those subjects too.

I'm writing an article about assembly because I have found in a few occasions things being explained in reference to the generated assembly code. Although I had an assembly class in college, I don't really rememeber anything, so I will have to start from the bottom.

## CPU registers

Before we can write any code in assembly, it is necessary to get familiar with how the CPU works. A foundational part of this is getting familiar with the registers.

CPUs can't directly access data in RAM, to make data accesible to the CPU it has to first be moved to a register. Once the data is in a register, the CPU can process it and move it to other registers or back to RAM.

The x86-64 (also known as x64) architecture, is the architecture most commonly used by modern home computers or servers (for example Intel Core i7), so it's the one I'm going to be focusing on.

x64 has 16 general purpose registers:

- rax
- rbx
- rcx
- rdx
- rsi
- rdi
- rbp
- rsp
- r8
- r9
- r10
- r11
- r12
- r13
- r14
- r15

These registers are 64 bits long, but they can be split to work with 32, 16 or 8 bits.

## Instructions

The exact number of instructions on the x64 architecture is hard to find, but it might be somewhere close to 1000 instructions. In this section I'm just going to show a few examples.

Each instruction has a documented behavior that can be used depending on what the programmer wants to achieve. One of the most basic instructions is `add`, for example:

```asm
add eax,14
```

The line above is assembly code. The word `add` is an instruction. It works a little different depending on the arguments, but in this case it will grab the value in eax and add 14 to it. The result will be stored in eax.

https://software.intel.com/en-us/articles/introduction-to-x64-assembly
https://www.nayuki.io/page/a-fundamental-introduction-to-x86-assembly-programming

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



## What is assembly?


