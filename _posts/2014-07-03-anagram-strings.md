---
id: 2182
title: Anagram strings
date: 2014-07-03T06:25:00+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2182
permalink: /2014/07/anagram-strings/
tags:
  - computer_science
  - algorithms
  - javascript
  - programming
---
## The question

Given two strings, check if they’re anagrams or not. Two strings are anagrams if they are written using the same exact letters, ignoring space, punctuation and capitalization. Each letter should have the same count in both strings. For example, ‘Eleven plus two’ and ‘Twelve plus one’ are meaningful anagrams of each other.

## My solution

The solution I came up with consists of having a hash-table where we will store how many times a character is found in string1. Then we will do the same for string2. At the end these should match.

<!--more-->

```js
var string1 = 'I like to eat tacos';
var string2 = 'A cat like ties too';
var string3 = 'I like to eat burritos';

function areAnagrams(s1, s2) {
  // Make them lowercase so we don't have to worry about that
  s1 = s1.toLowerCase();
  s2 = s2.toLowerCase();

  var letters = 'abcdefghijklmnopqrstuv';
  var found = {};

  // Add the keys to the hashtable
  for (var i = 0; i < s1.length; i++) {
    // Only do it if it is a letter
    if (-1 !== letters.indexOf(s1[i])) {
      if (undefined === found[s1[i]]) {
        // If this is the first time we see this letter then count is 1
        found[s1[i]] = 1;
      } else {
        // Increase the count for this letter
        found[s1[i]]++;
      }
    }
  }

  // Check all letters in s2
  for (i = 0; i < s2.length; i++) {
    // We only care about letters
    if (-1 !== letters.indexOf(s2[i])) {
      // If the letter is not there or it is already 0 then this is not
      // an anagram
      if (!found[s2[i]]) {
        return false;
      }

      found[s2[i]]--;
    }
  }

  // Check that at the end all letters are 0
  for (i in found) {
    if (found[i] !== 0) {
      return false;
    }
  }


  return true;
}

function test() {
  if (areAnagrams(string1, string2) && !areAnagrams(string1, string3)) {
    console.log('success');
  }
}

test(); // Prints success
```

The complexity of this is something line O(n) + O(m) because you have to go through both strings once to find if they have the same letters.
