---
id: 890
title: Javascript Inheritance
date: 2012-10-12T01:54:03+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=890
permalink: /2012/10/javascript-inheritance/
categories:
  - Javascript
tags:
  - javascript
  - programming
---
JavaScript Object Orientation is very different from most other popular languages (C++, Java, PHP), so if you come from one of those languages it becomes a little hard to wrap your mind on how things work in JS.

Prototypal inheritance is one of those things where people have trouble when they arrive to JS. Let&#8217;s see it in action:

<!--more-->

```js
// A person object
function Person(name, age) {
    this.name = name;
    this.age = age;

    this.getName = function() {
        return this.name;
    };

    this.getAge = function() {
        return this.age;
    };

    this.getId = function() {
        return 'This one gets overwritten';
    }
}

// A user object
function User(name, age, id) {
    this.id = id;
    this.name = name;

    this.getId = function() {
        return id;
    };
}

// Make user extend person
User.prototype = new Person();

aUser = new User('Adrian', 26, '1');

console.log(aUser.getName()); // Adrian
console.log(aUser.getAge()); // undefined
console.log(aUser.getId()); // 1
```

There is a lot of information on that snipet of code, but I think the most interesting part is line 30. We are assigning a new instance of Person to the User.prototype variable. What this line does is not very intuitive in my opinion, but here are the things that I see happening:

  * getName and getAge priviledged methods are made available to the User object.
  * The assignations made on Person constructor(line 4) are not executed when you instantiate a user.
  * Methods of User don&#8217;t get overwritten with methods of the same name in Person (getId)

Lets see a little different example:

```js
// A user object
function User(name, age, id) {
    this.name = name;
    this.age = age;
    this.id = id;

    this.getId = function() {
        return id;
    };
}

// Make user extend person
User.prototype = {
    'getName': function() {
        return this.name;
    },

    'getAge': function() {
        return this.age;
    },

    'getId': function() {
        console.log('I am ignored');
    }
};

aUser = new User('Adrian', 26, '1');

console.log(aUser.getName()); // Adrian
console.log(aUser.getAge()); // 26
console.log(aUser.getId()); // 1
```

I have made some changes, and we can now see the inheritance happening on line 13. We are adding members functions to User from an anonymous object. We can notice here that &#8216;getId&#8217; doesn&#8217;t overwrite the already defined method on User.

One last think I think is worth showing is the access to the private members of an object:

```js
// A user object
function Person(name, age) {
    var theName = name;
    var theAge = age;

    this.getName = function() {
        return theName;
    };
}

// Make user extend person
Person.prototype = {
    'getAge': function() {
        return theAge;
    }
};

aPerson = new Person('Adrian', 26);

console.log(aPerson.getName()); // Adrian
console.log(aPerson.getAge()); // Error because theAge is not defined
```

We can see on line 21 that getAge doesn&#8217;t have access to a private variable defined on the Person constructor.
