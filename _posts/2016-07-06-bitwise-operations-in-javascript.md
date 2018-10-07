---
id: 3703
title: Bitwise operations in Javascript
date: 2016-07-06T09:17:57+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3703
permalink: /2016/07/bitwise-operations-in-javascript/
categories:
  - Javascript
tags:
  - algorithms
  - javascript
  - programming
---
I&#8217;ve been doing a few algorithm exercises that deal with binary numbers lately. Since my language of choice for algorithm problems is JavaScript and I had in the past read a little about [how JavaScript numbers work](http://ncona.com/2015/01/javascript-numbers/), I was really confused to find out that binary operations actually work, since JavaScript numbers are represented with an exponent-fraction notation.

A quick search gave me the answer to this question. When you do binary operations against a number this will be converted to an integer in two&#8217;s complement. Another interesting thing is that even though JavaScript numbers are built using 64 bits, they will be converted to 32 bits when doing binary operations. Lets see how these two factors affect our operations.

<!--more-->

## 32 bits

To make this example simple, lets assume we are talking about unsigned numbers. If we have 32 bits the highest number we can represent is: 4,294,967,295 . If we added one to this number, an integer overflow would happen and all the bits would be converted to 0s. Lets try that:

```
> 4294967295 + 1
4294967296
```

We can see that no overflow happened. This is because we are using the + operator to make an addition between two JavaScript numbers that are 64 bits. The representation of this number is possible using 64 bits, but not using 32 bits. Lets now grab this 64 bit number and try to do a binary operation on it:

```
> 4294967296 | 1
1
```

The result this time is not correct. The correct answer should be 4,294,967,297, since we are basically setting the last bit, which was 0 to 1. The reason the given answer is 1 is because the number is too big to be represented with 32 bits and after it is truncated it looks like a 0:

```
> 0 | 1
1
```

## Two&#8217;s complement

In my previous explanation I simplified the concept a little by assuming we were using unsigned integers. The truth is that the number is converted to a two&#8217;s complement representation, which allows us to have both positive and negative numbers.

To make the explanation simpler, lets assume we have a number type that uses 8 bits. If this was an unsigned number, we should be able to represent numbers from 0 to 255 (00000000 to 11111111). All possible combinations are used and there is no room for unsigned numbers. If you added 1 to the highest number, an overflow would happen and the result would become 0.

Lets say we really want to be able to represent signed integers with our number type. One easy way of doing this is by using two&#8217;s complement. There is of course a drawback. We still have only 8 bits so we will have to sacrifice some space to represent negative numbers. Using two&#8217;s complement we can represent the number 0 (00000000) and positive numbers from 1 to 127 (00000001 to 01111111) and from -1 to -128 (11111111 to 1000000).

The positive numbers are very simple. The most significant bit will be set to 0 and all the other bits represent the number the same way as an unsigned binary number. Negative numbers require a little more explanation but are also very simple to understand. One interesting thing is that the highest number (01111111) is followed by the lowest possible number (10000000). This might seem confusing but is actually not that complicated.

The way you convert a positive number into a negative number is by taking the one&#8217;s complement (i.e. Performing a binary not operation in the number) and then adding 1. Lets try it with the highest possible number, 127.

```
127      -> 01111111
~127     -> 10000000
~127 + 1 -> 10000001
-127     -> 10000001
```

Now lets see how it works with the number 1:

```
1      -> 00000001
~1     -> 11111110
~1 + 1 -> 11111111
-1     -> 11111111
```

As you can see from here, with this notation, performing binary operations is pretty simple:

```
10000001 - 00000001 = 10000000
-127 - 1 = -128

11111111 + 00000001 = 00000000
-1 + 1 = 0
```

Now that we understand how two&#8217;s complement works, and we know that JavaScript performs binary operations using 32 bits, it is clearer what happens to our numbers.
