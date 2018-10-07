---
id: 2189
title: Find Even Occurring Element
date: 2014-09-25T03:43:12+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2189
permalink: /2014/09/find-even-occurring-element/
categories:
  - Application Design
  - Computer science
tags:
  - algorithms
  - javascript
  - programming
---
## The question

Given an integer array, one element occurs even number of times and all others have odd occurrences. Find the element with even occurrences.

## My answer

The first thing I thought of was using XOR, but then I realized that I am looking for the even number so it won&#8217;t actually work. My next idea was to use a hashtable:

1 &#8211; Start on the first elements and create a hashtable with the number of times each character is found
  
2 &#8211; Look for the even number in the hashtable

<!--more-->

```js
var a = [1, 2, 2, 2, 3, 4, 4, 4, 5, 6, 7, 7, 4, 4];

function findEven(arr) {
  var hash = {};

  // Check all characters and add count to hash table
  for (var i = 0; i < arr.length; i++) {
    var key = arr[i];
    if (undefined === hash[key]) {
      hash[key] = 1;
    } else {
      hash[key]++;
    }
  }

  // Check the hash table for even element
  for (var k in hash) {
    if (0 === hash[k] % 2) {
      return parseInt(k, 10);
    }
  }
}

function test() {
  if (findEven(a) === 7) {
    console.log('success');
  }
}

test(); // Prints success
```

The complexity for this solution would be O(n) for creating the hash table and another O(n) for checking the hash table for the even element. At the end this is O(n).
