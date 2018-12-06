---
title: Binary Search Trees
date: 2018-12-05
author: adrian.ancona
layout: post
permalink: /2018/12/binary-search-trees/
tags:
  - programming
  - javascript
  - computer_science
  - algorithms
---

A Binary Search Tree (BST) is a binary tree where the nodes are ordered following these characteristics:

- The left subtree of a node contains only nodes with values lower than the node's value
- The right subtree of a node contains only nodes with values greater than the node's value
- The left and right subtree each must also be a Binary Search Tree
- There must be no duplicate values
- A unique path exists from the root to every other node

The possible operations on a Binary Search Tree are: Search, Insert and Delete. An update is just a delete followed by an insert.

Binary Search Trees are pretty easy to implement and let you insert, delete and search in O(n) in the worse case scenario. There are self-balancing Binary Search Trees, that are harder to implement but offer O(log n) performance. I'm not going to cover self-balancing trees in this post.

<!--more-->

## Search

Searching a Binary Search Tree follows these steps:

- Grab the root node and check the value
- If that's the value you are looking for, then we are done
- If the value you are looking for is greater, then do a search on the right node
- If the value you are looking for is lower, then do a search on the left node
- If at any time you find a null node, then the value is not in the tree

Consider a tree like this:

[<img src="/images/posts/bst-example.jpg" alt="BST example" width="300" />](/images/posts/bst-example.jpg)

If we search for value `18` on that tree, we will follow these steps:

- Start at the root
- `15` is not the value we are looking for,we move to the right child
- `19` is not the value we are looking for, we move to the left child
- `18` is the value we are looking for, we are done

[<img src="/images/posts/bst-search.jpg" alt="BST search" width="300" />](/images/posts/bst-search.jpg)

## Insert

Inserting in a Binary Search Tree is very similar to the search:

- Follow the same procedure as search
- If the value is found, then there is nothing to do
- If the value is not found, we are going to create a new node as a child of the last node in the search chain
- If the value to insert is higher than the last node, we'll insert a new node as a right child
- If the value to insert is lower than the last node, we'll insert a new node as a left child

The image above, illustrates the steps to insert a value in a binary tree:

[<img src="/images/posts/bst-insert.jpg" alt="BST search" width="600" />](/images/posts/bst-insert.jpg)

- A search for value `19` is done in the tree
- `16` is the last node in the search (Since `19` is greater, but there is no right child)
- We create a new node with value `19` and add it as right child of `16`

## Delete

Deleting is a little harder to implement. It follows these steps:

