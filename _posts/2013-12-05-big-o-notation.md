---
id: 1852
title: Big O Notation
date: 2013-12-05T06:52:44+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1852
permalink: /2013/12/big-o-notation/
tags:
  - computer_science
  - algorithms
  - programming
---
Big O notation is a way to represent how well an algorithm scales as the amount of data involved increases. I will go over some examples of the most common orders and try to explain what each one means:

## O(1)

This means that the algorithm will perform the same way no matter how long the data set is. This is usually the case for hash tables. Here is an example of an O(1) algorithm:

```js
var myArray = [];

function addToArray(num) {
  myArray.push(num);
}
```

<!--more-->

This algorithm is O(1) because it doesn&#8217;t matter how many items myArray has, addToArray will always take the same amount of time to execute.

## O(N)

This means that the algorithm&#8217;s run time will increase by measure for each new item in the data set. An example of this algorithm is a linear search:

```js
var haystack = ['orange', 'banana', 'apple', 'grape'];

function search(val) {
  var l = haystack.length;
  for (var i = 0; i < l; i++) {
    if (haystack[i] === val) {
      return i;
    }
  }
}
```

You can see the algorithm looping through the array so as the array gets bigger the execution time gets longer in proportion to the number of elements. You might also have noticed that if you try to search for &#8216;orange&#8217; the algorithm won&#8217;t have to loop through all the elements. Big O represents the worst case scenario. In this case, if the element you are searching was the last one, then it would take N to complete the search.

## O(N^2)

Imagine that you have an algorithm that takes 1 second to execute for 1 element array. If this algorithm was O(N^2) it would take it 4 seconds to execute for 2 elements, 9 seconds for 3 and so on. As you can see, this number gets large very fast, so you will want to avoid this kind of algorithms.

A common example of this kind of algorithm is the bubble sort, where you have two nested for loops. Each for loops takes O(N), but since they are nested it becomes O(N^2).

```js
var elements = [3, 4, 2, 5, 56, 900, 3, 1];

function sort(arr) {
  var temp;
  var l = elements.length;
  for (var i = l - 1; i >= 0; i--) {
    for (var j = 0; j < i; j++) {
      if (arr[j] > arr[j + 1]) {
        temp = arr[j];
        arr[j] = arr[j + 1];
        arr[j + 1] = temp;
      }
    }
  }

  return arr;
}
```

## O(Log N)

This is considered a very efficient algorithm (even better than O(N)) because as the amount of data increases the run time decreases. An example of this is a binary search:

```js
var haystack = [1, 3, 4, 5, 20, 56, 602, 701, 888, 900];

function binarySearch(val) {
  var last = haystack.length;
  var first = 0;
  while (first <= last) {
    var middle = parseInt((last + first) / 2, 10);
    if (val === haystack[middle]) {
      return middle;
    }

    if (val > haystack[middle]) {
      first = middle + 1;
    } else {
      last = middle - 1;
    }
  }
}
```

Because this algorithm takes a sorted array, it keeps cutting the elements in half until it finds a match and for that reason it is very efficient.

## O(N Log N)

This happens when an algorithm has to go through each of the elements at least once and also perform an operation similar to that of a binary search (cutting the elements in half for each step). The algorithm that has this performance is quicksort:

```js
var elements = [3, 4, 2, 5, 56, 900, 3, 1, 34, 23, 453, 2, 304, 22, 88, 888];

function partition(items, left, right) {
  var pivot = items[Math.floor((left + right) / 2)];

  while (left <= right) {
    while (items[left] < pivot) {
      left++;
    }

    while (items[right] > pivot) {
      right--;
    }

    if (left <= right) {
      var tmp = items[left];
      items[left] = items[right];
      items[right] = tmp;
      left++;
      right--;
    }
  }

  return left;
}

function quickSort(arr, l, r) {
  if (arr.length < 2) {
    return arr;
  }

  var i = partition(arr, l, r);

  if (l < i - 1) {
    quickSort(arr, l, i - 1);
  }

  if (i < r) {
    quickSort(arr, i, r);
  }

  return arr;
}
```

This algorithm is a lot more complex but it is a very efficient sorting algorithm.
