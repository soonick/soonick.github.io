---
id: 2083
title: Java Generics
date: 2014-06-05T02:22:50+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2083
permalink: /2014/06/java-generics/
tags:
  - mobile
  - java
  - programming
---
Today I discovered a feature of java that I have been using for a while but I didn&#8217;t know it existed. Generics allow developers to create generic algorithms that work on collections of different data types but at the same time provide type safety.

Generics are commonly used for data structures. List is an example of a data structure that uses generics:

```java
List<String> list = new ArrayList<String>();
```

You could have declared your list like this:

```java
List list = new ArrayList();
```

The difference is that by using generics you make sure that you don&#8217;t accidentally try to insert something that is not a string into your list and cause a run time error. By specifying in the list declaration that this is a List of Strings you make sure that you get a compile time error if you try to add something that is not a string to the list.

<!--more-->

This is all cool but the coolest part is that you can create your own classes that use generics:

```java
public class OneElement<T> {
    private T element;

    public void set(T el) {
        this.element = el;
    }

    public T get() {
        return element;
    }
}
```

And you can can use them like this:

```java
OneElement<String> o = new OneElement<String>();
o.set("hello world");
System.out.println(o.get()); // Prints hello world

OneElement<Integer> e = new OneElement<Integer>();
e.set(4);
System.out.println("" + e.get()); // Prints 4
```
