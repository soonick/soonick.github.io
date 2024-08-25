---
title: Aligned and packed data in C and C++
author: adrian.ancona
layout: post
# date: 2024-09-11
# permalink: /2024/09/aligned-and-packed-data-in-c-and-cpp/
tags:
  - c++
  - networking
  - programming
---

I was reading some networking code and I stumbled into something that looked similar to this:

```cpp
typedef struct __attribute__((__packed__)) {
  uint8_t a;
  uint16_t b;
  uint32_t c;
} some_t;
```

I had no idea what `__attribute__((__packed__))` meant, so I did some digging and learned a bit about data alignment.

<!--more-->

## Data alignment and padding

We usually hear that a CPU has a 32 bit or 64 bit architecture. The number of bits of the architecture corresponds to the `word size` the CPU uses. CPUs are optimized to retrieve data from memory in `word size` chunks, so compilers add `padding` to structs, so each field matches the `word size`.

When we create a struct like the following:

```cpp
struct my_struct {
  uint8_t a;
  uint64_t b;
};
```

We might expect the struct to occupy `72` bits of memory (9 bytes), but if we run this code, we will see it actually uses `16` bytes:

```cpp
#include <iostream>
#include <stdint.h>

struct my_struct {
  uint8_t a;
  uint64_t b;
};

int main() {
  std::cout << sizeof(my_struct) << "\n";
}
```

The reason is that the `a` field will be aligned with `b` by being padded with zeros. This can be more easily appreciated if we print a hex representation of the data in memory.

We can use this little program to do it:

```cpp
#include <cstdio>
#include <stdint.h>

struct my_struct {
  uint8_t a;
  uint64_t b;
};

int main() {
  my_struct a = {
    .a = 0,
    .b = 0,
  };
  a.a -= 1;
  a.b -= 1;

  const uint8_t *ptr = (uint8_t *)&a;
  for (uint8_t i = 0; i < sizeof(my_struct); i++) {
    printf("%02X ", ptr[i]);
  }

  printf("\n");
}
```

The output is:

```
FF 00 00 00 00 00 00 00 FF FF FF FF FF FF FF FF
```

Here, we can clearly see that there are `7` bytes that are used only for padding.

## Packed structs

There are some scenarios where we want to prevent the compiler from adding padding to our structs. A specific case is when we are mapping data coming from a network request. Network protocols try to keep messages as small as possible, which means, no padding is added.

When working with data coming from a network, it's common to read an array of bytes and map them to a struct. For the mapping to work correctly, we need to instruct the compiler to use the `packed` format. We do this with `__attribute__((__packed__))`, like so:

```cpp
struct my_packed_struct {
  uint8_t a;
  uint64_t b;
} __attribute__((__packed__));
```

We can make the same experiment as before, and we'll notice that the size of our struct is now `9` bytes and the hex output is:

```
FF FF FF FF FF FF FF FF FF
```

## Conclusion

The specifics of how data is stored in memory are often not important when writing software. I doubt I will be using this knowledge very frequently, but it's interesting to see the techniques available to transform data from the wire, to data that can be used by a program.

As usual, I've made a runnable version of the code snippets from this article in [my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/aligned-and-packed-data-in-c-and-cpp).