- Find the node you want to delete (Let's call it A)
- If it's not found, there is nothing to do
- If A doesn't have any children, just delete it (Unlink it from the parent)
- If A has a single child (Let's call it B), link A's parent to B, instead of A. A will no longer be a part of the tree
- If A has two children, find the lowest element on it's right subtree. This can be done by going to A's right child (Let's call it B) and then going down to the left child, until there are no more left children (Let's call this last node on the left, C).
  - Set the value of A to the value C
  - Delete node C (C will be a leaf, or have only a right child, so one of the techniques from above can be used)

### The simplest case would be deleting a leaf:

[<img src="/images/posts/bst-delete-simple.jpg" alt="BST delete simple" width="600" />](/images/posts/bst-delete-simple.jpg)

- Find node `19`
- Remove the node (Set `16`'s right child to null)

### A little more complicated would be to delete a node with a single child:

[<img src="/images/posts/bst-delete-one-child.jpg" alt="BST delete one child" width="600" />](/images/posts/bst-delete-one-child.jpg)

- Find node `10`
- Since `10` is the left child of `21`, make `7` its left child instead

[<img src="/images/posts/bst-delete-one-child-2.jpg" alt="BST delete one child" width="600"/>](/images/posts/bst-delete-one-child-2.jpg)

### The most complicated case is the one where the node we want to delete has two children:

- Find node `10`

[<img src="/images/posts/bst-delete-two-children.jpg" alt="BST delete two children" width="600" />](/images/posts/bst-delete-two-children.jpg)

- Go to the right child
- Go to the left until the last node is hit (`12`)

[<img src="/images/posts/bst-delete-two-children-2.jpg" alt="BST delete two children" width="600" />](/images/posts/bst-delete-two-children-2.jpg)

- Replace the value of `10` and `12` (`10` will end at the bottom)
- Delete the node that has `10` now (At this point it will have 0 or 1 children)

[<img src="/images/posts/bst-delete-two-children-3.jpg" alt="BST delete two children" width="600" />](/images/posts/bst-delete-two-children-3.jpg)

## The code

Now that we know the algorithms, we can write the code. This is how it would look in `JavasScript`:

```js
class Bst {
  // Create a node
  _createNode(val, parent = null) {
    return {
      val: val,
      parent: parent,
      left: null,
      right: null,
    }
  }

  // Search for a value in this tree. If not found, returns
  // the closest node (the node where the value would be
  // inserted)
  _findPosition(val) {
    let current = this._root;
    while (true) {
      if (current.val === val) {
        return current;
      }

      if (val > current.val && current.right) {
        // The value we are searching for is greater.
        // Continue on the right subtree
        current = current.right;
      } else if (val < current.val && current.left) {
        // The value we are searching for is lower.
        // Continue on the left subtree
        current = current.left;
      } else {
        // No more tree to traverse
        return current;
      }
    }
  }

  // Deletes the given node. The node must have at most
  // one child
  _deleteSimple(node) {
    if (!node.left && !node.right) {
      // No children, simple delete
      if (!node.parent) {
        this._root = null;
      } else if (node.parent.right == node) {
        node.parent.right = null;
      } else {
        node.parent.left = null;
      }
    } else {
      // Single child, link the child to the parent
      if (!node.parent) {
        if (node.left) {
          this._root = node.left;
          node.left.parent = node.parent;
        } else {
          this._root = node.right;
          node.right.parent = node.parent;
        }
      } else if (node.parent.right == node) {
        if (node.left) {
          node.left.parent = node.parent;
          node.parent.right = node.left;
        } else {
          node.right.parent = node.parent;
          node.parent.right = node.right;
        }
      } else {
        if (node.left) {
          node.left.parent = node.parent;
          node.parent.left = node.left;
        } else {
          node.right.parent = node.parent;
          node.parent.left = node.right;
        }
      }
    }
  }

  // Search for a value in this tree
  search(val) {
    const found = this._findPosition(val);
    if (found && found.val === val) {
      return found;
    }
  }

  // insert a value
  insert(val) {
    // The case where this is the first value
    if (!this._root) {
      this._root = this._createNode(val);
      return;
    }

    // Search for the value. If it is found we don't need
    // to do anything
    let position = this._findPosition(val);
    if (position.val === val) {
      return;
    }

    // Insert the new value in the tree
    if (position.val > val) {
      position.left = this._createNode(val, position);
    } else {
      position.right = this._createNode(val, position);
    }
  }

  // Delete a value from the tree
  delete(val) {
    // Search for the value. If it is not found we don't
    // need to do anything
    let node = this.search(val);
    if (!node) {
      return;
    }

    if (node.left && node.right) {
      // Node has two children
      let lowestRightNode = node.right;
      while (lowestRightNode.left) {
        lowestRightNode = lowestRightNode.left;
      }

      let tempVal = lowestRightNode.val;
      lowestRightNode.val = node.val;
      node.val = tempVal;
      this._deleteSimple(lowestRightNode);
    } else {
      this._deleteSimple(node);
    }
  }
}

// Example of how to use it
let bst = new Bst();

bst.insert(4);
bst.insert(2);
bst.insert(3);
bst.search(3);
bst.delete(4);

console.log(bst._root);
```
