---
id: 2235
title: Add one to a number without using plus or minus sign
date: 2016-02-10T18:02:57+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2235
permalink: /2016/02/add-one-to-a-number-without-using-plus-or-minus-sign/
categories:
  - Computer science
tags:
  - algorithms
  - javascript
  - programming
---
I got asked this question in a code interview and I wanted to make sure my answer was good. Without the pressure of being in an interview I see the problem more clearly and the problem seems pretty easy now.

Lets look at the basics of adding in binary:

```
 0         1       1
+0        +0      +1
---       ---     ---
 0         1      10
```

<!--more-->

Now lets look at how it looks to add 1 to a few numbers:

```
1000       1111      10011
  +1         +1         +1
----      -----      -----
1001      10000      10100
```

You probably noticed a pattern from those examples. The way you add 1 to a number is by finding the rightmost 0, turning it to 1 and then turning all numbers to the right to 0. Here is an example of an implementation:

```js
function addOne(num) {
    var pos = 1;

    // Find the first 0
    // Parentheses are important here
    // !== has higher precedence than &
    while ((pos & num) !== 0) {
        pos = pos << 1;
    }

    // Switch the 0 to a 1
    num = num | pos;

    // Switch all 1s to the right
    pos = pos >> 1;
    while (pos !== 0) {
        num = num ^ pos;
        pos = pos >> 1;
    }

    return num;
}
```

The complexity is O(n) where n is the number of bits in the number. For the worst case scenario there will only be 1s in the number and you will have to go through all of the bits.
