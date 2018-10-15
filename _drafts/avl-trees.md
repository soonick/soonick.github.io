AVL trees (named after their inventors, Adelson-Velskii and Landis) were the first kind of self-balancing tree to be invented, so their implementation is somewhat simple compared to newer self-balancing trees.

This type of tree allows you to perform insertions, deletions and searches in O(log n). This tree keeps track of the heights of all the nodes. Every time one node is inserted, its height is compared with all the other leafs. If the height differs by more than one, the tree needs to be balanced.

<strong>Search</strong>

An AVL tree is a binary search tree (BST). A binary search tree is a binary tree where the nodes are ordered following these characteristics:

- The left subtree of a node contains only nodes with keys less than the node's key.
- The right subtree of a node contains only nodes with keys greater than the node's key.
- The left and right subtree each must also be a binary search tree.
- There must be no duplicate nodes.
- A unique path exists from the root to every other node.

Searching an AVL tree works the same way as searching any other binary search tree:
- Grab the root node and check the value
- If that's the value you are looking for then you already found it
- If the value you are looking for is greater then do a binary search on the right node
- If the value you are looking for is lower then do a binary search on the left node
- If at any time you find a null node then the value was not found

[cc lang="js"]
function search(val, root) {
  // If the val is in the current root then return it
  if (root.val === val) {
    return root;
  }

  if (val > root.val) {
    // If the value we are searching for is greater then
    // we keep searching at the right
    if (root.right) {
      return this.search(val, root.right);
    }
  } else {
    // If the value we are searching for is lower then
    // we keep searching at the left
    if (root.left) {
      return this.search(val, root.left);
    }
  }

  // If there was no root.left or root.right then
  // nothing will be returned
}
[/cc]

<strong>Balancing</strong>

Before jumping into insertion and deletion we need to explore balancing the tree. If at any moment the left node height and the right node height difference is greater than one then we need to rebalance. Let's look at an example:

[cc]
Start with:

    5         | Height of 5 is 2
  /   \       | Height of 4 is 1
4       6     | Height of 6 is 1
              | Difference between heights of children of 5 is 0
Insert 3:

     5         | Height of 5 is 3
   /   \       | Height of 4 is 2
  4     6      | Height of 6 is 1
 /             | Height of 3 is 1
3              | Difference between heights of children of 5 is 1


Insert 2:

       5         | Height of 5 is 4
     /   \       | Height of 4 is 3
    4     6      | Height of 6 is 1
   /             | Height of 3 is 2
  3              | Height of 2 is 1
 /               | Difference between height of children of 5 is 2,
2                |   so we need to rebalance

After rebalancing:

    4
   /  \
  3    5
 /      \
2        6
[/cc]

Now that we roughly know when to balance a tree, we need to look at how to do it.

When a tree becomes unbalanced, it has to be balanced by performing what is called a rotation. There are four different rotations that we can use to balance a tree. I'll use examples with only three nodes for simplicity, but the examples can be generalized. More specifically, once you find the node where the rotation needs to be made, you can make the rotation and disregard the sub-trees of the nodes below.

<strong>LL - Left-Left</strong>

An LL rotation is necessary when we have a tree that is too heave on the right:

[cc]
    4
      \
       5
        \
         6
[/cc]

For the example above, we can imagine that we started by inserting 4, then 5 and finally 6. After the rotation we end with this:

[cc]
    5
  /   \
4       6
[/cc]

The steps we followed to get there are:

<ul>
  <li>Whatever is above 4 needs to point to 5 now</li>
  <li>4 becomes 5's left child</li>
  <li>Whatever was 5's left child, becomes, 4's right child</li>
</ul>

Those are all the changes needed. Everything else stays the same. Let's add some markers to make this clearer:

[cc]
This:

    P
    |
    4
      \
       5
      /  \
     L     6

Becomes this:
    P
    |
    5
  /   \
4       6
 \
  L
[/cc]

<strong>RR - Right-Right</strong>

This is a mirror of LL:

[cc]
This:

    P
    |
    6
   /
  5
 / \
4   R

Becomes this:
    P
    |
    5
  /   \
4       6
       /
      R
[/cc]

The steps we followed are:

<ul>
  <li>Whatever is above 6 needs to point to 5 now</li>
  <li>6 becomes 5's right child</li>
  <li>Whatever was 5's right child, becomes, 6's left child</li>
</ul>

<strong>LR - Left-Right</strong>

This is where things become a little more interesting. In some situations a single rotation is not enough:

[cc]
    4
      \
       6
      /
     5
[/cc]

We could try an LL, but that doesn't really solve anything:

[cc]
    6
   /
  4
   \
    5
[/cc]

The way we do this is by doing a right on the right sub-tree:

