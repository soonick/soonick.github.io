---
id: 732
title: Introduction to Object Oriented Programing in Python
date: 2012-07-12T02:05:15+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=732
permalink: /2012/07/introduction-to-object-oriented-programing-in-python/
categories:
  - Python
tags:
  - programming
  - python
---
In this post I am going to explain the syntax for Object Oriented Programming in Python. I am assuming you have already done it in other languages so if you have not done Object Oriented Programming previously you should probably look for another article about it&#8217;s principles.

At the beginning when I started learning python I found some things that I felt kind of weird, like the lack of braces and semicolons. Now that I started learning their syntax for OOP I realize that doing things weirdly is their standard. Python (kind of) allows you to implement all the principles of OOP but their syntax is not similar to the one of Java, C++, or PHP that I am familiar with. Anyway so far I don&#8217;t see any problem with their different way of doing things so I will just explain how things are done in Python.

<!--more-->

## Creating a class

This is the structure of a class in python:

```python
class MyClass:
    some_property = 3

    def method_name(self):
        print "I'm a method"

    def print_property(self):
        print self.some_property

    def with_argument(self, arg):
        print arg
```

There are few things to notice here:

  * The **class** keyword is used to define the class
  * The **def** keyword is used to define methods of the class
  * **self** needs to be passed as the first argument for all methods of a class

At the begining one of the most confusing things for me was the passing of **self** to all of the methods. For some reason python doesn&#8217;t have a reference to the current object available to the methods by default, but it is always passed in the first argument of a method. If you forget to add **self** as the first argument to you method definition, your program will break when you try to call that method.

Now lets see how we can use our class:

```sh
>>> a = MyClass()
>>> a.method_name()
I'm a method
>>> a.print_property()
3
>>> a.with_argument('hello')
hello
```

As you can see from the call to **with_argument**, you don&#8217;t explicitly pass a reference to the current object. That, is automatically done by python. So the first argument you actually pass is the one next to self in the method definition.

An interesting thing to mention here is that by convention the reference to the current object is called **self** but you could call it something different if you wanted. This works exactly the same way:

```python
class MyClass:
    some_property = 3

    def method_name(george):
        print "I'm a method"

    def print_property(apple):
        print apple.some_property
```

## The constructor

```python
class MyClass:

    def __init__(self):
        print "I'm the constructor"
```

The constructor is defined using the **\_\_init\_\_** magic method. All &#8220;magic&#8221; methods in python follow the same naming convention of two underscores at the begining and two underscores at the end. Because of this distinction you shouldn&#8217;t name your own methods like this.

Let&#8217;s see it in action:

```sh
>>> a = MyClass()
I'm the constructor
```

## Inheritance

Lets define two classes, one called parent and one called child.

```python
class parent:
    def my_method(self):
        print "I'm the parent"

class child(parent):
    def child_method(self):
        print "I'm the child"
```

The code as it is right now would work like this:

```sh
>>> b = child()
>>> b.my_method()
I'm the parent
>>> b.child_method()
I'm the child
```

Now lets see what happens if we modify child a little.

```python
class child(parent):
    def my_method(self):
        print "I'm the child"

    def child_method(self):
        print "I'm the child"
```

An lets see it at work:

```sh
>>> c = child()
>>> c.my_method()
I'm the child
```

As expected the child method has shadowed the parent method. What is worth mentioning is the syntax to access method from a parent.

```python
class child(parent):
    def my_method(self):
        parent.my_method(self)
        print "I'm the child"
```

The important thing here is line 3. We are calling the **my_method** method of the **parent** class (the class, not an instance of it. That is the reason we can pass self explicitly), but the thing that does the magic is the passing of **self** as the first argument. Because in that context self is the instance of the current object, then you are passing the child instance to the parent class to work over it. And in action:

```sh
>> d = child()
>>> d.my_method()
I'm the parent
I'm the child
```

## Other important things

  * In python there aren&#8217;t access modifiers. All methods are public by default, and even tought it is possible to get some kind of privacy from them it is usually not worth the trouble.
  * There doesn&#8217;t exist any kind of type hinting that can be done in python to make sure that a variable passed to a method is of an specific type. This is because of the dynamic nature of python and is kind of usual for dynamic languages.
  * All methods and properties can be accessed statically without having to define it.
  * There is no concept of interfaces in python.
  * Multiple inheritance is possible.
