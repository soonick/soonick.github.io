---
id: 2187
title: Search Unknown Length Array
date: 2014-12-11T07:20:03+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2187
permalink: /2014/12/search-unknown-length-array/
categories:
  - Computer science
tags:
  - algorithms
  - javascript
  - programming
---
## The question

Given a sorted array of unknown length and a number to search for, return the index of the number in the array. Accessing an element out of bounds throws exception. If the number occurs multiple times, return the index of any occurrence. If it isn’t present, return -1.

## My answer

Reading the question there is one question that came to my mind: Can the exception be handled?. Assuming that it can&#8217;t I think the only alternative would be to check all elements starting from the first one. I will assume the exception can be handled so I can come with a better solution.

<!--more-->

1 &#8211; Start at the first element
  
2 &#8211; If that element is higher than the searched element then the element is not present
  
3 &#8211; If that element is the element we are looking for then return the index
  
4 &#8211; If that element is lower then go to element 2
  
5 &#8211; Follow the same rules and then go to index 2\*2 = 4 (then 4\*4 = 16)
  
6 &#8211; If at any moment you find that the current element is higher than the element you are looking for, you can do a binary search between the current index and the previous index
  
7 &#8211; If you get an exception you can handle it and do a binary search using current index and previous index as limits

```js
var arr = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];

function binarySearch(haystack, needle, left, right) {
  var middle = Math.ceil((left + right) / 2);
  var elem = haystack[middle];
  // If the element is undefined then we are still out of
  // bounds. Lets just pretend this is just a very high number
  if (undefined === elem) {
    elem = Number.MAX_VALUE;
  }

  if (elem === needle) {
    return middle;
  }

  if (left === right || left > right) {
    return -1;
  }

  if (needle > elem) {
    return binarySearch(haystack, needle, middle + 1, right);
  } else {
    return binarySearch(haystack, needle, left, middle - 1);
  }
}

function find(haystack, needle) {
  var prev = 0;
  var curr = 2;
  var elem;

  while (true) {
    elem = haystack[curr];

    // If found return it
    if (elem === needle) {
      return curr;
    }

    // In JS if you try to find an element out of bounds it
    // will return undefined instead of giving an exception
    // If this happens then we want to do a binary search
    if (elem > needle || elem === undefined) {
      return binarySearch(haystack, needle, prev, curr);
    } else {
      // If the element we are looking for is higher then
      // exponentially keep searching for an element farther
      // from the beginning
      prev = curr;
      curr = curr * curr;
    }
  }
}

function test() {
  if (find(arr, 21) === -1 && find(arr, 1) === 0 && find(arr, 10) === 9 &&
      find(arr, 6) === 5 && find(arr, 17) === 16) {
    console.log('success');
  }
}

test(); // Prints success
```

The proposed answer uses a similar approach but instead of discovering the limits of the array exponentially they increase it by exponents of 2. The efficiency of this method is close to O(Logn).
