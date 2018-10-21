---
id: 2116
title: Combine Two Strings
date: 2014-08-01T01:56:03+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2116
permalink: /2014/08/combine-two-strings/
tags:
  - application_design
  - computer_science
  - algorithms
  - javascript
  - programming
---
## The question

We are given 3 strings: str1, str2, and str3. Str3 is said to be a shuffle of str1 and str2 if it can be formed by interleaving the characters of str1 and str2 in a way that maintains the left to right ordering of the characters from each string. For example, given str1=&#8221;abc&#8221; and str2=&#8221;def&#8221;, str3=&#8221;dabecf&#8221; is a valid shuffle since it preserves the character ordering of the two strings. So, given these 3 strings write a function that detects whether str3 is a valid shuffle of str1 and str2.

<!--more-->

## The solution

When I read the question for the first time I though edge cases might make this a little tricky, but it seems like they take care of themselves. What I thought of doing is:

&#8211; Set one pointer to the last letter of str1
  
&#8211; Set one pointer to the last letter of str2
  
&#8211; Set one pointer to the last letter of str3
  
&#8211; Grab the letter at str3 and compare it to the letter at str2.
  
&#8211; If they match move str3 and str2 one letter to the left
  
&#8211; If they don&#8217;t match then compare str3 to str1
  
&#8211; If they match move str3 and str1 one letter to the left
  
&#8211; If they don&#8217;t match then str3 is not a shuffle
  
&#8211; Repeat until there are not more letters on str3

This seems to work fine for all the tests I did and the complexity is O(n), where n is the length of the shuffle.

```js
function isShuffle(str1, str2, shuffle) {
  var pointer1 = str1.length - 1;
  var pointer2 = str2.length - 1;
  var shufflePointer = shuffle.length - 1;

  while (shufflePointer >= 0) {
    if (shuffle[shufflePointer] === str2[pointer2]) {
      pointer2--;
    } else if (shuffle[shufflePointer] === str1[pointer1]){
      pointer1--;
    } else {
      return false;
    }

    shufflePointer--;
  }
  return true;
}

function test() {
  if (isShuffle('acc', 'abc', 'abaccc') === true &&
      isShuffle('acc', 'abc', 'baacc') === false) {
    console.log('success');
  }
}

test(); // Prints success
```

The recommended solution on [Arden&#8217;s site](http://www.ardendertat.com/2011/10/10/programming-interview-questions-6-combine-two-strings/ "Arden Dertat") uses recursion but it doesn&#8217;t seem like it is more efficient than my suggested solution so I&#8217;ll stick to my version.
