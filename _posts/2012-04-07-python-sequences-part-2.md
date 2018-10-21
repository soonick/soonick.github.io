---
id: 593
title: 'Python Sequences - Part 2'
date: 2012-04-07T19:51:04+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=593
permalink: /2012/04/python-sequences-part-2/
tags:
  - programming
  - python
---
This post is a continuation of [Python Sequences](http://ncona.com/2012/03/python-sequences/ "Python Sequences - List").

## Concatenating Sequences

You can concatenate sequences using the plus (+) operator:

```python
>>> [1, 2] + [3, 4]
[1, 2, 3, 4]
```

## Multiplying Sequences

You can multiply a sequence by an integer number to repeat it the specified number of times:

```python
>>> [1, 2] * 3
[1, 2, 1, 2, 1, 2]
```

<!--more-->

## Membership

You can verify if a value is inside a sequence by using the **in** operator. This operator returns a Boolean specifying if the value was or not found:

```python
>>> 4 in [1, 3, 5, 7]
False
>>> 3 in [1, 3, 5, 7]
True
```

## Getting the length of a Sequence

```python
>>> len([1, 3, 5, 7])
4
```

## Getting lowest member of a Sequence

```python
>>> min([1, 3, 5, 7])
1
```

## Getting highest member of a Sequence

```python
>>> max([1, 3, 5, 7])
7
```
