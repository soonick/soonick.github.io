---
id: 2167
title: Check Balanced Parentheses
date: 2014-07-10T05:48:00+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2167
permalink: /2014/07/check-balanced-parentheses/
categories:
  - Application Design
  - Computer science
tags:
  - algorithms
  - javascript
  - programming
---
## The question

Given a string of opening and closing parentheses, check whether it’s balanced. We have 3 types of parentheses: round brackets: (), square brackets: [], and curly brackets: {}. Assume that the string doesn’t contain any other character than these. No spaces, words or numbers. Just to remind, balanced parentheses require every opening parenthesis to be closed in the reverse order opened. For example ‘([])’ is balanced but ‘([)]‘ is not.

<!--more-->

## My solution

I have faced similar problems in the past(building a calculator) so this exercise didn&#8217;t seem that hard:

&#8211; Start on the first character and repeat for each character
  
&#8211; If that character is an opening brace add it to a stack
  
&#8211; If that character is a closing brace pop from the stack
  
&#8211; If the popped brace matches the current brace then continue
  
&#8211; If the popped brace doesn&#8217;t match the current brace then fail
  
&#8211; At the end if the stack is not empty then fail

This seems to be the best solution for this problem, so lets see the code:

```js
var stack = [];

function checkParentheses(word) {
  var map = {
    '(': ')',
    '[': ']',
    '{': '}'
  };
  for (var i = 0; i < word.length; i++) {
    if (word[i] === '(' || word[i] === '[' || word[i] === '{') {
      stack.push(word[i]);
    } else {
      var last = stack.pop();

      if (word[i] !== map[last]) {
        return false;
      }
    }
  }

  if (stack.length !== 0) {
    return false;
  }

  return true;
}

function test() {
  if (checkParentheses('([]{}){}[]') === true) {
    console.log('success');
  }

  if (checkParentheses('([]{}{}[]') === false) {
    console.log('success');
  }

  if (checkParentheses('([]{}){}[]}') === false) {
    console.log('success');
  }
}

test(); // Prints success three times
```
