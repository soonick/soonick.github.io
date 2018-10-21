---
id: 2211
title: Unique paths
date: 2015-03-04T04:10:07+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2211
permalink: /2015/03/unique-paths/
tags:
  - computer_science
  - algorithms
  - javascript
  - programming
---
A robot is located at the top-left corner of a m x n grid (marked ‘S’ in the diagram below). The robot can only move either down or right at any point in time. The robot is trying to reach the bottom-right corner of the grid (marked ‘F’ in the diagram below). How many possible unique paths are there?

```
+---+---+---+---+---+---+---+
| S |   |   |   |   |   |   |
+---+---+---+---+---+---+---+
|   |   |   |   |   |   |   |
+---+---+---+---+---+---+---+
|   |   |   |   |   |   | F |
+---+---+---+---+---+---+---+
```

The first idea that came to my mind after seeing this problem was to find all the combinations for two movements down and six movements to the right(>>>>>>vv). I couldn&#8217;t remember of the top of my head the formula but after a little playing with pen and paper it came back to me. The formula is:

<!--more-->

```
  T!
-----
 D!R!
```

Where T is total number of elements you are combining(8 in the example), D is the number of times you can move down(2 in the example) and R is the number of times you can move right(6 in the example). The code to calculate this would be:

```js
function paths(r, c) {
    // Since we are already in the first row and first column
    // there is one movement we wont be doing
    r--;
    c--;

    var total = r + c;
    var tFactorial = 1;
    var rFactorial;
    var cFactorial;
    for (var i = 1; i <= total; i++) {
        tFactorial *= i;
        if (i === r) {
            rFactorial = tFactorial;
        }

        if (i === c) {
            cFactorial = tFactorial;
        }
    }

    return tFactorial / (rFactorial * cFactorial);
}
```

Another way to do this is using recursion to check all the possible paths. The reasoning behind it is:
  
If you are in a extreme column(all the way to the right) or an extreme row(all the way to the bottom), there is only one path to the end (either moving to the right or moving to the bottom)
  
If you are not in a extreme then you have a number of paths equal to the addition of the paths you can take from the position at your right and the position below you:

```js
function paths(r, c) {
    // Make rows and columns 0 based
    r--;
    c--;

    function doIt(x, y) {
        // We are in a extreme column or in a
        // extreme row. There is only one more
        // way to get to the end
        if (x === c || y === r) {
            return 1;
        }

        // We are not in a extreme, so add the
        // paths for both right and left
        return doIt(x + 1, y) + doIt(x, y + 1);
    }

    return doIt(0, 0);
}
```

This will cause some duplicate calculations. We can use memoization to avoid them:

```js
function paths(r, c) {
    // Make rows and columns 0 based
    r--;
    c--;
    var cache = {};

    function doIt(x, y) {
        // We are in a extreme column or in a
        // extreme row. There is only one more
        // way to get to the end
        if (x === c || y === r) {
            return 1;
        }

        // We are not in a extreme, so add the
        // paths for both right and left
        if (!cache[(x + 1) + ',' + y]) {
            cache[(x + 1) + ',' + y] = doIt(x + 1, y);
        }
        if (!cache[x + ',' + (y + 1)]) {
            cache[x + ',' + (y + 1)] = doIt(x, y + 1);
        }

        return cache[(x + 1) + ',' + y] + cache[x + ',' + (y + 1)];
    }

    return doIt(0, 0);
}
```

We can also use a similar approach starting from the bottom right:

```js
function paths(r, c) {
    function doIt(x, y) {
        // We are in the top or in the left
        if (x === 0 || y === 0) {
            return 1;
        }

        return doIt(x - 1, y) + doIt(x, y - 1);
    }

    // Make rows and columns 0 based
    return doIt(r -1, c - 1);
}
```

With memoization:

```js
function paths(r, c) {
    var cache = {};

    function doIt(x, y) {
        // We are in the top or in the left
        if (x === 0 || y === 0) {
            return 1;
        }

        // Don't calculate values that have already
        // been calculated
        if (!cache[(x - 1) + '-' + y]) {
            cache[(x - 1) + '-' + y] = doIt(x - 1, y);
        }
        if (!cache[x + '-' + (y - 1)]) {
            cache[x + '-' + (y - 1)] = doIt(x, y - 1);
        }

        return cache[(x - 1) + '-' + y] + cache[x + '-' + (y - 1)];
    }

    // Make rows and columns 0 based
    return doIt(r -1, c - 1);
}
```

LeetCode shows a top-bottom approach a little different than mine. Instead of checking if you are in a extreme, they check if you have reached the bottom-right corner. It has the same result but it seems like it does some unnecessary calculations:

```js
function paths(r, c, m, n) {
  if (r == m && c == n) {
    return 1;
  }
  if (r > m || c > n) {
    return 0;
  }

  return paths(r+1, c, m, n) + paths(r, c+1, m, n);
```

With memoization:

```js
function paths(r, c) {
  var mat = []

  function backtrack(r, c, m, n) {
    if (r == m && c == n) {
      return 1;
    }
    if (r > m || c > n) {
      return 0;
    }

    if (!mat[r+1]) {
      mat[r+1] = [];
    }
    if (!mat[r]) {
      mat[r] = [];
    }

    if (mat[r+1][c] == undefined) {
      mat[r+1][c] = backtrack(r+1, c, m, n, mat);
    }
    if (mat[r][c+1] == undefined) {
      mat[r][c+1] = backtrack(r, c+1, m, n, mat);
    }

    return mat[r+1][c] + mat[r][c+1];
  }

  return backtrack(1, 1, r, c);
}
```

They also show an iterative bottom-up approach:

```js
function paths(m, n) {
  var mat = [];
  mat[m] = [];
  mat[m][n+1] = 1;

  for (r = m; r >= 1; r--) {
    if (!mat[r]) {
      mat[r] = [];
    }
    if (!mat[r+1]) {
      mat[r+1] = [];
    }

    for (c = n; c >= 1; c--) {
      mat[r][c] = (mat[r+1][c] || 0) + (mat[r][c+1] || 0);
    }
  }

  return mat[1][1];
}
```

Running [some performance tests](http://jsperf.com/unique-paths) I could see that the solution that uses combinations is by far the fastest. After that leet&#8217;s bottom-up approach is way faster than the best of my solutions. This really blew my mind because I thought my top-bottom approach would be a little better than leet&#8217;s, so I wanted to find out why.

After a little playing with the code I found the reason my implementation was so slow is because I was doing a lot of string operations for my hash keys. Once I changed to use an array instead of a hash table my implementation is a little faster than leet&#8217;s:

```js
function paths(r, c) {
    // Make rows and columns 0 based
    r--;
    c--;
    var cache = [];

    function doIt(x, y) {
        // We are in a extreme column or in a
        // extreme row. There is one one more
        // way to get to the end
        if (x === c || y === r) {
            return 1;
        }

        if (!cache[x]) {
            cache[x] = [];
        }
        if (!cache[x + 1]) {
            cache[x + 1] = [];
        }

        // We are not in a extreme, so add the
        // paths for both right and left
        if (!cache[x + 1][y]) {
            cache[x + 1][y] = doIt(x + 1, y);
        }
        if (!cache[x][y + 1]) {
            cache[x][y + 1] = doIt(x, y + 1);
        }

        return cache[x + 1][y] + cache[x][y + 1];
    }

    return doIt(0, 0);
}
```
