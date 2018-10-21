---
id: 2222
title: Binary search
date: 2015-02-25T19:14:36+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2222
permalink: /2015/02/binary-search/
tags:
  - computer_science
  - algorithms
  - javascript
  - programming
---
I was just going through the basics and I wanted to verify that I still knew how to do a binary search. If I remember correctly these are the steps:

&#8211; Set a left pointer at the beginning of the sorted array
  
&#8211; Set a right pointer at the end of the sorted array
  
&#8211; Calculate the middle between those two pointers(If there is no exact middle, truncate the number) and set the a middle pointer there
  
&#8211; Check if the middle is the number you are looking for. If it is return
  
&#8211; If the element at middle is greater than the element you are looking for set the left pointer to middle + 1
  
&#8211; If the element at middle is lower than the element you are looking for set the right pointer to middle &#8211; 1
  
&#8211; Repeat until the number is found or left is greater than right (not found)

<!--more-->

Here is the implementation in JS:

```js
var array = [1, 2, 3, 4, 6, 7, 9, 22, 44, 66, 77, 99, 989, 1345, 7777, 7779, 9999, 10000000];

function binarySearch(needle, haystack) {
  function search(needle, haystack, left, right) {
    if (left > right) {
      return -1;
    }

    // We do left + ((right - left) / 2) instead of the simpler
    // (right + left) / 2 to avoid an overflow when right + left
    // becomes too big
    var middle = parseInt(left + ((right - left) / 2), 10);

    if (haystack[middle] === needle) {
      return middle;
    }

    if (haystack[middle] > needle) {
      return search(needle, haystack, left, middle - 1);
    }

    if (haystack[middle] < needle) {
      return search(needle, haystack, middle + 1, right);
    }
  }

  return search(needle, haystack, 0, haystack.length -1);
}

console.log(binarySearch(1, array)); // Found in 0
console.log(binarySearch(2, array)); // Found in 1
console.log(binarySearch(10000000, array)); // Found in 17
console.log(binarySearch(77, array)); // Found in 10
console.log(binarySearch(54, array)); // Not found (-1)
```
