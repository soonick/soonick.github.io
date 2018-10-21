---
id: 580
title: Python Sequences
date: 2012-03-30T05:47:52+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=580
permalink: /2012/03/python-sequences/
tags:
  - programming
  - python
---
Sequences is the name that python gives to a data structure that contains a &#8220;sequence&#8221; of elements, each with a numeric consecutive index. The sequence is very similar to an array in other programming languages. The first index number is 0 and they increment by one as elements are added.

Sequences can contain numbers, strings, other sequences, etc&#8230;

## Creating a sequence

You can define a sequence like a list of elements separated by commas and listed inside square brackets ([]):

```python
ages = [13, 15, 22, 23, 56, 12, 33]
```

<!--more-->

And then you can access each element using it&#8217;s index number:

```python
>>> print ages[0]
13
```

## Indexing

In most programming language you can access an array element by defining the index number of the element you want (as the last code example). Python adds some functionality to the way sequences work.

Because sequences always start with 0 and increment just by one for each element, there is no way to have an element with a negative index. So when you try to access an element in a negative index what python does is start counting the elements starting from the last one:

```python
>>> print ages[-1]
33
```

It is worth mentioning that the last element of a sequence is -1 and not -0. This is because in mathematics 0 can&#8217;t have a sign.

## Slicing

Python also provides a very easy way to get just some elements from a sequence. You can do this by specifying a range, and python will give you just the element you want.

```python
ages = [13, 15, 22, 23, 56, 12, 33]
print ages[2:4]
[22, 23]
```

Here we told python that we wanted to get all element starting from the index 2 until the index 4. It is interesting and important to notice that the first index you specify will be included in the returned sequence (inclusive), but the last one wont (exclusive). So in the example we just got elements in indexes 2 and 3. This brings the question: What do I do if I want to get the last element in the returned sequence? Well, we can accomplish this by having the second parameter be the last index + 1:

```python
ages = [13, 15, 22, 23, 56, 12, 33]
print ages[4:7]
[56, 12, 33]
```

You can also use negative indexes to start counting from the end:

```python
ages = [13, 15, 22, 23, 56, 12, 33]
print ages[-3:-1]
[56, 12]
```

But this brings another question: How can I access the last element from a sequence if the first parameter is a negative index and using -1 as the second parameter brings you the second last? Python allows you to omit any of the parameters of the sequence slice. If you omit the first parameter it will start from the first element, if you omit the last parameter it will end at the last element:

```python
ages = [13, 15, 22, 23, 56, 12, 33]
print ages[-3:]
[56, 12, 33]
print ages[:3]
[13, 15, 22]
print ages[:]
[13, 15, 22, 23, 56, 12, 33]
```

As you saw, we can omit both parameters and the whole sequence will be returned.

There is one more thing you can do when slicing. You can specify the step size. This means that if you want to only get odd indexes you can do this:

```python
ages = [13, 15, 22, 23, 56, 12, 33]
print ages[::2]
[13, 22, 56, 33]
```

The step size can&#8217;t be zero, but it can be negative, which would cause the sequence to get the elements in backwards order (you would have to give the two fist parameters in backwards order too):

```python
ages = [13, 15, 22, 23, 56, 12, 33]
print ages[6:0:-1]
[33, 12, 56, 23, 22, 15]
print ages[::-1]
[33, 12, 56, 23, 22, 15, 13]
```

## Strings as sequences

As a final note for this article I want to comment that all strings in python can use the same operations as the sequences:

```python
>>> word = 'hello world'
>>> print word[0:5]
hello
```
