---
id: 2417
title: JavaScript Numbers
date: 2015-01-21T18:41:42+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2417
permalink: /2015/01/javascript-numbers/
tags:
  - computer_science
  - algorithms
  - javascript
---
The title for this post might sound vague, but the reason I&#8217;m writing it is because in JavaScript this is true:

```
(.1 + .2) !== .3;
```

This makes my head explode so I want to understand better the reason for this.

## IEEE 754

It turns out that JavaScript only has one number type, unlike other programming languages that have many types(int, long, float, etc&#8230;). The type JavaScript uses is defined by the IEEE 754 standard for floating point numbers. This format is good because many hardware manufacturers ship they chips with support for this standard which makes operations on these numbers really fast.
  
<!--more-->

JavaScript uses an specific implementation of IEEE754 called binary64, which means that it uses 64 bits to represent any number. The 64 bits(0 to 63) available are used like this:

0 to 51(Fraction) &#8211; The actual number we will be working with
  
52 to 62(Exponent) &#8211; An exponent we will be applying to the fraction
  
63(Sign) &#8211; If this bit is on, it means this is a negative number

## Exponent

The exponent consists of 11 bits. Since negative and positive exponents are possible, the value 1023 is used to represent 0:

```
01111111111
```

Any value lower than that number is considered negative(01111111110 = -1) and any value greater is considered positive(10000000000 = 1). Having zero(00000000000) as the exponent has a special meaning. I&#8217;ll explain about this later.

## Fraction

This is the actual number you want, but it is not as simple as that. You have 52 bits available that you can fill with any number you want, for example:

```
0000000000000000000000000000000000000000000000000010
```

This represents 2 in binary but when this value is used to calculate the actual number this will be converted to:

```
1.000000000000000000000000000000000000000000000000001
```

Which is not what we want. There is one exception to this rule, and that is when the exponent is 0. If the exponent is 0 then the number will be treated as:

```
0.000000000000000000000000000000000000000000000000001
```

There is something very important to point here, and that is that these numbers are all binary, and binary fractions are different than decimal fractions. Here are some examples:

```
0.1 = (1/2) = 2^-1
0.01 = (1/4) = 2^-2
0.001 = (1/8) = 2^-3
```

## (.1 + .2) !== .3;

Now, lets see if we can with all this information make sense of the problem.

Lets see how .1 is represented in IEEE 754 notation. If we look at our binary fractions we have that:

```
1/8 = 0.125
1/16 = 0.0625
```

Which means that .001 is too big and .0001 is not big enough. This already points to trouble since there might not be an exact representation of that value. Lets see how close we can get with the 52 bits available:

2^-4 + 2^-5 + 2^-8 + 2^-9 + 2^-12 + 2^-13 + 2^-16 + 2^-17 + 2^-20 + 2^-21 + 2^-24 + 2^-25 + 2^-28 + 2^-29 + 2^-32 + 2^-33 + 2^-36 + 2^-37 + 2^-40 + 2^-41 + 2^-44 + 2^-45 + 2^-48 + 2^-49 + 2^-52 = 0.0999999999999998667732370449812151491641998291015625

or

2^-4 + 2^-5 + 2^-8 + 2^-9 + 2^-12 + 2^-13 + 2^-16 + 2^-17 + 2^-20 + 2^-21 + 2^-24 + 2^-25 + 2^-28 + 2^-29 + 2^-32 + 2^-33 + 2^-36 + 2^-37 + 2^-40 + 2^-41 + 2^-44 + 2^-45 + 2^-48 + 2^-49 + 2^-51 = 0.100000000000000088817841970012523233890533447265625

The second number is the closest to 0.1 so it will be the one I will use:

```
0001100110011001100110011001100110011001100110011010
```

Now, because this number is an integer and we actually want it to be fraction we have to use the exponent to place it in the correct position after the dot, remembering the rules we already know about the exponent. We want to move it 4 positions to the left so it becomes:

```
1001100110011001100110011001100110011001100110100000
```

We lost one 1 at the left, but this will be put back automatically because the exponent won&#8217;t be 0.

The exponent will be the -4 because we want to move the decimal point 4 times to the right to get the number we are looking for. Following the exponent rules, -4 is represented like this:

```
01111111011
```

Our final number in memory will look like this:

```
0 01111111011 1001100110011001100110011001100110011001100110100000
```

In decimal it would be close to 0.100000000000000088817841970012523233890533447265625, which is not identical to 0.1.

If we follow the same procedure for 0.2 and make the addition we can see that 0.1 + 0.2 !== 0.3.
