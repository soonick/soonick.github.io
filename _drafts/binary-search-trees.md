A Binary Search Tree (BST) is a binary tree where the nodes are ordered following these characteristics:

- The left subtree of a node contains only nodes with keys less than the node's key.
- The right subtree of a node contains only nodes with keys greater than the node's key.
- The left and right subtree each must also be a Binary Search Tree.
- There must be no duplicate nodes.
- A unique path exists from the root to every other node.

The possible operations on a Binary Search Tree are: Search, Insert and Delete. An update is just a delete followed by an insert.

## Search

Searching a Binary Search Tree follows these steps:

- Grab the root node and check the value
- If that's the value you are looking for, then we are done
- If the value you are looking for is greater, then do a search on the right node
- If the value you are looking for is lower, then do a search on the left node
- If at any time you find a null node, then the value was not found

+++++ Example

## Insert

Inserting in a Binary Search Tree is very similar to the search:

- Follow the same procedure as search
- If the value is found, then there is nothing to do
- If the value is not found, we are going to create a new node as a child of the last node in the search chain
- If the value to insert is higher than the last node, we'll insert a new node as a right child
- If the value to insert is lower than the last node, we'll insert a new node as a left child

+++++ Example

## Delete

Deleting is the most complicated to implement. It follows these steps:

- Find the node you want to delete (Let's call it A)
- If it's not found, there is nothing to do
- If A doesn't have any children, just delete it (Unlink it from the parent)
- If A has a single child (Let's call it B), link A's parent to B, instead of A. A will no longer be a part of the tree
- If A has two children, find the lowest element on it's right subtree. This can be done by going to A's right child (Let's call it B) and then going down to the left child, until there are no more left children (Let's call this last node on the left, C).
  - Set the value of A to the value C
  - Delete node C (C will be a leaf, or have only a right child, so one of the techniques from above can be used)

+++++ Example
