---
id: 2193
title: House painting problem
date: 2017-02-08T10:56:46+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2193
permalink: /2017/02/house-painting-problem/
tags:
  - computer_science
  - algorithms
  - javascript
  - programming
---
## The question

There are a row of houses, each house can be painted with one of three colors red, blue or green. The cost of painting each house with a certain color is different. You have to paint all the houses such that no two adjacent houses have the same color. You have to paint the houses with minimum cost. How would you do it? 

Note: Painting house-1 with red costs different from painting house-2 with red. The costs are different for each house and each color.

<!--more-->

## The solution

There is a trivial solution to this problem, which would be to calculate all the possible combinations and then choose the one with the lowest cost. If we had only two houses we could calculate: red-green, red-blue, green-red, green-blue, blue-red, blue-green; a total of 6 combinations. Things start getting more complicated pretty fast. With three houses:

```
red-green-red
red-green-blue
red-blue-red
red-blue-green
green-red-green
green-red-blue
green-blue-green
green-blue-red
blue-red-blue
blue-red-green
blue-green-blue
blue-green-red
```

This time we have 12 combinations, which is twice as much as with 2 houses. If we had 4 houses we would have 24 combinations. It could seem like the complexity is `N*2` where `N` is the number of houses, but it only increases by 2 because we have 3 colors. If we added one more color, we would have the following combinations for 2 houses:

```
red-green
red-blue
red-yellow
green-red
green-blue
green-yellow
blue-red
blue-green
blue-yellow
yellow-red
yellow-green
yellow-blue
```

This time we have 12 combinations for 2 houses with 4 different colors. If we added one more house we would end up with 36 combinations.

In both cases, adding one house results on: (new number of combinations) = (previous number of combinations) \* (M &#8211; 1), where M is the number of colors. Taking into account that for the scenario of one house we can actually use M instead of M-1, we can model our complexity as: M \* ((M-1)^(N-1)). In a simplified O notation you would probably say it&#8217;s O(M^N)

This complexity is pretty bad and can in most cases be optimized by using other techniques. In general for these kind of problems we need to find patterns and invariants. We have already found the number of possible combinations, which is a good start but now we need to find ways to reduce the number of combinations.

A technique I like to follow when facing these problems is to start very small. Using a single color is not possible because you can&#8217;t have two houses painted the same color together. Using two colors is also not very useful because there are only two possibilities no matter how many houses there are. If the colors are reg and green, you either start with red or start with green and then interpolate the colors until there are no more houses.

The problem starts taking form when there are 3 colors, so lets start from there. If we had 1 house, we just pick the cheapest color. If we had 2 houses, it is also pretty simple, we check all the combinations and pick the cheapest one. Adding one more house starts making things more interesting. Here is where we want to start looking for shortcuts. We already know that calculating all combinations and taking the cheapest would work, but we are trying to find a better way.

There is actually a little invariant hidden in this problem that can be observed when dealing with 3 houses. We can paint the last house one of 3 colors red, green or blue. This is information we can&#8217;t change. The way we decide which color to paint it is based on information about all the previous houses. Another invariant is that if we painted the last house red, we can only paint the previous house green or blue. But how do we choose which color is best?

We decided we want the last house to be red, this means the second house can only be green or blue. Lets assume that we calculated all combinations for 2 houses and found that if you had to choose between painting the second house green or blue, the cheapest combination ends with a green house. At this point, you don&#8217;t care about the combination x-blue-red because you already know that x-green-red is cheaper. You can follow the same process assuming you decide to paint the third house green or blue.

Then you end with the cheapest price for painting the last house on each of the three colors. If you add one more house you just need these 3 values to figure out which color to paint it. You can keep adding houses and the process will remain the same.

Using this technique we have reduced the complexity to N * M. For each of the houses you have to calculate the price for each of the colors.

Now that we know the algorithm we can write the code for it:

```js
// An array containing the costs of painting each
// house in a given color
var costs = [
  {
    r: 4,
    g: 20,
    b: 3
  },
  {
    r: 10,
    g: 4,
    b: 6
  },
  {
    r: 33,
    g: 10,
    b: 7
  },
  {
    r: 90,
    g: 85,
    b: 89
  },
  {
    r: 1,
    g: 9,
    b: 1
  }
];
var n = costs.length; // number of houses
var c = 3; // number of colors

function solve() {
  var lowest = [];
  lowest.push({
    r: costs[0].r,
    g: costs[0].g,
    b: costs[0].b
  });

  for (var h = 1; h < n; h++) {
    var hLow = {};

    hLow.r = costs[h].r + Math.min(lowest[h - 1].g, lowest[h - 1].b);
    hLow.g = costs[h].g + Math.min(lowest[h - 1].r, lowest[h - 1].b);
    hLow.b = costs[h].b + Math.min(lowest[h - 1].r, lowest[h - 1].g);

    lowest.push(hLow);
  }

  return Math.min(lowest[n - 1].r, lowest[n - 1].g, lowest[n -1].b);
}

function test() {
  if (solve() === 100) {
    console.log('success');
  }
}

test();
```
