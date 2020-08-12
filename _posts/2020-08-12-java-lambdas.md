---
title: Java Lambdas
author: adrian.ancona
layout: post
date: 2020-08-12
permalink: /2020/08/java-streams/
tags:
  - design_patterns
  - java
  - programming
---

Sometimes when writing software, it is useful to pass a function as an argument to another function. A common example for this is a generic filter function. In pseudo code, it would look something like this:

```js
filter(persons, filter_function) {
  filtered = [];
  for (person in persons) {
    if (filter_function(person)) {
      filtered.push(person);
    }
  }

  return filtered;
}
```

<!--more-->

In the example above, we provide a list of `persons` and a `filter_function`. The `filter_function` gets applied on each `person` and if it returns false, the person is discarded.

## Interfaces

We can implement something similar to the example above using interfaces. We define an interface with a single method and pass an object implementing this interface to a function. Let's see how it looks:

```java
import java.util.ArrayList;

public class Interface {
  // Interface of the filter
  private interface Filter<T> {
    public boolean filter(T t);
  }

  // Function that filters numbers based on a given filterFunction
  public static ArrayList<Integer> filter(int[] numbers, Filter<Integer> filterFunction) {
    ArrayList<Integer> filtered = new ArrayList<Integer>();
    for (int i = 0; i < numbers.length; i++) {
      if (filterFunction.filter(numbers[i])) {
        filtered.add(numbers[i]);
      }
    }

    return filtered;
  }

  public static void main(String[] args) {
    // Implement the interface
    Filter<Integer> customFilter = new Filter<Integer>() {
      public boolean filter(Integer number) {
        return number < 10;
      }
    };

    int[] numbers = {1, 4, 11};

    // Use our custom filter
    ArrayList<Integer> result = filter(numbers, customFilter);

    // Print result
    for (int i = 0; i < result.size(); i++) {
      System.out.println(result.get(i));
    }
  }
}
```

## Lambdas

A lambda is just a shorter way to define our single method interface. The example would look like this using a lambda:

```java
import java.util.ArrayList;

public class Interface {
  private interface Filter<T> {
    public boolean filter(T t);
  }

  public static ArrayList<Integer> filter(int[] numbers, Filter<Integer> filterFunction) {
    ArrayList<Integer> filtered = new ArrayList<Integer>();
    for (int i = 0; i < numbers.length; i++) {
      if (filterFunction.filter(numbers[i])) {
        filtered.add(numbers[i]);
      }
    }

    return filtered;
  }

  public static void main(String[] args) {
    // This is the only part that changed
    Filter<Integer> customFilter = (Integer number) -> {
      return number < 10;
    };

    int[] numbers = {1, 4, 11};

    ArrayList<Integer> result = filter(numbers, customFilter);

    for (int i = 0; i < result.size(); i++) {
      System.out.println(result.get(i));
    }
  }
}
```

The compiler can infer the types of the arguments, so we can further simplify the lambda:

```java
Filter<Integer> customFilter = (number) -> {
  return number < 10;
};
```

For single statement lambdas we can omit the braces and the return keyword:

```java
Filter<Integer> customFilter = (number) -> number < 10;
```

For single argument lambdas we can also omit the parentheses:

```java
Filter<Integer> customFilter = number -> number < 10;
```

## Conclusion

This article shows the syntax of lambda expressions and how they can be used to pass a function as an argument.
