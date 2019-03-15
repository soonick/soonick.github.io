---
title: Passing functions as arguments in C++
author: adrian.ancona
layout: post
date: 2019-05-15
permalink: /2019/05/passing-functions-as-arguments-in-cpp/
tags:
  - c++
  - programming
---

## Using functions that take functions

There are times, when it is convenient to have a function receive a function as an argument. This technique can be seen in the standard C++ library. As an example, `std::transform` can be used to create a series of values based on other values:

```cpp
#include <vector>
#include <algorithm>
#include <iostream>

int makeNumbersBig(int small) {
  return small * 10;
}

int main() {
  std::vector<int> numbers{1, 2, 3}; // numbers has 3 values: 1, 2, 3
  std::vector<int> bigNumbers(3); // bigNumbers has 3 values, default
                                  // initialized: 0, 0, 0

  // Starting at numbers.begin() and until numbers.end(), execute
  // makeNumbersBig and store the result in bigNumbers
  std::transform(
    numbers.begin(),
    numbers.end(),
    bigNumbers.begin(),
    makeNumbersBig
  );

  // Print the values of bigNumbers
  for (const auto big : bigNumbers) {
    std::cout << big << std::endl;
  }
}
```

<!--more-->

The function loops through `numbers`, executing the given function and putting the results in `bigNumbers`. At the end, it prints:

```
10
20
30
```

The same program, can be written using a lambda:

```cpp
#include <vector>
#include <algorithm>
#include <iostream>

int main() {
  std::vector<int> numbers{1, 2, 3}; // numbers has 3 values: 1, 2, 3
  std::vector<int> bigNumbers(3); // bigNumbers has 3 values, default
                                  // initialized: 0, 0, 0

  std::transform(
    numbers.begin(),
    numbers.end(),
    bigNumbers.begin(),
    [](int small) {
      return small * 10;
    }
  );

  // Print the values of bigNumbers
  for (const auto big : bigNumbers) {
    std::cout << big << std::endl;
  }
}
```

## Writing functions that take functions

So far, we know how to pass a function to another function as an argument, but how do we write a function that does this? Let's try to implement the `transform` function:

```cpp
#include <vector>
#include <algorithm>
#include <iostream>

void transform(std::vector<int>::iterator beginIt,
    std::vector<int>::iterator endIt,
    std::vector<int>::iterator destinationBeginIt,
    int func (int)) {
  while (beginIt != endIt) {
    *destinationBeginIt = func(*beginIt);
    beginIt++;
    destinationBeginIt++;
  }
}

int main() {
  std::vector<int> numbers{1, 2, 3}; // numbers has 3 values: 1, 2, 3
  std::vector<int> bigNumbers(3); // bigNumbers has 3 values, default
                                  // initialized: 0, 0, 0

  transform(
    numbers.begin(),
    numbers.end(),
    bigNumbers.begin(),
    [](int small) {
      return small * 10;
    }
  );

  // Print the values of bigNumbers
  for (const auto big : bigNumbers) {
    std::cout << big << std::endl;
  }
}
```

This code does exactly the same as the previous ones, the difference is that, we wrote it ourselfs!

The `transform` function takes iterators of a vector of integers (`std::vector<int>::iterator`) as arguments. The interesting part is the last argument:

```cpp
int func (int)
```

This is actually just a function signature, so there is nothing really new here. One important thing to know is that functions are always passed by reference (or pointer), it doesn't matter if it's not specified in the signature. These are exactly the same:

```cpp
int func (int)
int (*func) (int)
int (&func) (int)
```

Notice that for the cases were we explicitly use `*` or `&`, we need the use parentheses.

## Writing functions that take complicated functions

Writing a function signature as an argument to another function, can make  the code hard to read. For that reason, it is common to use `typedef`. This is the signature for `typedef`:

```cpp
typedef <type declaration> <new name>
```

An example could be:

```cpp
typedef unsigned long long my_long;
```

Now, `my_long` can be used to declare a variable of type `unsigned long long`:

```cpp
my_long number;
```

With this information, we can create a type based on a function, to make functions more readable. `transform` can be rewriten like:

```cpp
typedef int myFuncType (int);

void transform(std::vector<int>::iterator beginIt,
    std::vector<int>::iterator endIt,
    std::vector<int>::iterator destinationBeginIt,
    myFuncType func);
```

Another function that can help make our definitions simpler is `typeof`. Imagine we have a function that accepts another function with a complicated signature:

```cpp
void doSomething(
    std::vector<std::unordered_map<int, std::string>> someFunction(std::vector<int>, std::string)) {
  // Code here
}
```

This function definition becomes very hard to read because the function it accepts as an argument is very long. In some cases, we already have a function with that signature that we know we want to use. In those cases, we can do:

```cpp
std::vector<std::unordered_map<int, std::string>> someFunction(std::vector<int>, std::string) {
  // Some code here
}

void doSomething(typeof someFunction) {
  // Code here
}
```

The signature for `doSomething` becomes a lot simpler by using `typeof`;
