---
id: 2140
title: Convert Array
date: 2014-11-13T02:24:45+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2140
permalink: /2014/11/convert-array/
tags:
  - computer_science
  - algorithms
  - javascript
  - programming
---
## The question

Given an array [a1, a2, &#8230;, aN, b1, b2, &#8230;, bN, c1, c2, &#8230;, cN] convert it to [a1, b1, c1, a2, b2, c2, &#8230;, aN, bN, cN] in-place using constant extra space

## My solution

At first this question felt a little confusing so lets clear a few things.
  
&#8211; There will only be a, b and c
  
&#8211; The size of the array is going to be `N*3`
  
&#8211; The problem needs to be solved without creating an extra array so the modifications need to be made in the same array

<!--more-->

The algorithm:

1 &#8211; Start at the element at index 1 (We know the element at index 0 is in the right place already)
  
2 &#8211; Check if the element is already in the place it should be. If it is, continue to next element.
  
3 &#8211; If the element is not in the right place grab the element that should be in that place and move this element to the other element location.
  
4 &#8211; Repeat for all elements

This is the code:

```js
var arr = ['a1', 'a2', 'a3', 'a4', 'b1', 'b2', 'b3', 'b4', 'c1', 'c2', 'c3', 'c4'];

function convertArray(arr) {
  var letters = ['a', 'b', 'c'];
  var maxNumber = arr.length / 3;

  function moveToExpected(index) {
    var expectedNumber = (Math.floor(index / 3)) + 1;
    var expectedLetter = letters[(index % 3)];

    if (arr[index] !== expectedLetter + expectedNumber) {
      var expectedElementPosition = (index % 3) * maxNumber +
          (Math.floor(index / 3));
      var tmp = arr[index];
      arr[index] = arr[expectedElementPosition];
      arr[expectedElementPosition] = tmp;
      moveToExpected(expectedElementPosition);
    }
  }

  var secondLast = arr.length - 1;
  for (var i = 1; i < secondLast; i++) {
    moveToExpected(i);
  }
}

function test() {
  convertArray(arr);

  var expected = ['a1', 'b1', 'c1', 'a2', 'b2', 'c2', 'a3', 'b3', 'c3', 'a4', 'b4', 'c4'];
  if (JSON.stringify(expected) === JSON.stringify(arr)) {
    console.log('success');
  }
}

test(); // Prints success
```

This gets the job done in a kind of efficient way but I am not sure about the O notation for this. It will go through all elements in the array and for some of them it will do some swaps. It is more than O(n) but less than O(n^2).

## The best solution

The solution they propose is a little similar:

1 &#8211; Start at the element at index 1 (We know the element at index 0 is in the right place already)
  
2 &#8211; Get the index of the element that should be in this location.
  
3 &#8211; If the index is higher than the current index then we can just swap those two elements
  
4 &#8211; If the index is lower that means that the element has been already swapped so we have to follow the swaps until current index is lower than the swap index and then do the swap
  
5 &#8211; Repeat for all elements

This is the code:

```js
function convertArray(arr) {
  var n = arr.length / 3;

  function getIndex(current) {
    return (current % 3) * n + (current / 3);
  }

  var swap;
  var tmp;
  for (var i = 0; i < arr.length; i++) {
    swap = Math.floor(getIndex(i));
    while (swap < i) {
      swap = Math.floor(getIndex(swap));
    }
    tmp = arr[i];
    arr[i] = arr[swap];
    arr[swap] = tmp;
  }
}

function test() {
  convertArray(arr);

  var expected = ['a1', 'b1', 'c1', 'a2', 'b2', 'c2', 'a3', 'b3', 'c3', 'a4', 'b4', 'c4'];
  if (JSON.stringify(expected) === JSON.stringify(arr)) {
    console.log('success');
  }
}

test(); // Prints success
```

They explain the complexity as O(N^1.3) which is some times called super linear.
