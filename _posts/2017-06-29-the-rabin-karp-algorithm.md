---
id: 4286
title: The Rabin-Karp algorithm
date: 2017-06-29T04:19:01+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4286
permalink: /2017/06/the-rabin-karp-algorithm/
categories:
  - Computer science
tags:
  - algorithms
  - javascript
  - programming
---
I was doing a little studying on algorithms when I stumbled into what looked to me as a pretty simple question: &#8220;Find the first occurrence of a string inside another string&#8221;. This can be simply achieved with two nested loops and a worst case scenario performance of O(nm) or O(n^2) if m&#8217;s size is relative to n.

Here is an implementation that uses two loops:

```js
function findString(s1, s2) {
  // We only need to loop until s2 doesn't fit anymore
  var loopLimit = s1.length - s2.length;
  for (var i = 0; i <= loopLimit; i++) {
    for (var j = 0; j < s2.length; j++) {
      // As soon as we find a mismatch we abort the loop
      if (s1[i + j] !== s2[j]) {
        break;
      }
    }

    // If j reached the size of s2, it means all letters
    // in s2 matched. We have succeeded!
    if (j === s2.length) {
      return true;
    }
  }

  return false;
}

findString('aaaaaaaaaa', 'aaaab'); // false
findString('aaaaaaaaab', 'aaaab'); // true
findString('aaaaaaaaab', 'ab'); // true
```

<!--more-->

For a lot of scenarios the algorithm above will perform pretty decently. It will abort as soon as it finds a mismatch. The examples I used are worse case scenarios to illustrate the worst case complexity.

The first and second example do exactly the same work, the only difference is that one returns false and the other returns true. For both cases n = 10 and m = 5. The outer loop executed n &#8211; m + 1 times and the inner loop executed m times each time:

```
(n - m + 1) * m = mn - m^2 + m

If we represent m in relation to n we have:

Multiply by 2 to make math easier
(n - n/2 + 1) * n/2 -> (2n - n + 2) * n
(2n - n + 2) * n = 2n^2 - n^2 + 2n = n^2 - 2n
Divide by two (Undo the multiplication we did before)
(n^2)/2 - n

Since n^2 is the largest magnitude this would be
represented as O(n^2)
```

## Rabin-Karp

There are a few algorithms that can do this search more efficiently and Rabin-Karp is one of them. Rabin-Karp algorithm is not the most efficient algorithm for searching a string inside another string, but it is the easiest to implement. It&#8217;s worse time complexity is interestingly also O(mn), but it is a lot harder to get this scenario.

