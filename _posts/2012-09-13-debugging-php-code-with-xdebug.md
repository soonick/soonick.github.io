---
id: 801
title: Debugging PHP code with xDebug
date: 2012-09-13T02:22:41+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=801
permalink: /2012/09/debugging-php-code-with-xdebug/
tags:
  - debugging
  - php
  - programming
---
Xdebug is a PHP extension which provides debugging, tracing and profiling capabilities.

Installing xDebug in an Ubuntu based distribution is very easy using apt-get:

```
sudo apt-get install php5-xdebug
```

Just by installing xDebug you will get two very basic but useful rewards: Pretty var_dumps and pretty error messages.

<!--more-->

So instead of getting this:

[<img src="/images/posts/php_error.png" />](/images/posts/php_error.png)

or this:

[<img src="/images/posts/var_dump.png" />](/images/posts/var_dump.png)

You will be getting this:

[<img src="/images/posts/xdebug_php_error.png" />](/images/posts/xdebug_php_error.png)

and this:

[<img src="/images/posts/xdebug_var_dump.png" alt="xDebug var_dump output" />](/images/posts/xdebug_var_dump.png)

You can configure the dept of the variables nesting to show on your var_dumps with this xDebug property:

```
xdebug.var_display_max_depth
```

If after installing xDebug you are not getting this type of output you will have to add this line to your php.ini file:

```
html_errors = 1
```

One very useful xdebug directive that you can add to your php.ini file is **xdebug.file\_link\_format**, which print a link on your error messages that will open your text editor in the line where the error occurred. This is my configuration for Gedit:

```
xdebug.file_link_format = xdebug://%f@%l
```

Open Firefox and go to this URL:

```
about:config
```

Add a new boolean setting &#8220;network.protocol-handler.expose.xdebug&#8221; and set it to false.

Create a bash script with this content and make it executable.

```sh
#! /bin/sh

f=`echo $1 | cut -d @ -f 1 | sed 's/xdebug:\/\///'`
l=`echo $1 | cut -d @ -f 2`

gedit +$l $f
```

Next time you see a xDebug error and you click on a link you will see a pop up asking you to select a program to open that type of links. Choose the shell script you created.

It has happened to me that I have a web design that uses a lot of floats, absolute positions and z-indexes that whenever I get an error message it is impossible to read it because my layout hides the messages. For these occasions we can buffer the error messages and print them at the end of the layout using these functions:

```
xdebug_start_error_collection()
xdebug_stop_error_collection()
xdebug_get_collected_errors()
```
