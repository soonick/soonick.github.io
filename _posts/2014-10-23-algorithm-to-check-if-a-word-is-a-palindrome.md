---
id: 2225
title: Algorithm to check if a word is a palindrome
date: 2014-10-23T01:29:39+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2225
permalink: /2014/10/algorithm-to-check-if-a-word-is-a-palindrome/
tags:
  - application_design
  - computer_science
  - algorithms
  - javascript
  - programming
---
## The question

Given a word, verify if it is a palindrome excluding spaces and punctuation.

## The solution

This is the algorithm I came up to find out if a word is a palindrome:

&#8211; Place a pointer(left) on the first character
  
&#8211; Place a pointer(right) on the last character
  
&#8211; Check if the element at left is a character (not punctuation or space)
  
&#8211; If the element is not a character move the pointer one space to the right until you find a character
  
&#8211; Check if the element at right is a character
  
&#8211; If the element is not a character move the pointer one space to the left
  
&#8211; If left is greater than right return true
  
&#8211; Check if left and right elements are the same
  
&#8211; If they are not the same return false
  
&#8211; If they are the same move left one space to the right and right one space to the left
  
&#8211; Start over from step three

<!--more-->

This would be the JavaScript implementation:

```js
var palindrome = 'Anita lava la tina';
var palindrome2 = 'A man, a plan, a canal: Panama';
var notPalindrome = 'A man is not panama';

function isPalindrome(word) {
  function isCharacter(needle) {
    var haystack = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

    if (-1 !== haystack.indexOf(needle)) {
      return true;
    }

    return false;
  }

  var left = 0;
  var right = word.length - 1;

  while (left <= right) {
    while (!isCharacter(word[left])) {
      left++;
    }

    while(!isCharacter(word[right])) {
      right--;
    }

    if (word[left].toLowerCase() !== word[right].toLowerCase()) {
      return false;
    }

    left++;
    right--;
  }

  return true;
}

console.log(isPalindrome(palindrome)); // true
console.log(isPalindrome(palindrome2)); // true
console.log(isPalindrome(notPalindrome)); // false
```