This algorithm focuses on removing the inner loop from the example above. The way it removes this loop is by using a hash function instead (I&#8217;ll talk more about this function in a minute). It uses a sliding window of characters of m length and calculates the hashes for each window one by one. If the hash of that window matches the hash of the string we are looking for, then we have probably found a match (I say &#8220;probably&#8221; because hash functions can have collisions).

## Rolling hash

A hash algorithm will return an integer based on a string. To calculate the integer, the algorithm has to loop through all the characters and perform some calculations based on these (I don&#8217;t really understand what it does). It requires to read all the characters for this calculation. Because it has to go through all the characters in the string to compute the hash, it takes O(n) to compute the hash (Where n is the length of the string).

A rolling hash algorithm helps in reducing the time for generating a hash for a string because it derives it based on a previous hash.

## Rabin fingerprint

Rabin fingerprint is an implementation of a rolling hash algorithm. To see how it works lets look at an example:

```js
var s = 'abcd';
var windowSize = 3;
var primeNumber = 127;

// This function will calculate a hash for the
// first <size> number of characters in <s> using
// Rabin-fingerprint algorithm. It will use <prime>
// as the base
function calculateHash(s, size, prime) {
  var val = 0;

  // Each of the first three characters
  for (var i = 0, exponent = size - 1; i < size; i++, exponent--) {
    // This is the ascii value for that character
    // a = 97, b = 98, ...
    var ascii = s.charCodeAt(i);

    // Exponent starts at size - 1 and ends at 0
    val += ascii * Math.pow(prime, exponent);
  }

  return val;
}

// Since our characters are a(97), b(98) and c(99)
// and primeNumber is 127, the result is:
// (97 * (127^2)) + (98 * (127^1)) + (99 * (127^0))
// = 1577058
var firstHash = calculateHash(s, windowSize, primeNumber);

// To calculate a rollingHash we need the previous hash
// This hash has to be the hash for characters from
// start - 1 to end - 1.
function calculateRollingHash(previousHash, s, start, end, prime) {
  // Both start and end are inclusive. To calculate the
  // rolling hash of 'bcd' from the string 'abcd',
  // start = 1, end = 3
  var size = end - start + 1;

  // From the previous hash we need to remove the part
  // that represents the a -> (97 * (127^2)).
  // We also want to have (98 * (127^1)) + (99 * (127^0))
  // become (98 * (127^2)) + (99 * (127^1)) and finally add
  // the letter d -> (100 * (127^0))

  // Remove a
  var valueToRemove = s.charCodeAt(start - 1);
  var newHash = previousHash - (valueToRemove * Math.pow(prime, (size - 1)));

  // Convert (98 * (127^1)) + (99 * (127^0)) to
  // (98 * (127^2)) + (99 * (127^1))
  newHash *= prime;

  // Add d
  newHash += s.charCodeAt(end);

  return newHash;
}

// This results in
// (98 * (127^2)) + (99 * (127^1)) + (100 * (127^0))
// = 1593315, but calculated in constant time
calculateRollingHash(firstHash, s, 1, 3, primeNumber);
```

## Search string within string using Rabin-Karp

Now that we know how Rabin-Karp works and how to use a rolling hash algorithm, we can write an implementation:

```js
function findString(s1, s2) {
  var prime = 127;
  var rollingHash;
  var s2Hash = calculateHash(s2, s2.length, prime);
  var loopLimit = s1.length - s2.length;
  var mismatch = false;

  for (var i = 0; i <= loopLimit; i++) {
    if (!rollingHash) {
      rollingHash = calculateHash(s1, s2.length, prime);
    } else {
      rollingHash = calculateRollingHash(rollingHash, s1, i, i + s2.length - 1, prime);
    }

    if (rollingHash === s2Hash) {
      mismatch = false;
      for (var j = 0; j < s2.length; j++) {
        if (s1[i + j] !== s2[j]) {
          mismatch = true;
        }
      }

      if (!mismatch) {
        return true;
      }
    }
  }

  return false;
}

function calculateHash(s, size, prime) {
  var val = 0;
  for (var i = 0, exponent = size - 1; i < size; i++, exponent--) {
    var ascii = s.charCodeAt(i);
    val += ascii * Math.pow(prime, exponent);
  }

  return val;
}

function calculateRollingHash(previousHash, s, start, end, prime) {
  var size = end - start + 1;
  var valueToRemove = s.charCodeAt(start - 1);
  var newHash = previousHash - (valueToRemove * Math.pow(prime, (size - 1)));
  newHash *= prime;
  newHash += s.charCodeAt(end);

  return newHash;
}

findString('aaaaaaaaaa', 'aaaab'); // false
findString('aaaaaaaaab', 'aaaab'); // true
findString('aaaaaaaaab', 'ab'); // true
```

By using a rolling hash we avoid the internal loop in most iterations. The check in lines 15 to 27 is necessary because it is possible for our hashing algorithm to have crashes (although this should be very rare). Whenever we find a hash match, we verify that all the characters also match (most cases this should be true), in which case, we return true.

As I mentioned earlier, the worst case scenario for this algorithm is also O(mn), but for this to happen you would need to have hash crashes for each iteration, which is very unlikely to happen (unlikely enough that I&#8217;m unable to present an example where this occurs). In most cases this algorithm will take O(n).
