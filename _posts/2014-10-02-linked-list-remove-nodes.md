---
id: 2107
title: Linked List Remove Nodes
date: 2014-10-02T02:24:32+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2107
permalink: /2014/10/linked-list-remove-nodes/
tags:
  - computer_science
  - algorithms
  - javascript
  - programming
---
## The question

Given a linked list of integers and an integer value, delete every node of the linked list containing that value.

## The solution

The tricky part about this problem is taking care of the edge cases. You have to go through all the elements in the list, so the efficiency is O(n).

  * Initialize one variable(lastGood) to null
  * Initialize one variable(first) to the head
  * Check the first element on the linked list(current) 
      * If it is not the number you are looking for assign lastGood=current and move current to the next node
      * If it is the number then check if lastGood has a value assigned 
          * if lastGood doesn&#8217;t have a value it means we want to remove the first item so assign first to current.next
          * if lastGood has a value then assign lastGood.next to current.next
  * Repeat for all elements

<!--more-->

Here is the source code:

```js
// This works like a linked list
// 3 -> 3 -> 5 -> 3
head = {
  value: 3,
  next: {
    value: 3,
    next: {
      value: 5,
      next: {
        value: 3,
        next: null
      }
    }
  }
};

function removeNodes(listHead, remove) {
  var first = listHead;
  var current = listHead;
  var lastGood = null;
  while (current) {
    if (current.value === remove) {
      if (lastGood) {
        lastGood.next = current.next;
      } else {
        first = current.next;
      }
    } else {
      lastGood = current;
    }

    current = current.next;
  }

  return first;
}

function test() {
  var result = removeNodes(head, 3);

  if (result.value === 5 && result.next === null) {
    console.log('success');
  } else {
    console.log('failure');
  }
}

test(); // Prints success
```
