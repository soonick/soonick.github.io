---
id: 1863
title: Hash tables
date: 2014-03-20T01:55:31+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1863
permalink: /2014/03/hash-tables/
categories:
  - Application Design
  - Computer science
tags:
  - algorithms
  - data structures
  - design patterns
  - javascript
  - programming
---
Hash tables are a very important data structure that can be used for many things. They are really fast so they are a good fit for almost anything where they can be used. One example of when a hash table is useful is an associative array, for example:

```js
var a = {};
a['hello'] = 'hola';
a['bye'] = 'adios';

console.log(a['hello']); // Prints hola
```

The beauty of hash tables is that searching for the value of a\[&#8216;hello&#8217;\] (ideally)takes the same time no matter how many values the associative array has. In JavaScript we have this functionality with plain objects, but I needed to understand a little more about it&#8217;s implementation so I will explain how you could create your own hash table using arrays.

<!--more-->

## Hash function

Creating a hash table is relatively easy once we have a hash function. A hash function will receive a string as input and will return an integer in a given range as output.

```js
var index = hash('someKey');
```

For the hash table to be useful it should give you well distributed return values depending on the data. I will not go in very much detail about good hashing algorithms because I&#8217;m sure I wouldn&#8217;t do a great job explaining all the strategies. For my example I will use a very simple strategy, the length of the key will be the returned value, so for example:

```js
hash('hello'); // Returns 5
hash('Bye'); // Returns 3
```

## Buckets

Since we are going to use an array to store our elements we need to limit the size of our array. If we are using JavaScript we might not care about this and increase the size of the array as needed but this might not be a good idea for performance reasons. Having to resize the array constantly takes resources as well as having a very large array in memory may be something we don&#8217;t want.

For my example I will use a very small 10-items array:

```js
var buckets = new Array(10);
```

This means we have indexes from 0 to 9 available for us to store whatever we want. Now, the problem is that since our hash function returns the length of the key, we might get something that is out of those bounds:

```js
hash('more than ten'); // Returns 13
```

This would force our array to resize, which is something we don&#8217;t want. What I&#8217;m going to do instead is modify the hash function so it never returns a number larger than a given limit.

```js
hash('more than ten'); // Returns 13 % 10 = 3
```

## Crashes

There will be cases when we will have two keys return the same hash:

```js
hash('one'); // Returns 3
hash('two'); // Returns 3
```

For this reason we need to have a strategy to manage crashes. There are many things that can be done, but I will go for a simple alternative. When there are two elements in a bucket we will store them in an array:

```js
buckets[3] = [
  [
    'one',
    'value for one'
  ],
  [
    'two',
    'value for two'
  ]
];
```

Then we can loop that array and find the correct value for our key. This of course means that we would have to do a linear search here, but if we have enough buckets and our hash gives us relatively well distributed values then this should happen very rarely.

## The code

Putting everything together our code looks like this:

```js
var hashTable = function(buckets) {
  if (!buckets) {
    buckets = 10;
  }

  var values = new Array(buckets);

  function hash(word) {
    return word.length % buckets;
  }

  this.put = function(key, value) {
    var keyHash = hash(key);

    if (!values[keyHash]) {
      // The first value
      values[keyHash] = [
        [key, value]
      ];
    } else {
      // This is a crash
      values[keyHash].push([
        key, value
      ]);
    }
  };

  this.get = function(key) {
    var keyHash = hash(key);

    if (!values[keyHash]) {
      return;
    }

    for (var i = 0; i <= values[keyHash].length; i++) {
      if (values[keyHash][i][0] === key) {
        return values[keyHash][i][1];
      }
    }
  };
};

var ht = new hashTable(10);

ht.put('one', 'uno');
ht.put('five', 'cinco');
ht.put('seventy three', 'setenta y tres');
ht.put('two', 'dos');
ht.put('ninety seven', 'noventa y siete');

console.log(ht.get('one')); // uno
console.log(ht.get('five')); // cinco
console.log(ht.get('seventy three')); // setenta y tres
console.log(ht.get('two')); // dos
console.log(ht.get('ninety seven')); // noventa y siete
console.log(ht.get('nothing')); // undefined
```
