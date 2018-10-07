---
id: 2123
title: Binary Search Tree Check
date: 2014-10-16T01:09:48+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2123
permalink: /2014/10/binary-search-tree-check/
categories:
  - Application Design
  - Computer science
tags:
  - algorithms
  - javascript
  - programming
---
## The question

Given a binary tree, check whether it’s a binary search tree or not.

## My solution

I cheated a little in this question because I didn&#8217;t remember what a binary search tree is. After checking wikipedia I found the characteristic of a BST:

&#8211; The left subtree of a node contains only nodes with keys less than the node&#8217;s key.
  
&#8211; The right subtree of a node contains only nodes with keys greater than the node&#8217;s key.
  
&#8211; The left and right subtree each must also be a binary search tree.
  
&#8211; Each node can have up to two successor nodes.
  
&#8211; There must be no duplicate nodes.

<!--more-->

At the beginning I fell in the trap of going through every node and checking that it was greater than the left and lower than the right but as wikipedia shows. There are scenarios when this simple check wouldn&#8217;t work. With this in mind I came with a solution that even though is O(n), it is probably a little convoluted:

&#8211; Create a function(isBst)
  
&#8211; The function will return false if the node doesn&#8217;t correspond to a BST.
  
&#8211; The function will return either the highest number found in the given node if true was passed in the second argument, or the lowest if there was no second argument.
  
&#8211; Call the function with the root of the tree you want to check
  
&#8211; If the root is null return null
  
&#8211; Create a variable(right) and assign the lowest value on the right node(isBst(root.right))
  
&#8211; Create a variable(left) and assign the highest value on the left node(isBst(root.left, true))
  
&#8211; If right is lower than root or left is higher than root then return false
  
&#8211; If higher was passed as a second argument then return right if it is not null, if it is return root
  
&#8211; If higher was not passed as a second argument then return left if it is not null, if it is return root

## The best solution

There are two other solutions that are also O(n) but are a little more elegant. One of them consists of passing the max and min allowed values every time we call isBst. The simplest one seems to consist of traversing the three in order and verifying that the values are output in order.

```js
/*
       8
     /   \
    3     10
  /  \      \
 1   6       14
    / \     /
   4   7   13

*/
var bst = {
  val: 8,
  left: {
    val: 3,
    left: {
      val: 1,
      left: null,
      right: null
    },
    right: {
      val: 6,
      left: {
        val: 4,
        left: null,
        right: null
      },
      right: {
        val: 7,
        left: null,
        right: null
      }
    }
  },
  right: {
    val: 10,
    left: null,
    right: {
      val: 14,
      left: {
        val: 13,
        left: null,
        right: null
      },
      right: null
    }
  }
};

/*
         20
       /    \
     10      30
            /   \
           5     40
*/
var bt = {
  val: 20,
  left: {
    val: 10,
    left: null,
    right: null
  },
  right: {
    val: 30,
    left: {
      val: 5,
      left: null,
      right: null
    },
    right: {
      val: 40,
      left: null,
      right: null
    }
  }
};

// My solution
// Returns false if the root doesn't belong to a BST, otherwise it returns
// if higher is true: the value of the right node
// if higher is not true: the value of the left node
function isBst(root, higher) {
  if (root === null) {
    return null;
  }

  var right = isBst(root.right);
  if (right === false) {
    return false;
  }
  var left = isBst(root.left, true);
  if (left === false) {
    return false;
  }

  if ((right === null || root.val < right) && (left === null || root.val > left)) {
    var returnVal;
    if (higher) {
      returnVal = right === null ? root.val : right;
    } else {
      returnVal = left === null ? root.val : left;
    }
    return returnVal;
  } else {
    return false;
  }
}

// Min and max
function isBst2(root, min, max) {
  if (min === undefined) {
    min = Number.NEGATIVE_INFINITY;
  }
  if (max === undefined) {
    max = Number.POSITIVE_INFINITY;
  }

  if (root === null) {
    return true;
  }

  if (min > root.val || max < root.val) {
    return false;
  }

  return isBst2(root.left, min, root.val) && isBst2(root.right, root.val, max);
}

// Traverse
function isBst3(root, lastNode) {
  if (lastNode === undefined) {
    lastNode = Number.NEGATIVE_INFINITY;
  }

  if (root === null) {
    return true;
  }

  if (!isBst3(root.left, lastNode)) {
    return false;
  }

  if (root.val < lastNode) {
    return false;
  }

  return isBst3(root.right, root.val);
}

function test() {
  if (isBst(bst) !== false && isBst(bt) === false &&
      isBst2(bst) === true && isBst2(bt) === false &&
      isBst3(bst) === true && isBst3(bt) === false) {
    console.log('success');
  }
}

test(); // Prints success
```
