---
id: 1196
title: Introduction to node.js
date: 2013-04-18T05:56:33+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1196
permalink: /2013/04/introduction-to-node-js/
tags:
  - javascript
  - node
  - programming
---
Node.js is a relatively new technology (born on 2009) that allows us run JavaScript code from outside a browser. This had already been done in the past by Mozilla Rhino, but node.js gained a lot of popularity for it&#8217;s ease of use. Node code runs inside Google&#8217;s V8 JavaScript Engine which is exactly the same engine that is used for Google Chrome. Because node code runs on this engine, when you write node code you don&#8217;t have to worry about browser compatibility issues. Node also gets rid of some restrictions that are given to JS when running on a browser, so with node you have access to things like the file system and hardware.

Node can be used for a lot of tasks like most other programming languages, but one of it&#8217;s most common uses is as a server side scripting language. Probably The main benefit of using JavaScript in the server is that if you are a web developer you will be using a syntax that you are already familiar with, so it will be easy to get up to speed.

<!--more-->

There are a few things to keep in mind when you start programming using node. Probably the most interesting one is that most node libraries are asynchronous. The reason for this is because node runs in a single thread, so it is imperative to keep that thread available so you don&#8217;t keep new connections hanging and waiting for a response. By having asynchronous libraries we can delegate time consuming operations like reading files or database interactions to other applications and let that main thread available. This model works for node because it uses JavaScript&#8217;s event driven architecture, so the main thread can be notified when a task is completed by sending an event to the main thread.

## Installation

You can get and install Node from it&#8217;s main site [nodejs.org](http://nodejs.org/) where you will find a version for all major OS. If you are using a Debian based distribution you can of course do:

```
sudo apt-get install nodejs
```

## Trying it out

If you type **nodejs**(Just node in some systems) on your terminal you will get the node prompt:

```
>
```

From here you can execute any javascript you want:

```js
> var greetings = "Hello";
undefined
> console.log(greetings);
Hello
undefined
> greetings
'Hello'
```

By default the interactive console always prints the return value of the executed statement, that is the reason we see **undefined** printed in the second line, because there is no value returned from the first statement.

Other important thing to have in mind is that node doesn&#8217;t run inside of a browser, so functionality that is inherent from the browser is not available. Here are some examples:

```js
> window
ReferenceError: window is not defined
    at repl:1:2
    at REPLServer.eval (repl.js:80:21)
    at Interface.<anonymous> (repl.js:182:12)
    at Interface.emit (events.js:67:17)
    at Interface._onLine (readline.js:162:10)
    at Interface._line (readline.js:426:8)
    at Interface._ttyWrite (readline.js:603:14)
    at ReadStream.<anonymous> (readline.js:82:12)
    at ReadStream.emit (events.js:88:20)
    at ReadStream._emitKey (tty.js:327:10)
> alert('hello');
ReferenceError: alert is not defined
    at repl:1:1
    at REPLServer.eval (repl.js:80:21)
    at repl.js:190:20
    at REPLServer.eval (repl.js:87:5)
    at Interface.<anonymous> (repl.js:182:12)
    at Interface.emit (events.js:67:17)
    at Interface._onLine (readline.js:162:10)
    at Interface._line (readline.js:426:8)
    at Interface._ttyWrite (readline.js:603:14)
    at ReadStream.<anonymous> (readline.js:82:12)
```

## NPM

NPM stands for node package manager. This tool provide an easy way to install and manage node modules that you may need to build your applications. If you installed node using a package from nodejs.org you probably already have npm, if you use Debian you can also do:

```
sudo apt-get install npm
```

And you can install packages by using

```
npm install package-name
```

This is all for my introduction but I will be writing more about node in the future.
