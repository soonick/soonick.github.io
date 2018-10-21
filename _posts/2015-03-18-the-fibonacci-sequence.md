---
id: 2230
title: The Fibonacci sequence
date: 2015-03-18T17:00:59+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2230
permalink: /2015/03/the-fibonacci-sequence/
tags:
  - computer_science
  - algorithms
  - javascript
  - programming
---
The Fibonacci sequence is a sequence of numbers starting with 0 and 1 and then adding the sum of the two last numbers at the end of the sequence:

```
0, 1, 1, 2, 3, 5, 8, 13, 21, 34, ...
```

The mathematical representation of the Fibonacci sequence is:

```
F(n) = F(n-1) + F(n-2)
```

<!--more-->

Computing a Fibonacci sequence is one of the first things we learn while learning to program. A simple recursive implementation looks like this:

```js
function fib(n) {
    switch(n) {
        case 0:
            return 0;
        case 1:
            return 1;
        default:
            return fib(n -1) + fib(n -2);
    }
}
```

Although this implementation is very straight forward it has two disadvantages: It&#8217;s time complexity is fib(n), which is very high for such a simple problem. Since it uses recursion there is a risk of running out of stack space.

We can improve the time complexity(from fib(n) to n) at the cost of n space complexity by using memoization:

```js
function fib(n) {
    var cache = {};

    function calculate(n) {
        if (cache[n]) {
            return cache[n];
        }

        switch(n) {
            case 0:
                return 0;
            case 1:
                return 1;
            default:
                cache[n] = calculate(n - 1) + calculate(n - 2);
                return cache[n];
        }
    }

    return calculate(n);
}
```

A better approach is to use an iterative version with a time complexity of n and a constant space complexity:

```js
function fib(n) {
    if (n === 0) {
        return 0;
    }

    if (n === 1) {
        return 1;
    }

    var secondLast = 0;
    var last = 1;
    var tmp;

    for (var i = 1; i < n; i++) {
        tmp = secondLast;
        secondLast = last;
        last = tmp + secondLast;
    }

    return last;
}
```

There are a couple more magical ways to get a Fibonacci number.

## Fast doubling

This method is based on the fact that:

```
F(2n) = Fn(2F(n+1) - F(n))
F(2n + 1) = F(n+1)^2 + F(n)^2
```

The complexity of this algorithm is log n. Here is the implementation:

```js
function fib(n) {
    function fibTuple(n) {
        if (n <= 0) {
            return [0, 1];
        }
        var ab = fibTuple(Math.floor(n / 2));
        var a = ab[0], b = ab[1];
        var c = a * (2 * b - a);
        var d = b * b + a * a;
        if (n % 2 == 0) {
            return [c, d];
        } else {
            return [d, c + d];
        }
    }

    switch(n) {
        case 0:
            return 0;
        case 1:
            return 1;
        default:
            return fibTuple(n-1)[1];
    }
}
```

You can also get the Fibonacci number in constant time if you [use rounding](http://en.wikipedia.org/wiki/Fibonacci_number#Computation_by_rounding):

```js
function fib(n) {
    var sqrt5 = Math.sqrt(5);
    var phi = (sqrt5 + 1) / 2;
    return Math.round(Math.pow(phi, n) / sqrt5);
}
```
