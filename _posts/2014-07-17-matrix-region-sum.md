---
id: 2092
title: Matrix region sum
date: 2014-07-17T02:13:24+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2092
permalink: /2014/07/matrix-region-sum/
tags:
  - computer_science
  - algorithms
  - javascript
  - programming
---
## The question

Given a matrix of integers and coordinates of a rectangular region within the matrix, find the sum of numbers falling inside the rectangle. Our program will be called multiple times with different rectangular regions from the same matrix.

## My solution

Just from the question I am not completely sure what they are asking me but it sounds like I will have a matrix of integers (I will assume a 2 dimensional matrix) and then they will give me coordinates for two opposite corners and I just need to sum all numbers inside the limits of those coordinates. They also mention that the program will be called multiple times with different rectangular regions which makes me thing that I&#8217;m expected to do some kind of caching.

I spent some time thinking of how to do this in an efficient way but I couldn&#8217;t come up with something that felt right.

<!--more-->

## The best solution

Apparently the best solution involves some pre-computation in order to calculate all possible sums starting from the top left corner. [The original article explains this very well](http://www.ardendertat.com/2011/09/20/programming-interview-questions-2-matrix-region-sum/).

## The implementation

```js
var matrix = [
  [1, 2, 3, 4, 5, 6, 7],
  [9, 8, 7, 6, 5, 4, 3],
  [1, 1, 1, 1, 1, 1, 1],
  [0, 1, 2, 3, 2, 1, 0],
  [9, 9, 9, 9, 9, 9, 9],
  [4, 4, 4, 4, 4, 4, 4]
];

// Create an array for the sums
var sums = new Array(matrix.length);

function calculateSums() {
  var height = matrix.length;
  var width = matrix[0].length;

  for (var y = 0; y < height; y++) {
    // Add a row to the array
    sums[y] = new Array(width);
    for (var x = 0; x < width; x++) {
      // We can use a similar technique to calculate the sums based on the
      // values already in the sums matrix
      var leftSum = sums[y][x-1] || 0;
      var topSum = 0;
      var topLeftSum = 0;
      if (typeof sums[y - 1] === 'object') {
        topSum = sums[y - 1][x] || 0;
        topLeftSum = sums[y-1][x-1] || 0;
      }

      sums[y][x] = topSum + leftSum - topLeftSum + matrix[y][x];
    }
  }

  return sums;
}

function getRectangleSum(topLeft, bottomRight) {
  return sums[bottomRight[1]][bottomRight[0]] -
      sums[topLeft[1] - 1][bottomRight[0]] -
      sums[bottomRight[1]][topLeft[0] - 1] +
      sums[topLeft[1] - 1][topLeft[0] - 1];
}

// Fill sums with all possible sums starting from top left corner
calculateSums();

function test() {
  if (getRectangleSum([3, 2], [4, 3]) === 7) {
    console.log('successs');
  } else {
    console.log('failure');
  }
}

test(); // Prints success
```
