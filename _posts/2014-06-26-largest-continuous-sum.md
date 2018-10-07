---
id: 2099
title: Largest Continuous Sum
date: 2014-06-26T01:06:39+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2099
permalink: /2014/06/largest-continuous-sum/
categories:
  - Application Design
  - Computer science
tags:
  - algorithms
  - javascript
  - programming
---
## The question

Given an array of integers (positive and negative) find the largest continuous sum.

## My solution

These are the steps I followed:

&#8211; Get the first number and add it to a variable where you will store the largest sum so far(largest).
  
&#8211; Create another variable(currentSum) where you will store the value of the current sum so far and assign the same number to it.
  
&#8211; Move to the next number. Calculate the sum of n1 and n2, if it is positive then assign it to currentSum.
  
&#8211; Check if currentSum is larger that largest. If it is, update largest.
  
&#8211; If currentSum became negative then assign 0 to it.

You have to go through each number in the array once, so the complexity is O(N).

<!--more-->

## The implementation

```js
function findLargestSum(arr) {
  // Start both variables with the value of the first element
  var largest = arr[0];
  var current = arr[0];

  for (var i = 1; i < arr.length; i++) {
    var sum = current + arr[i];
    // If sum becomes negative restart it to 0
    if (sum < 0) {
      current = 0;
    } else {
      current = sum;
    }

    // If sum becomes greater than largest then
    // update largest
    if (sum > largest) {
      largest = sum;
    }
  }

  return largest;
}

function test() {
  var input = [1, 2, 3, -1, 7, -12, -3, 45, -27, -1, 4, 30, -100, 1];
  // The largest sum for this array is 51
  if (51 === findLargestSum(input)) {
    console.log('success');
  } else {
    console.log('failure');
  }
}

test();
```

A friend suggested to make this exercise a little more complicated by also printing the sequence that gives that result. Here is the code for that:

```js
function findLargestSum(arr) {
  var largest = arr[0];
  var current = arr[0];
  var currentStart = 0;
  var currentEnd = 0;
  var largestStart = 0;
  var largestEnd = 0;

  for (var i = 1; i < arr.length; i++) {
    var sum = current + arr[i];
    if (sum < 0) {
      current = 0;
      currentStart = i + 1;
    } else {
      current = sum;
    }

    if (sum > largest) {
      largestStart = currentStart;
      largestEnd = currentEnd = i;
      largest = sum;
    }
  }

  var resultArray = [];
  for (i = largestStart; i <= largestEnd; i++) {
    resultArray.push(arr[i]);
  }
  return resultArray;
}

function test() {
  var input = [1, 2, 3, -1, 7, -12, -3, 45, -27, -1, 4, 30, -100, 1];
  var expected = [45, -27, -1, 4, 30];
  if (expected.toString() === findLargestSum(input).toString()) {
    console.log('success');
  } else {
    console.log('failure');
  }
}

test();
```
