---
id: 2157
title: All permutations of a string
date: 2014-08-14T01:29:10+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2157
permalink: /2014/08/all-permutations-of-a-string/
tags:
  - computer_science
  - algorithms
  - javascript
  - programming
---
## The question

Generate all permutations of a given string.

## My solution

This is a question that I had been asked before and I wasn&#8217;t able to solve in the duration of an interview. I took some time to think about the problem and this is what I came with.

There are going to be n! permutations so that is what I should expect. The permutations of a string of length 1 is the string itself. The permutations for a string of length two is the string and the reversed string. With this in mind I came up with this recursive algorithm:

<!--more-->

&#8211; The name of the function will be **permute**
  
&#8211; If the length of the input is 1 then return the string
  
&#8211; If the length of the input is 2 then return the string and the reversed string
  
&#8211; If the length of the string is more than 2 then initialize an empty array and start with the first character:
  
&#8211; Remove current character from string and get all the permutations for that string using **permute**
  
&#8211; Do the same removing one character at a time
  
&#8211; When you are done with the characters then return the permutations array

The code explains it better:

```js
function permute(input) {
  var permutations = [];

  if (input.length === 2) {
    permutations.push(input);
    permutations.push(input[1] + input[0] + '');
    return permutations;
  }

  for (var i = 0; i < input.length; i++) {
    var p = permute(input.substr(0, i) + input.substr(i + 1));
    for (var j in p) {
      permutations.push(input[i] + p[j]);
    }
  }

  return permutations;
}

function test() {
  var permutations = permute('abc');

  var expected = ['abc', 'acb', 'bac', 'bca', 'cab', 'cba'];
  if (JSON.stringify(expected) === JSON.stringify(permutations)) {
    console.log('success');
  }
}

test(); // Prints success
```

I am not sure about the complexity of this algorithm but I think it would be n! if it wasn&#8217;t because I am moving permutations from one array to another.

## The best solution

The solution proposed by Arden suggests the following: Given a string of length n, get the permutations of the sub-string with length n-1 and then insert the missing letter in all possible positions within the permutations.

Here is the code:

```js
function permute(input) {
  if (input.length <= 1) {
    return [input];
  }

  // Get all permutations for length - 1
  var perms = permute(input.substring(1));
  var c = input[0];
  var res = [];

  // Place c in all posible locations within the permutations
  for (var p in perms) {
    for (var i = 0; i < input.length; i++) {
      res.push(perms[p].substring(0, i) + c + perms[p].substring(i));
    }
  }

  return res;
}

function test() {
  var permutations = permute('abc');

  var expected = ['abc', 'bac', 'bca', 'acb', 'cab', 'cba'];
  if (JSON.stringify(expected) === JSON.stringify(permutations)) {
    console.log('success');
  }
}

test(); // Prints success
```

I ran both solutions a few times and Ardens solution performs better than mine. This is probably because I do more string and array operations than him.
