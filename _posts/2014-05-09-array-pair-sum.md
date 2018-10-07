---
id: 2086
title: Array Pair Sum
date: 2014-05-09T04:52:07+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2086
permalink: /2014/05/array-pair-sum/
categories:
  - Application Design
  - Computer science
tags:
  - algorithms
  - javascript
  - programming
---
This is the first post on a series where I will be resolving some common coding interview questions.

## The question

Given an integer array, output all pairs that sum up to a specific value k.

## My solution

I like to start by creating a test for my solution:

```js
var arr = [1, 4, 2, 6, 8, 3, 9, 0, 7];
var res = findPairs(arr, 7);
// I expect res to be [[1, 6], [4, 3], [0, 7]]
```

<!--more-->

Now, lets think about how to solve this problem. In my test I only expect the pair to appear once, this means that once we find a pair both elements can be removed from the array. With this assumption this is what I would do:

  * Get the first element and then compare with all the elements until I find one that sums to k.
  * If no match is found then remove the first element.
  * If a match is found then add it to the answer and remove both elements from the array.
  * Do the same thing for the second element until there are no more elements.

There are two main problems I see with this solution:

  * It goes through the elements of the array multiple times, so the efficiency would be O(n^2), which is pretty much as bad as it gets.
  * You can&#8217;t really remove elements from an array so we would have to settle with assigning null to that array position.

Due to the inefficiency of the previous method I decided to try something different:

  * Sort the array (Using merge sort the efficiency would be O(nlogn).
  * Start from first element and then start comparing with the last element in reverse order.
  * When you find a match you add it to the result.
  * When you find that the sum becomes lower than k then you move the left pointer one position to the right.
  * Repeat until done.

This is the best solution I could come up with(nlogn) but it turns out this is not the most efficient way to do it. With the help of a hash table you can solve this problem in O(n):

  * Start from the left of the array.
  * Check if the value we need for it to sum k is in the hash table.
  * Add this value to the hash table.

## The best solution

This solution will have to go through all the elements only once and since inserting and reading from a hash table is constant, it gives us an efficiency of O(n)

```js
function findPairs(a, k) {
  var pairs = []; // We will store the pairs here
  var read = {}; // Hashtable with read elements

  // Loop once through all the elements in the array
  for (var current = 0; current < a.length; current++) {
    var expected = k - a[current];

    if (read[expected]) {
      // If the sum for the current element is found
      // then we add the pair to the result and
      // delete the element we used from the read
      // hashtable
      pairs.push([expected, a[current]]);
      delete read[expected];
    } else {
      // If we didn't find the element necessary to
      // sum k then we add current element to read
      // array
      read[a[current]] = true;
    }
  }

  return pairs;
}

function test() {
  var arr = [1, 4, 2, 6, 8, 3, 9, 0, 7];
  var res = findPairs(arr, 7);

  // This is not the most efficient way to compare arrays
  // but I didn't want to bloat this exercise with more code
  var expected = [[1, 6], [4, 3], [0, 7]];
  if (expected.toString() === res.toString()) {
    console.log('success');
  } else {
    console.log('failure');
  }
}

test(); // This prints success
```
