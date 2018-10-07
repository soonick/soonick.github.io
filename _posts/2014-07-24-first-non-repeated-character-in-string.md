---
id: 2170
title: First Non Repeated Character in String
date: 2014-07-24T05:43:15+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2170
permalink: /2014/07/first-non-repeated-character-in-string/
categories:
  - Application Design
  - Computer science
tags:
  - algorithms
  - javascript
  - programming
---
## The question

Find the first non-repeated (unique) character in a given string.

## My answer

At first glance I am tempted to start from the left and add each character go to a hashtable with the number of times I have seen it. Once I have gone through the whole string I will do it again now searching for the first character that returns 1.

<!--more-->

This seems to be the right solution so lets look at the code:

```js
function checkFirstNonRepeated(word) {
  var map = {};

  for (var i = 0; i < word.length; i++) {
    if (undefined === map[word[i]]) {
      map[word[i]] = 1;
    } else {
      map[word[i]]++;
    }
  }

  for (i = 0; i < word.length; i++) {
    if (1 === map[word[i]]) {
      return word[i];
    }
  }
}

function test() {
  if (checkFirstNonRepeated('asdfasdf') === undefined) {
    console.log('success');
  }

  if (checkFirstNonRepeated('asdfasd') === 'f') {
    console.log('success');
  }
}

test(); // Prints success twice
```
