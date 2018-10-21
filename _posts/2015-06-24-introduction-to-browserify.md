---
id: 2815
title: Introduction to Browserify
date: 2015-06-24T06:49:03+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2815
permalink: /2015/06/introduction-to-browserify/
tags:
  - browserify
  - javascript
  - productivity
  - programming
---
When a web project starts getting big, managing dependencies becomes hard if you don&#8217;t have the right tools. If you have some experience with web development, you probably use RequireJS to manage your dependencies.

RequireJS does a great job but if you are familiar with node, you probably wish it was as easy in the browser. Dependency management is built into node, so you don&#8217;t have to worry about it.

Browserify lets you write node-style code that works in the browser. It is basically a replacement for RequireJS that allows you to create bundles with less configuration.

<!--more-->

## Simple example

Make sure you have browserify:

```
npm install -g browserify
```

Lets build a simple example with a **calculator** that uses an **adder** module. This is how adder.js looks like:

```js
module.exports = function(a, b) {
  return a + b;
}
```

calculator.js:

```js
var adder = require('./adder');

function add(a, b) {
  return adder(a, b);
}

console.log(add(2, 3));
```

We can now run browserify on calculator.js and it will create a bundle with all it&#8217;s dependencies:

```
browserify calculator.js -o out.js
```

This will create a file called out.js that looks like this:

```js
(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
module.exports = function(a, b) {
  return a + b;
};

},{}],2:[function(require,module,exports){
var adder = require('./adder');

function add(a, b) {
  return adder(a, b);
}

console.log(add(2, 3));

},{"./adder":1}]},{},[2]);
```

The important thing from this file is that it has the calculator and all its dependencies bundled together. You can now just add this file to an html file:

```html
<html>
<body>
  <script src="out.js"></script>
</body>
</html>
```

If you run this in a browser, you will see the number 5 printed in the console, because we are calling add(2, 3) in calculator.js

This is basically what browserify does, but there are a few more things that are important if you want to use it for a real project.

## Workflow

Since the browser doesn&#8217;t speak CommonJS, you can&#8217;t just write a JavaScript file that uses CommonJS and include it using a script tag on your page. Before you do that you have to use browserify to translate your CommonJS file to something the browser understands.

This extra step comes with it&#8217;s challenges. Since the code you write is not the same code that runs in the browser, debugging becomes a little more difficult. If you have a bug on your code, the browser will report the line number where the error happened in the generated file, which is not the code you wrote.

Browserify uses source maps to work around this issue. Adding source maps is as simple as adding a -d flag:

```
browserify calculator.js -o out.js -d
```

When a bug is reported by the browser it will now report the correct file and line so you can easily fix it.

Another issue with using browserify is that every time you change something you have to go back to the terminal and run a command so the file you are using in the browser gets updated with the latest changes. Furthermore, as your code base grows, browserify will have to process more files and thus, take more time to run. Both of these issues can be taken care of by watchify.

Watchify runs the browserify command and then watches your project files for changes. Every time you change a file it will run browserify again. Watchify keeps a cache of the files that have been processed so every time you change a file only the necessary files get recompiled. This makes for faster builds.

Here is an example of how to run it:

```
watchify calculator.js -o out.js -d -v
```

This will run browserify with the debug flag every time you change a file. The -v flag tells watchify to print a line every time it runs browserify. It looks something like this:

```
2021 bytes written to out.js (0.01 seconds)
```

With this, you can get started with Browserify and enjoy writing node-like code for the browser.