[cc]
This is were we started:

    4
      \
       6
      /
     5

This is the right sub-tree of 4:

  6
 /
5

After right rotating this tree we get:

5
 \
  6

And the whole thing looks like this:

4
  \
   5
    \
     6

From here we can do our left rotation and we'll have a balanced tree.
[/cc]

<strong>RL - Right-Left</strong>

This is a mirror or LR. The process looks something like this:

[cc]
This would be the starting point:

  6
 /
4
 \
  5

This is the left sub-tree of 6:

4
 \
  5

After left rotating this tree we get:

  5
 /
4

And the whole thing looks like this:

    6
   /
  5
 /
4
[/cc]

<strong>What to rotate?</strong>

Now that we know how to rotate, we still need to figure out when a rotation needs to be made, which rotation and what will be the root.

Before we can make these decisions we need to decide how to calculate the height of all the sub-trees whenever we need them. Calculating the heights of the sub-trees of the root node would require us to traverse the whole tree, which would be very inefficient. For this reason a better approach is to store and update the height of the trees every time it is needed. Lets start with a simple node that can store the height:

[cc]
function Node(val, left, right, height) {
  this.val = val;
  this.left = left;
  this.right = right;
  this.height = height;
};
[/cc]

Now, we need to decide when to update the height of a node:

[cc]
  5      -> Height = 2
 / \
4   6    -> Height = 1
[/cc]

If we insert a 7 here, we end with this:

[cc]
  5      -> Height = 2
 / \
4   6    -> Height = 1
     \
      7
[/cc]

Because we are inserting a child under a node that has a height of 0, that means that we changed its height to 1. But this could also (but not necessarily) have affected the height of the parents. The first problem we have is that after finding the where we want to insert 7, we want to be able to traverse the tree in reverse. For this, we need to modify our node to also have a link to the parent:

[cc]
function Node(val, parent, left, right, height) {
  this.parent = parent;
  this.val = val;
  this.left = left;
  this.right = right;
  this.height = height;
};
[/cc]

After we find that we are going to insert 7 as the right child of 6, we know that we are modifying the height of the right sub-tree of 6. It used to be 0 (no children) and it will become 1. Before we modify the height of 6, we need to verify the height of the left sub-tree. Only if the height of the left sub-tree is lower than the height of the modified sub-tree (we are inserting on the right sub-tree), we increase the height of 6. To put it more clearly:

Steps to insert 7:

<ul>
  <li>Search where 7 will be inserted (In this case, as the right child of 6)</li>
  <li>Create a new node (Node(7, parentNode, null, null, 1))</li>
  <li>Set 6's right node to the new node (parentNode.right = newNode)</li>
  <li>Go to new node's parent and check if the height of the other sub-tree is equal to the one of the modified subtree. If the heights are the same, we don't modify the height and we stop. If the height is different, we modify the height and continue recursively with 6's parent</li>
</ul>

<strong>Inserting</strong>

Let's try to put it in practice now. Inserting consists of searching where the element we want to insert should be, add the element and rebalance if necessary. Here is an example implementation:

[cc lang="js"]
function Node(val, parent, left, right, height) {
  this.parent = parent;
  this.val = val;
  this.left = left;
  this.right = right;
  this.height = height;
};

// Returns the root of the tree
function insert(val, root) {
  if (!root) {
    // Create the root
    return new Node(val, null, null, null, 1);
  } else {
    // Search for this value. If it is found
    // we don't need to do anything
    if (this.search(val, root)) {
      return root;
    }

      var newNode = new node(val, this.currenNode, 0);
      if (val > this.currentNode.val) {
        this.currentNode.right = newNode;
      } else {
        this.currentNode.left = newNode;
      }

      // Update heights of parents
      var currentNode = this.currentNode;
      while (currentNode) {
        currentNode.height++;
        currentNode = currentNode.dad;
      }

      // Balance
      currentNode = this.currentNode;
      while (currentNode) {
        var left = 0;
        var right = 0;
        if (currentNode.left) {
          left = currentNode.left.height;
        }
        if (currentNode.right) {
          right = currentNode.right.height;
        }

        var diff = left - right;
        if (diff < -1) {
          currentNode.right.dad = currentNode.dad;
          currentNode.dad = currentNode.right;
        }

        if (diff > 1) {
          currentNode.left.dad = currentNode.dad;
          currentNode.dad = currentNode.left;
        }
      }
  }
};
[/cc]

<strong>Deleting</strong>

Deleting a node is a little more tricky:
- Find the node you want to delete (Lets call it A)
- Find the largest element on it's left subtree (Lets call it B)
- Set the value of A to the value B
- Set the parent of B's right subtree to B's left subtree(If there is one)
- Rebalance if necessary

### here
