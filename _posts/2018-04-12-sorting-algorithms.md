---
id: 2195
title: Sorting algorithms
date: 2018-04-12T03:09:25+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2195
permalink: /2018/04/sorting-algorithms/
tags:
  - computer_science
  - algorithms
  - javascript
  - programming
---
This is a refresher of sorting algorithms since I recently realized that I don&#8217;t remember how a lot of the most common sorting algorithms work. I&#8217;m only going to focus on arrays on this article since it is the most common structure for these kind of problems.

## Bubble sort

This is the first algorithm we learn at school. It is not very efficient(O(n ^ 2) in most of the cases) but it is pretty easy to implement.

  * Grab the first two elements(0 and 1) in an array and compare them
  * If the element in the left is higher than the elements in the right then swap them
  * Grab the next two elements(1 and 2) and do the same
  * Repeat until the greatest element is in the far right
  * Do the same starting from the first two elements(0 and 1) but ending before reaching the last element(which is already sorted)
  * At the end the array will be sorted

<!--more-->

The JavaScript code looks like this:

```js
function bubbleSort(a) {
  for (var limit = a.length - 1; limit > 0; limit--) {
    var swapped = false;

    for (var i = 0; i < limit; i++) {
      if (a[i] > a[i + 1]) {
        swapped = true;
        var t = a[i];
        a[i] = a[i + 1];
        a[i + 1] = t;
      }
    }

    if (!swapped) {
      return;
    }
  }
}
```

## Insertion sort

This is another very simple sorting algorithm. In the worst case scenario it will take O(n ^ 2) but in the best case scenario it will take O(n). The algorithm works like this:

  * Grab the second element and compare it with the first
  * If the second element is lower, swap it with the first one
  * Now the two first elements are sorted
  * Grab the third element and compare it with the elements at its left one by one
  * When you find one that is smaller then place the third element next to that one and move all elements one space to the right
  * If no element is smaller then place the third element at the beginning
  * Repeat for all elements in the array

The JavaScript code looks like this:

```js
function insertionSort(a) {
  for (var current = 1; current < a.length; current++) {
    for (var compared = current; compared > 0; compared--) {
      if (a[compared - 1] > a[compared]) {
        var temp = a[compared];
        a[compared] = a[compared - 1];
        a[compared - 1] = temp;
      }
    }
  }
}
```

## Quick sort

This is a very efficient algorithm that usually takes O(n log n) but has a worst case of O(n ^ 2). This algorithm is the one used by many programming languages and standard libraries for sorting arrays because of its efficiency. The algorithm goes like this:

  * Choose a pivot (I&#8217;ll talk more about this later)
  * Make all elements at the left of the pivot lower than the pivot and all elements at the right larger
  * Repeat recursively for both halves

The choice of pivot can greatly affect the performance of quick sort. If you chose the first element as the pivot and the array was already sorted then the performance would be O(n ^ 2). Good options to choose a pivot are:

  * Random
  * The element at the middle
  * Median of three: Look at the first element, the last element and the element at the middle and choose the median

The JavaScript code looks like this when using the median of three strategy:

```js
function quickSort(a) {
  function sort(a, left, right) {
    // If there is one element or less there is nothing to do
    if (right - left <= 1) {
      return;
    }

    // Calculate the pivot using the median of three
    var middle = parseInt((left + right) / 2, 10);
    var pivot = [a[left], a[right], a[middle]].sort()[1];

    // Move all larger elements to right and lower to left. At the end the value
    // of i is the division between lower and larger elements
    var i = left;
    var j = right;
    while (i <= j) {
      while (a[i] < pivot) {
        i++;
      }

      while (a[j] > pivot) {
        j--;
      }

      if (i <= j) {
        var temp = a[i];
        a[i] = a[j];
        a[j] = temp;
        i++;
        j--;
      }
    }

    // If there is a left side, sort it
    if (left < i - 1) {
      sort(a, left, i - 1);
    }

    // If there is a right side sort it
    if (i < right) {
      sort(a, i, right);
    }
  }

  sort(a, 0, a.length - 1);
}
```

As you can see this algorithm is a lot larger than the previous algorithms, so it is a tradeoff between code complexity and execution time. Most of the time the benefits will make it worth the extra complexity.

## Merge sort

This algorithm has a complexity of O(n log n) in all cases with the tradeoff of requiring O(n) extra space. These are the steps:

  * Divide the array in n sub arrays.
  * Merge the first two sub arrays in sorted order
  * Merge the third and fourth arrays in sorted order
  * Continue doing this until there are no more arrays
  * Continue merging recursively

```js
function mergeSort(a) {
  var middle = parseInt(a.length / 2, 10);
  var left = [];
  var right = [];

  if (a.length > 1) {
    // Left array
    for (var i = middle - 1; i >= 0; i--) {
      left[i] = a[i];
    }

    // Right array
    for (i = a.length - 1; i >= middle; i--) {
      right[i - middle] = a[i];
    }

    mergeSort(left);
    mergeSort(right);
  }

  // Merge two arrays together into a given array
  function merge(array, left, right) {
    var l = left.length - 1;
    var r = right.length - 1;
    var c = array.length - 1;

    while (l >= 0 || r >= 0) {
      if (r === -1 || left[l] > right[r]) {
        array[c] = left[l];
        l--;
      } else {
        array[c] = right[r];
        r--;
      }
      c--;
    }
  }

  merge(a, left, right);
}
```
