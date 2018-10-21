---
id: 2135
title: Transform word
date: 2014-10-08T19:43:34+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2135
permalink: /2014/10/transform-word/
tags:
  - application_design
  - computer_science
  - algorithms
  - javascript
  - programming
---
## The question

Given a source word, target word and an English dictionary, transform the source word to target by changing/adding/removing 1 character at a time, while all intermediate words being valid English words. Return the transformation chain which has the smallest number of intermediate words.

## The solution

There are two parts to solving this problem. First we need to create a graph of the dictionary where each edge corresponds to a valid transformation of a word. We can represent this graph using a hash table (an object in JS). Then we do a breadth first search on this graph and that will give us the most efficient path.

<!--more-->

```js
var dictionary = {
  ad: true,
  at: true,
  ate: true,
  bat: true,
  bed: true,
  bet: true,
  cat: true,
  ed: true,
  table: true
};

function createGraph(dict) {
  var graph = {};
  var letters = 'abcdefghijklmnopqrstuvwxyz';
  var i;
  var j;

  // For all words
  for (var word in dictionary) {
    // For all characters in the word
    for (i = 0; i < word.length; i++) {
      // Remove character
      var removeWord = word.substring(0, i) + word.substring(i + 1);
      if (dictionary[removeWord]) {
        if (!graph[word]) {
          graph[word] = {};
        }

        graph[word][removeWord] = true;
      }

      // Change a character
      for (j = 0; j < letters.length; j++) {
        var changedWord = word.substring(0, i) + letters[j] +
            word.substring(i + 1);

        if (changedWord != word && dictionary[changedWord]) {
          if (!graph[word]) {
            graph[word] = {};
          }

          graph[word][changedWord] = true;
        }
      }
    }

    // Add a character
    for (i = 0; i < word.length + 1; i++) {
      for (j = 0; j < letters.length; j++) {
        var addWord = word.substring(0, i) + letters[j] +
            word.substring(i);

        if (dictionary[addWord]) {
          if (!graph[word]) {
            graph[word] = {};
          }

          graph[word][addWord] = true;
        }
      }
    }
  }

  return graph;
}

function transformWord(graph, start, goal) {
  var paths = [[start]];
  var extended = [];

  while (paths.length) {
    var currentPath = paths.shift();
    var currentWord = currentPath[currentPath.length - 1];

    if (currentWord === goal) {
      return currentPath;
    } else if (-1 !== extended.indexOf(currentWord)) {
      continue;
    }

    extended.push(currentWord);
    transforms = graph[currentWord];
    for (var index in transforms) {
      if (-1 === currentPath.indexOf(index)) {
        var newPathStr = JSON.stringify(currentPath);
        var newPath = JSON.parse(newPathStr);
        newPath.push(index);
        paths.push(newPath);
      }
    }
  }
}

// This creates this graph:
// {
//   ad: { ed: true, at: true },
//   at: { ad: true, bat: true, cat: true, ate: true },
//   ate: { at: true },
//   bat: { at: true, cat: true, bet: true },
//   bed: { ed: true, bet: true },
//   bet: { bat: true, bed: true },
//   cat: { at: true, bat: true },
//   ed: { ad: true, bed: true }
// }
// Note that the word table is not there.
// This is because it doesn't have any connections
var graph = createGraph(dictionary);

function test() {
  var path = transformWord(graph, 'ad', 'bed');
  var expected = ['ad', 'ed', 'bed'];
  if (JSON.stringify(path) === JSON.stringify(expected)) {
    console.log('success');
  }
}

test(); // Prints success
```

Since creating the graph can be done in a pre-processing step we can ignore that time. The complexity of a breadth first seach is O(n), so that is the complexity of this solution.
