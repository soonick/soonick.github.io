---
id: 497
title: Introduction to Python
date: 2012-01-26T01:19:43+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=497
permalink: /2012/01/introduction-to-python/
categories:
  - Python
tags:
  - programming
  - python
---
I have been wanting to learn python for some time, mostly because a lot of my favority open source projects use it and seek people with that expertise, so finally here I am taking my first steps with python.

There are two things that really catch my eye about python:
	  
&#8211; Doesn&#8217;t use brackets to group statement
	  
&#8211; Doesn&#8217;t use semicolons to end lines

These two semantic rules of python freak me out a little, maybe because I am so used to brackets and semicolons that I can&#8217;t imagine a programming language that doesn&#8217;t use them. But they claim this makes programming easier, so I hope they are right.

<!--more-->

## Installation

There is not really much I can say about installation because when I checked I already had the python interpreter installed.

I imagine that if you don&#8217;t have it doing this in ubuntu would be enough:

```
sudo apt-get python
```

You can verify that you have it installed by typing **python** in a terminal. You will get a >>> prompt, use **Ctrl+D** to quit the prompt.

## An easy example

The first examples seen in python&#8217;s documentation are run in interactive mode (from the >>> prompt), but since I don&#8217;t think I will be using that mode a lot in real life, I will write my example in a file called example.py.

I will use the same example used on python&#8217;s documentation, the fibonacci series (if you don&#8217;t know it go check wikipedia, it is a really simple algorithm).

```python
a = 0
b = 1
x = 0
while b < 1000:
    # Automatically adds \n character after printing the value of the variable
    print b
    x = b
    b = a + b
    a = x
```

Python&#8217;s documentation does the same thing in a more efficient but also more confusing (at least for a beginner) way:

```python
# This weird little piece of code is the same as saying
# a = 0
# b = 1
# it takes all variables at the left of the equal sign and assigns
# all values at the right of the equal sign in their corresponding
# positions
a, b = 0, 1
while b < 10:
    print b
    # This next piece of code is even weirder than the last assignation.
    # With a little python magic they avoid the use of a helper variable.
    # The python interpreter first solves a+b, then assigns b to a and
    # then assigns the value of the operation it made (a+b before modifying a)
    # to b
    a, b = b, a+b
```

Now we have the code in our example.dev file we can execute it just by typing in a terminal:

```
python example.py
```

## Conclusions

I didn&#8217;t expect python to be so different from other programming languages I have used in the past, but I really got a big surprise. I have heard a lot of good things about python, so I don&#8217;t plan to be give up just because the syntax is a little different. Overall the experience has been eye opening and I can&#8217;t wait to learn more about the language.
