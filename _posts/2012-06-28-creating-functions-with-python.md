---
id: 723
title: Creating functions with Python
date: 2012-06-28T04:36:14+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=723
permalink: /2012/06/creating-functions-with-python/
tags:
  - programming
  - python
---
We can create functions on Python using the **def** keyword.

```python
def printSomething():
    print "something"
```

Functions in python can have arguments and return statements as in most languages.

```python
def addNumbers(number1, number2):
    return number1 + number2
```

<!--more-->

Passing of arguments is generally done by value, but if we use a mutable data structure like a sequece they are passed by referece:

```python
def byValue(a):
    a = 'else'

def byReference(b):
    b[0] = 'changed'

c = 'something'
byValue(c)
print c
something


d = ['value', 'value2']
byReference(d)
print d
['changed', 'value2']
```

One important thing to mention here is that in Python there is not way to pass a number or a string by reference.

We can assign default values to our arguments using this syntax:

```python
def someFunction(argument='some value', another='another value'):
    print argument + '-' + another

someFunction()
some value-another value
```

## Keyword arguments

This python functionality allows us to pass arguments to a function in any order we want but specifying what value we want to assign to what function argument.

```python
def someFunction(something, else):
    print something + '-' + else

someFunction('one', 'two')
one-two

someFunction(else='two', something='one')
one-two
```

As we can see from the example, by specifying the names of the function arguments we can pass the parameters in any order we want. Combining this functionality with default argument values can be very useful.

## Passing a variable amount of arguments to a function

There are times when we want to pass a variable amout of arguments to a function. We can do this by using the `*` operator.

```python
def printNumbers(*numbers):
    print numbers

printNumbers(1, 2, 3, 4)
(1, 2, 3, 4)
```

In the example printing numbers returns a tuple with all the values passed to the function.

We can also use the `**` operator to get keyword arguments.

```python
def printArguments(**arguments):
    print arguments

printArguments(arg1='something', val2=3)
{'arg1': 'something', 'val2': 3}
```

This time we get a dictionary in return. Let&#8217;s see what happens when we combine these two options.

```python
def printArguments(*values, **arguments):
    print values
    print arguments

printArguments('value', 5)
('value', 5)
{}

printArguments(something='ABC', num=1)
()
{'num': 1, 'something': 'ABC'}

printArguments(1, 2, 'something', val=7, word='yes')
(1, 2, 'something')
{'word': 'yes', 'val': 7}
```

From the previous examples we can see that `*` only catches non keyword argumens and `**` only catches keyword arguments.

## Expanding function arguments

You can also use `*` and `**` when passing arguments to a function to expand the values of the passed argument.

```python
def addNumbers(x, y, z):
    return x + y + z

a = (4, 5, 6)
print addNumbers(*a)
15
```

In the previous example, instead of passing three values to the function we passed a tuple containing three values and used the `*` operator to expand those values.

```python
def printWords(firstWord='first', secondWord='second'):
    print firstWord + '-' + secondWord

a = {'secondWord':'two', 'firstWord':'one'}
printWords(**a)
one-two
```

Here we used the `**` operator to expand a dictionary into the function arguments.
