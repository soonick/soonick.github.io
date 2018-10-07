---
id: 2150
title: Kth Largest Element in Array
date: 2014-11-27T01:54:25+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2150
permalink: /2014/11/kth-largest-element-in-array/
categories:
  - Application Design
  - Computer science
tags:
  - algorithms
  - javascript
  - programming
---
## The question

Given an array of integers find the kth element in the sorted order (not the kth distinct element). So, if the array is [3, 1, 2, 1, 4] and k is 3 then the result is 2, because it’s the 3rd element in sorted order (but the 3rd distinct element is 3).

## My solution

This doesn&#8217;t sound as a very hard problem but I couldn&#8217;t find a solution better than:

&#8211; Sort using quicksort
  
&#8211; Return the element at index k

The complexity of this solution is the complexity of quicksort O(nlogn).

<!--more-->

## The best solution

The best solution is a family of algorithms called &#8220;selection algorithm&#8221; which serves exactly this purpose. Most specifically quickselect can be used:

```js
var arr = [1, 5, 6, 6, 9, 2, 3, 3, 4, 3, 1, 9, 4, 5, 7, 7, 1];

function partition(arr, left, right, pivot) {
  // Move pivot to the end
  var tmp;
  tmp = arr[pivot];
  arr[pivot] = arr[right];
  arr[right] = tmp;

  // This is the index that divides lower and higher numbers
  var swapIndex = left;

  for (var i = left; i < right; i++) {
    // Check if current value is lower than pivot value
    if (arr[i] < arr[right]) {
      tmp = arr[i];
      arr[i] = arr[swapIndex];
      arr[swapIndex] = tmp;
      swapIndex++;
    }
  }

  // Move pivot value to where it should be
  tmp = arr[right];
  arr[right] = arr[swapIndex];
  arr[swapIndex] = tmp;

  return swapIndex;
}

function select(arr, left, right, k) {
  // I don't care very much about the pivot now. I'm just choosing the middle.
  var pivot = parseInt((left + right) / 2, 10);
  var res = partition(arr, left, right, pivot);

  if (res === k) {
    return arr[res];
  }

  if (k < res) {
    return select(arr, left, res - 1, k);
  } else {
    return select(arr, res + 1, right, k);
  }
}

function test() {
  var found = select(arr, 0, arr.length -1, 6);

  if (found === 3) {
    console.log('success');
  }
}

test(); // Prints success
```
