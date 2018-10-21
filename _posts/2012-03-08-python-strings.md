---
id: 567
title: Python strings
date: 2012-03-08T05:34:24+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=567
permalink: /2012/03/python-strings/
tags:
  - programming
  - python
---
Python has a lot of ways to represent strings, so it is useful to be familiar with them in case you ever find them in any python program.

## Ordinary Strings

These are probably the most commonly used strings on python. You can enclose them using single or double quotes (&#8216; or &#8220;) and you can use a backslash to escape characters or to print special characters like a line break:

```python
print "Hello\nWorld"
Hello
World

print 'Hello\nWorld'
Hello
World

print 'This is a backslash: \\'
This is a backslash: \
```

<!--more-->

## Long Strings

You can write long (multi-line) strings by encasing them on triple quotes (&#8221;&#8217; or &#8220;&#8221;&#8221;). This is very useful when you need to write very long statements because you don&#8217;t have to escape any quotes (&#8216; or &#8220;).

```python
print '''She said: "Hello",
and I thought:
"This can't be real"'''
She said: "Hello",
and I thought:
"This can't be real"
```

You could do the same with double quotes:

```python
print """She said: "Hello",
and I thought:
"This can't be real"
"""
She said: "Hello",
and I thought:
"This can't be real"
```

One thing to notice in my last example is that I entered a line break before closing the string. I did this because if I would have left them on the same line I would have had 4 consecutive quotes, and that would give an error. If you need your string to end with a quote and you don&#8217;t want the extra line break, you can escape the last quote that is part of the string:

```python
print """She said: "Hello",
and I thought:
"This can't be real""""
She said: "Hello",
and I thought:
"This can't be real"
```

## Raw Strings

Raw strings are useful when you don&#8217;t want to use backslashes to scape characters on your string. This is very useful for writing windows paths:

```python
print r'C:\afolder\afile.txt'
C:\afolder\afile.txt
```

One thing to keep in mind when using raw strings is that while quotes can be escaped, the backslash you use to escape them will be showed in the final string:

```python
print r'don\'t say I didn\'t tell you'
don\'t say I didn\'t tell you
```

You can also use raw triple-quoted strings:

```python
print r'''"I have quotes (')",
also slashes \
and I am multi-lined'''
"I have quotes (')",
also slashes \
and I am multi-lined
```

## Unicode Strings

As for python 3.0 all strings will be Unicode strings. For versions before that you have to add u before the string:

```python
print u'I am unicode á'
I am unicode á
```
