---
id: 2159
title: Reverse Words in a String
date: 2014-08-28T01:42:10+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2159
permalink: /2014/08/reverse-words-in-a-string/
tags:
  - algorithms
  - computer_science
  - javascript
  - programming
---
## The question

Given an input string, reverse all the words. To clarify, input: &#8220;Interviews are awesome!&#8221; output: &#8220;awesome! are Interviews&#8221;. Consider all consecutive non-whitespace characters as individual words. If there are multiple spaces between words reduce them to a single white space. Also remove all leading and trailing whitespaces. So, the output for &#8221; CS degree&#8221;, &#8220;CS degree&#8221;, &#8220;CS degree &#8220;, or &#8221; CS degree &#8221; are all the same: &#8220;degree CS&#8221;.

<!--more-->

## My solution

This question feels a little tricky because it looks easy but it makes me think that there are implications with the way strings are handled that should be taken into account. For a simple approach I would do this:

&#8211; Create an empty string
  
&#8211; Start at the last character
  
&#8211; If it is and empty space keep moving towards the first character until you find a letter.
  
&#8211; If it is a letter set a variable to the index of that letter
  
&#8211; Keep moving left until you find a space or the string ends
  
&#8211; When that happens grab all characters from that point until the first letter you found and add them to previously created string
  
&#8211; Repeat until you reach the end of the string

## The best solution

After taking a look at the best solution I realized that my solution wasn&#8217;t that bad but there is a way to solve the problem without using extra space: Reverse all the characters in the string, then reverse the letters of each individual word. This could be done inline if it wasn&#8217;t because in JS strings are immutable, which means:

```js
var s = 'asdf';
s[0] = 'b';
console.log(s); // Prints asdf
```

With this in mind this is my solution:

```js
function reverse(input) {
  var string = '';
  var end = null;

  // Start at the end
  for (var i = input.length; i !== 0; i--) {
    if (input[i - 1] !== ' ') {
      // If a letter was found and end has not been set (we are not in the
      // middle of a word) then set end
      if (end === null) {
        end = i - 1;
      }
    } else {
      // If this is a space and end is set (We were inside a word). Then add all
      // characters of the word to the string
      if (end !== null) {
        // Add a space as separator for all but the first string
        if (string.length) {
          string += ' ';
        }

        for (var j = i; j <= end; j++) {
          string += input[j];
        }

        end = null;
      }
    }
  }

  return string;
}

function test() {
  if ('world pretty hello' === reverse('  hello pretty  world      ')) {
    console.log('success');
  }
}

test(); // Prints success
```
