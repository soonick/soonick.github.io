---
id: 2220
title: Dutch national flag problem
date: 2014-06-19T00:59:02+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2220
permalink: /2014/06/dutch-national-flag-problem/
categories:
  - Application Design
  - Computer science
tags:
  - algorithms
  - javascript
  - programming
---
The name of this problem comes from the Netherlands flag which consists of three colors: red, white and blue.

## The question

Given an array of size n which has a random number of 1s, 2s and 3s in random order. Arrange the numbers so all the 1s are at the beginning, followed by the 2s and then the 3s.

<!--more-->

## The answer

You can solve this problem by following these steps:

  * Add a pointer(left) at the beginning of the array
  * Add a pointer(right) at the end of the array
  * Add a pointer(middle) at the left of the array
  * Check the value at middle
  * If the value is one move left and middle one space to the right
  * If the value is two. Move middle one space to the right
  * If the value is three swap the element with the element on right and move right one space to the left
  * Check the element at middle until right and middle are in the same position

The complexity is O(n) because in the worst case you would have to transition all the elements in the array.

## The code

```js
var f = [1, 2, 3, 3, 3, 1, 2, 3, 2, 2, 2, 2, 3, 3, 3, 3, 1, 1, 1, 3, 2];

function fixFlag(flag) {
  var left = 0;
  var middle = 0;
  var right = flag.length - 1;

  function swap(i, j) {
    var tmp = flag[i];
    flag[i] = flag[j];
    flag[j] = tmp;
  }

  while (middle < right) {
    if (flag[middle] === 3) {
      swap(middle, right);
      right--;
    }

    if (flag[middle] === 2) {
      middle++;
    }

    if (flag[middle] === 1) {
      swap(middle, left);
      left++;
      middle++;
    }
  }
}

fixFlag(f);

console.log(f);
// The output is [ 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3 ]
```
