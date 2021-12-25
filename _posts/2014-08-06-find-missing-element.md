---
id: 2104
title: Find Missing Element
date: 2014-08-06T21:38:56+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2104
permalink: /2014/08/find-missing-element/
tags:
  - computer_science
  - algorithms
  - javascript
  - programming
---
## The question

There is an array of non-negative integers. A second array is formed by shuffling the elements of the first array and deleting a random element. Given these two arrays, find which element is missing in the second array.

## My solution

The idea that came to my mind first involved using a hash-table.

&#8211; Go over all the elements in the second array and add them to the hash table
  
&#8211; Go over all the elements in the first array and try to get it from the hash table. If it is not there, that&#8217;s the number.

The hash table solution has a complexity of O(n) but it uses a lot of space by creating a hash table with all the elements in the array.

<!--more-->

## The best solution

There is a more clever way to fix this problem. Add all the elements on the first array, then add all the elements in the second array and subtract those two numbers. The result is the missing number. This is a very good solution with a little problem. The result of adding all the elements on the array could be so big that it overflows the value that an integer can hold.

The best solution involves XORing all elements in the first array and second array. The result of this operation is the missing number.

To understand how this work, lets see how XOR works:

XOR table

```
0|0|0
0|1|1
1|0|1
1|1|0
```

If the two bits you are comparing have the same value the result is 0, otherwise it is 1. This means, if you XOR a number against itself, the result will be 0:

```
101
101
---
000
```

If you XOR all numbers, since all the numbers are twice, they will negate themselves, except for the number that doesn&#8217;t appear in the second array, which will be the result.

## The implementation

Interestingly enough, I tried this algorithm and it works fine when the arrays contain negative integers so I&#8217;m not sure why this restriction was added to the problem.

```js
function findMissingElement(left, right) {
  var result = 0;

  // XOR all element on right and left (except the last from left)
  for (var i = 0; i < right.length; i++) {
    result = result ^ left[i] ^ right[i];
  }

  // XOR the last element from left
  result = result ^ left[i];

  return result;
}

function test() {
  var arr1 = [23, 9999, 2, 5, 22, 32, 44, 23, 1, 1, 65];
  var arr2 = [44, 9999, 2, 5, 65, 22, 23, 1, 1, 23];

  if (32 === findMissingElement(arr1, arr2)) {
    console.log('success');
  } else {
    console.log('failure');
  }
}

test(); // Prints success
```
