---
id: 3025
title: Writing ES6 with Babel
date: 2015-07-02T07:36:43+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3025
permalink: /2015/07/writing-es6-with-babel/
categories:
  - Javascript
tags:
  - es6
  - javascript
  - programming
---
I&#8217;ve been using JavaScript for a few years, and as of today it is my favorite programming language because it allows you to build things really fast. All the JavaScript I wrote in the past was in a version called EcmaScript 5. I know there is works on EcmaScript 6 and EcmaScript 7, but since I work mostly on the browser, I can&#8217;t really use it until the browsers add support.

Babel is a ES6 to ES5 compiler. This means that you can write code in ES6 and it will be transformed to something most browsers understand. This is interesting because it allows us to use new features that are not yet implemented in all browsers, but also because it resembles the way software was developed in the past(write, compile, run). The problem with the old programming model is that it could take some time to compile the code, so there was a delay from when you write the code and you can see it in action. For JavaScript the compilation time can be brought down to something fast enough that the developer doesn&#8217;t realize the code was compiled.

<!--more-->

## Using Babel

Start by getting babel:

```
npm install -g babel
```

Now, just specify the file you want to compile and the output file:

```
babel es6.js > es5.js
```

This will output a file named es5.js in the current directory.

## Why do I want to use ES6?

When people around me started talking about writing ES6 and compiling it to ES5. The first thing that came to my mind is, **Why?**. What is ES6 going to give me that ES5 doesn&#8217;t.

As with most programming language updates, they usually come with syntactic sugar and some features users have been requesting for a while. I&#8217;m going to go through the parts that I consider more important and you can then decide if it makes sense for you.

I&#8217;m not going to go in depth on any of the features, but Rather show how you can start using them with Babel.

## Modules

I think modules is one of the most important features of ES6. If you are in the business of creating serious JS applications, then you need to be able to separate your JS into modules. Currently teams do this in the browser by using AMD.

ES6 Modules are similar to CommonJS modules with a few improvements. Lets look at an example. First we create a module that exports a constructor:

```js
function Calculator() {}

Calculator.prototype.add = function(a, b) {
  return a + b;
};

export default Calculator;
```

Then we create an app that uses this module:

```js
import Calculator from './calculator';

var c = new Calculator();
console.log(c.add(2, 3));
```

This seems pretty straight forward, but there are a few reasons it isn&#8217;t. First, by default Babel will transform ES6 modules into CommonJS format. Since this format is not supported by the browser, it is not really useful. You can tell it to transform to AMD instead:

```
babel --modules amd app.js
```

The other problem is that it won&#8217;t automatically create bundles for you. You have to run babel on each of the files you want to transform and then configure your AMD library so everything works fine. This makes it a little more work than most developers are willing to do, so tools have been created around this.

Babelify is a Browserify transform module. It basically allows Browserify to understand ES6 syntax and output ES5. Using it is pretty easy. First install the dependencies:

```
npm install -g browserify
npm install babelify
```

And then run it against the entry point of your app:

```
browserify app.js -t babelify --outfile out.js
```

Now you can just load out.js from your HTML file and it will work the way you expect it.

## Template strings

These are very simple, but really cool too. It allows you to easily add variable values into your strings.

```js
var name = 'Adrian';

console.log('My name is ' + name);
console.log(`My name is ${name}`);

var text = 'This text is kind of long,' +
'for that reason it is divided into' +
'multiple lines';

var text2 = `This text is kind of long,
for that reason it is divided into
multiple lines`

console.log(text, text2);

function dollar(num) {
  return '$' + num;
}

console.log('I have ' + dollar(3) + ' USD');
console.log(`I have ${dollar(3)} USD`);
```

## Classes

JavaScript has always been object oriented, but it didn&#8217;t have classes. You created inheritance using the prototype chain. This is very confusing for people that move to JavaScript from a language that uses classes.

ES6 Introduces classes so people new to JavaScript feel more comfortable. It is important to understand that the new class syntax is just syntactic sugar for creating constructors. Under the hood inheritance still works the same way.

This is how inheritance looks like in ES6:

```js
class Person {
  constructor(name) {
    this.name = name;
  }

  jump() {
    console.log('I jumped');
  }
}

class Student extends Person {
  setGrade(grade) {
    this.grade = grade;
  }
}

var s = new Student('Adrian');
s.setGrade(10);
console.log(s.grade, s.name);
```

This will log **10 Adrian** to the console.

## Arrow functions

Arrow functions are syntactic sugar to define functions. Probably the most useful addition is the lexical assignment of **this**. It is a common mistake defining a function in ES5 and having the wrong value for **this**. Here is an example:

