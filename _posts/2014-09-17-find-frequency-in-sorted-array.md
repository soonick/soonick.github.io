---
id: 2228
title: Find frequency in sorted array
date: 2014-09-17T22:56:04+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2228
permalink: /2014/09/find-frequency-in-sorted-array/
tags:
  - application_design
  - computer_science
  - algorithms
  - javascript
  - programming
---
## The question

Given a sorted array that can include duplicates find the number of times that a given number appears in the array.

## The solution

The first thing that came to my mind was to do a binary search for the element and then check how many times it appears to the left and how many times it appears to the right. This has the drawback that if the array has a large number of appearances for that number then the performance might be greatly degraded because we would have to linearly search left and right.
  
To overcome this limitation we would need to do a custom binary search that searches for the first occurrence of a value and another that searches for the last element. Once we have those indexes we can find the difference and that is the number of appearances:

<!--more-->

```js
var a1 = [1, 1, 1, 1, 1, 1, 1];
var a2 = [1, 2, 3, 4, 5, 5, 5, 5, 6, 6, 6, 6, 7, 8, 8];
var a3 = [1, 1, 1, 1, 1, 1, 1];

/**
 * Performs a binary search for the first occurrence of the needle.
 * If last is true it will look for the last occurrence instead
 */
function binarySearch(needle, haystack, last) {
  function search(needle, haystack, left, right) {
    if (left > right) {
      return -1;
    }

    var middle = left + parseInt((right - left) / 2, 10);

    // If we found the needle we still have to make sure this is the first
    // or last occurrence
    if (haystack[middle] === needle) {
      if (!last) {
        // If this is the beginning of the array then we know this is the first
        // occurrence. Otherwise if the element at the left is not different
        // we need to keep searching.
        if (middle === 0 || haystack[middle - 1] !== needle) {
          return middle;
        } else {
          return search(needle, haystack, left, middle - 1);
        }
      } else {
        // If this is the end of the array then we know this is the last
        // occurrence. Otherwise if the element at the right is not different
        // we need to keep searching.
        if (middle === right || haystack[middle + 1] !== needle) {
          return middle;
        } else {
          return search(needle, haystack, middle + 1, right);
        }
      }
    }

    if (haystack[middle] > needle) {
      return search(needle, haystack, left, middle - 1);
    }

    if (haystack[middle] < needle) {
      return search(needle, haystack, middle + 1, right);
    }
  }

  return search(needle, haystack, 0, haystack.length - 1);
}

function findFrequency(needle, haystack) {
  var first = binarySearch(needle, haystack);
  var last = binarySearch(needle, haystack, true);

  if (first === -1 || last === -1) {
    return 0;
  }

  return last - first + 1;
}

console.log(findFrequency(1, a1)); // 7
console.log(findFrequency(5, a2)); // 4
console.log(findFrequency(5, a3)); // 0
```
