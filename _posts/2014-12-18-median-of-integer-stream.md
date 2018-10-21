---
id: 2163
title: Median of Integer Stream
date: 2014-12-18T02:21:55+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2163
permalink: /2014/12/median-of-integer-stream/
tags:
  - application_design
  - computer_science
  - algorithms
  - javascript
  - programming
---
## The question

Given a stream of unsorted integers, find the median element in sorted order at any given time. So, we will be receiving a continuous stream of numbers in some random order and we don’t know the stream length in advance. Write a function that finds the median of the already received numbers efficiently at any time. We will be asked to find the median multiple times. Just to recall, median is the middle element in an odd length sorted array, and in the even case it’s the average of the middle elements.

<!--more-->

## The solution

The best solution consists on having two heaps, a max-heap and a min-heap. These heaps will follow two rules:
  
&#8211; The max-heap contains the smallest half of the elements, the min-heap contain the largest half
  
&#8211; The number of elements in the max-heap will always be the same as the min-heap or one more

There is a heap library for node, so I will use it for the implementation:

```js
var heap = require('heap');

var minHeap = [];
var maxHeap = [];
var total = 0;

function insert(num) {
  if (total % 2 === 0) {
    // If this is an even element add it to maxHeap
    heap.push(maxHeap, -1 * num);
    total++;

    if (minHeap.length === 0) {
      return;
    }

    // If maxHeap's root became greater than minHeap's root then swap the roots
    if (-1 * maxHeap[0] > minHeap[0]) {
      toMin = -1 * heap.pop(maxHeap);
      toMax = -1 * heap.pop(minHeap);
      heap.push(maxHeap, toMax);
      heap.push(minHeap, toMin);
    }
  } else {
    // If this is an even element add it to max head. Then pop the lowest element
    // and add it to the min heap
    var toMin = -1 * heap.pushpop(maxHeap, -1 * num);
    heap.push(minHeap, toMin);
    total++;
  }
}

function getMedian() {
  if (total % 2 === 0) {
    // If the number of elements is even then we need to get both roots and
    // divide them by two
    return (-1 * maxHeap[0] + minHeap[0]) / 2;
  } else {
    // If the number of elements is odd return the head of the max heap
    return -1 * maxHeap[0];
  }
}

function test() {
  insert(1);
  insert(2);
  insert(3);

  if (getMedian() === 2) {
    console.log('success');
  }

  insert(4);

  if (getMedian() === 2.5) {
    console.log('success');
  }

  insert(9);

  if (getMedian() === 3) {
    console.log('success');
  }

}

test(); // Prints success 3 times
```