```js
function Cat() {
  this.sound = 'MEOW';

  this.meow = function() {
    window.setTimeout(function() {
      console.log(this.sound);
    }, 100);
  };
}

var c = new Cat();
c.meow();
```

If you are new to JavaScript, you probably expect this code to log MEOW to the console. Instead, it logs undefined. This happens because the function inside setTimeout creates it&#8217;s own scope and it&#8217;s own this. This is easily fixed by using bind, but on ES6, that is not necessary anymore:

```js
class Cat {
  constructor() {
    this.sound = 'MEOW';
  }

  meow() {
    window.setTimeout(() => {
      console.log(this.sound);
    }, 100);
  }
}

var c = new Cat();
c.meow();
```

When you use fat arrows(=>) to create a function, the value for this for that function will be taken from the context where that function was created. This is many times what developers want, so it becomes more convenient.

The syntax for arrow functions is not what we are used to, so it might take a little to get used to. This is how it works:

```js
// Function with no arguments
function() {
  // some code
}

() => {
  // some code
}

// Function with arguments
function(a, b, c) {
  // some code
}

(a, b, c) => {
  // some code
}

// Function with a single identifier as argument
function(a) {
  // some code
}

a => {
  // some code
}

// Function returns an expression
function(a, b) {
  return a + b;
}

(a, b) => a + b;
```

## Block scoping

In JavaScript you declare variables using the **var** keyword. Var creates a variable in the current function scope. Other programming languages use what is called block scope. This means that a variable only exists within the block where it was declared(A block is the body of an if, or a loop, basically anything surrounded by curly braces).

An example of the var keyword in action:

```js
function hello(lang) {
  if (lang === 'spanish') {
    var greet = 'hola';
  }

  console.log(greet);
}

hello('spanish'); // This prints: hola
```

ES6 Introduces two keywords that use block scope instead of function scope. The first one is **let**. Lets look at it in action:

```js
function hello(lang) {
  if (lang === 'spanish') {
    let greet = 'hola';
  }

  console.log(greet);
}

console.log(hello('spanish'));
```

This gives a reference error because greet hasn&#8217;t been defined in the function scope.

The second keyword for creating a variable with block scope is **const**. As it&#8217;s name implies, this creates a constant, which means once a value is assigned(and it has to be assigned when you declare it), it can&#8217;t be changed.

## Promises

Promises have been out there for a while, but you needed to download a library to use them and their APIs differed a little. ES6 brings promises natively to the browser and with an standardized API. Promises would probably deserve a post of themselves so I&#8217;m not going to explain them here. There important thing here is that you won&#8217;t need to load a library anymore and that the API is now a standard.

## Computed property names

This is again, just sugar syntax. Take this scenario in ES5:

```js
var key = 'cat';
var obj = {};
obj[key] = 'meow';
obj['Big ' + key] = 'MEOW';
console.log(obj.cat, obj['Big cat']);
```

This will print **meow MEOW**. In ES6 you can use computed property names(The ones between braces[]) inline with the object declaration:

```js
var key = 'cat';
var sounds = {
  [key]: 'meow',
  ['Big ' + key]: 'MEOW'
};
console.log(sounds.cat, sounds['Big cat']);
```

It saves a little typing.

## Default parameters

This features handles the scenario where you have a function that has optional parameters. When the parameters are not given, you want to use default values. Lets see how this was done in the past:

```js
function fiveTimes(num) {
  num = num || 1;
  console.log(5 * num);
}

fiveTimes(); // Prints 5
fiveTimes(9); // Prints 45
```

With ES6 you can use this syntax:

```js
function fiveTimes(num=1) {
  console.log(5 * num);
}

fiveTimes(); // Prints 5
fiveTimes(9); // Prints 45
```

## Destructuring assignment

This is a new syntax for creating variables based on arrays or objects. Here is how it works:

```js
var fruits = {
  banana: 'platano',
  strawberry: 'fresa',
  orange: 'naranja'
};

// ES5
var b = fruits.banana;
var s = fruits.strawberry;
console.log(b, s); // platano fresa

// ES6
var {banana, strawberry} = fruits;
console.log(banana, strawberry); // platano fresa

var orderedNames = ['Adrian', 'Bernardo', 'Carlos', 'Daniel'];

// ES5
var first = orderedNames[0];
var second = orderedNames[1];
var next = orderedNames.splice(2);
// Adrian, Bernardo, ['Carlos, 'Daniel']
console.log(first, second, next);

// ES6
var [first, second, ...next] = orderedNames;
// Adrian, Bernardo, ['Carlos, 'Daniel']
console.log(first, second, next);
```
