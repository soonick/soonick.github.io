---
title: Null terminated and length prefixed strings
author: adrian.ancona
layout: post
date: 2020-04-15
permalink: /2020/04/null-terminated-and-length-prefixed-strings/
tags:
  - algorithms
  - computer_science
  - data_structures
---

## Null terminated strings

[Null terminated strings](https://en.wikipedia.org/wiki/Null-terminated_string) (also called C strings) store a string as a sequence of characters terminated by a null character (`\0`).

For example, if we have a variable with the string `taco`, in a character array, it would look like this:

```
index: 0 | 1 | 2 | 3 | 4
value: t | a | c | o | \0
```

Notice that even though, `taco` is only 4 characters, it is necesary to allocate an extra byte for the null characer (`\0`).

`C strings` have two main advantages:

- Single byte overhead
- There is no limit on the length of the string

And two main disadvantages:

- To find the lenght of a string, it has to be searched character by character until `\0` is found.
- It isn't possible to store a `\0` character as part of the string

Another less tangible issue with null terminated strings is that they are error prone:

- If we try to store binary data in a string, the data will be truncated if it contains a null character, and we will not receive any warning about this
- Buffer overflows caused by forgetting to add a `\0` character at the end of a string have been the cause of security vulnerabilities in many systems

## Length prefixed strings

[Length prefixed strings](https://en.wikipedia.org/wiki/String_(computer_science)#Length-prefixed) (Also called UCSD strings or Pascal strings) work by prefixing the actual string with its length.

If a system is to use length prefixed strings, it needs to decide how the length is going to be stored. If we decided to store the length in the first byte it would look like this:

```
index: 0 | 1 | 2 | 3 | 4
value: 4 | t | a | c | o
```

As in the null terminated example, the overhead is a single byte. The problem is that the maximum number that can be stored in a byte is 255, so a string longer than this value can't be represented on this system.

Modern computers have a lot more memory than they did before, so instead of storing the length on the first byte, systems use 16, 32 or 64 bits, which increases the limits to `65,536`, `4,294,967,295` or `9,223,372,036,854,775,807` characters.

In this case the main benefits are:

- Finding the length of a string is a constant time operation
- Can contain any character, so they can be used to store binary data
- Since the length is always known, it's harder to haver buffer overflows

Disadvantages:

- Extra overhead of up to 64 bits

## Conclusion

Different systems handle strings in different ways. In some cases, it is necessary or useful to know the internals (like in C, for example), while in others they are hidden from you (JavaScript for example).

In any case, understanding how strings are stored in memory can serve as a base for understanding how computers store files, which is something I'll cover in another article.
