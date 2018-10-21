---
id: 1625
title: Debugging node apps using built in debugger
date: 2013-08-01T15:00:22+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1625
permalink: /2013/08/debugging-node-apps-using-built-in-debugger/
tags:
  - debugging
  - javascript
  - node
  - programming
---
When it comes to debugging node applications you have a few options. Most people I know use their IDE&#8217;s debugger which does the work really well for them. The next option for people who don&#8217;t use IDE&#8217;s is usually [node inspector](https://github.com/node-inspector/node-inspector "Node inspector"), which does a pretty good job too. Not long ago I found out that Node comes with a command line built in debugger which I tried and I think is easy enough that may become my debugger of choice.

To start debugging an application just use the debug command before running it:

```
node debug app.js
```

When you do this your script will be loaded but the execution will stop at the first line. You will also get a **debug>** prompt where you can issue debugger commands.

<!--more-->

You can use the **debugger** statement to add breakpoints to your app. Lets debug a little app:

```js
function fibonacci(n) {
  var fib = [];
  fib[0] = 0;
  fib[1] = 1;
  for (var i = 2; i <= n; i++){
    fib[i] = fib[i - 1] + fib[i - 2];
  }
  return fib[n];
}

function factorial(n) {
  var f = [];
  if (n === 0 || n === 1) {
    return 1;
  }
  if (f[n] > 0) {
    return f[n];
  } else {
    f[n] = factorial(n-1) * n;
    return f[n];
  }
}

var a = fibonacci(6);
debugger; // This is a break point
var b = factorial(6);
var c = a + b;

console.log(c);
```

We can start the debugger using the command we just learned:

```
node debug app.js
< debugger listening on port 5858
connecting... ok
break in app.js:24
 22 }
 23
 24 var a = fibonacci(6);
 25 debugger;
 26 var b = factorial(6);
debug>
```

You can see that the app broke on the first line of code that is actually being executed(the functions are being defined but they are not being executed yet). At this point line 24 hasn&#8217;t been executed yet and the debugger is waiting for instructions. From here we can use the **step**(can be abreviated as **s**) command to step into the function that is executed in that line:

```
debug> s
break in app.js:2
  1 function fibonacci(n) {
  2   var fib = [];
  3   fib[0] = 0;
  4   fib[1] = 1;
debug>
```

Now we are on line two. We can take a few steps forward using the **next(n)** command:

```
debug> n
break in app.js:3
  1 function fibonacci(n) {
  2   var fib = [];
  3   fib[0] = 0;
  4   fib[1] = 1;
  5   for (var i = 2; i <= n; i++){
debug> n
break in app.js:4
  2   var fib = [];
  3   fib[0] = 0;
  4   fib[1] = 1;
  5   for (var i = 2; i <= n; i++){
  6     fib[i] = fib[i - 1] + fib[i - 2];
debug> n
break in app.js:5
  3   fib[0] = 0;
  4   fib[1] = 1;
  5   for (var i = 2; i <= n; i++){
  6     fib[i] = fib[i - 1] + fib[i - 2];
  7   }
debug>
```

Say at this time we want to know the contents of fib. We can do this using the **repl**(Read-Eval-Print-Loop) command:

```
debug> repl
Press Ctrl + C to leave debug repl
> fib
[ 0, 1 ]
debug>
```

From the repl you can execute any JavaScript you want from the context of the script you are debugging. To go back to the debugger prompt use Ctrl + C. We can use the **cont(c)** command to continue the execution of our script until the next breakpoint (our debugger statement on line 25):

```
debug> c
break in app.js:25
 23
 24 var a = fibonacci(6);
 25 debugger;
 26 var b = factorial(6);
 27 var c = a + b;
debug>
```

The last command that I find using a lot is **out(o)**. Out will take you out of the current function context:

```
break in app.js:25
 23
 24 var a = fibonacci(6);
 25 debugger;
 26 var b = factorial(6);
 27 var c = a + b;
debug> n
break in app.js:26
 24 var a = fibonacci(6);
 25 debugger;
 26 var b = factorial(6);
 27 var c = a + b;
 28
debug> s
break in app.js:12
 10
 11 function factorial(n) {
 12   var f = [];
 13   if (n === 0 || n === 1) {
 14     return 1;
debug> o
break in app.js:27
 25 debugger;
 26 var b = factorial(6);
 27 var c = a + b;
 28
 29 console.log(c);
debug> repl
Press Ctrl + C to leave debug repl
> b
720
```

Once you get used to the most common commands it is pretty useful to debug even large applications.
