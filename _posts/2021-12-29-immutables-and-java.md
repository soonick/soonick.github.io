---
title: Immutables and Java
author: adrian.ancona
layout: post
date: 2021-12-29
permalink: /2021/12/immutables-and-java
tags:
  - design_patterns
  - java
  - programming
---

## What are immutables?

An immutable is a type that can't be modified after it has been created.

The most common way to define an object in Java is by instantiating a class; Once the class is instantiated, we can modify its properties directly or by calling methods that modify them. Let's look at an example of a mutable object:

```java
public class MyClass {
  public int value;
}
```

This is a very simple type that we can instantiate and modify:

```java
MyClass obj = new MyClass();
obj.value = 4;
```

Immutables differ from these types in that once instantiated, they can't be modified (Properties can't be changed and there are no methods to modify them).

<!--more-->

A built in example of an immutable type are strings:

```java
String msg = "I'm an immutable string";
```

Once created the string can't be modified. We can assign a different string to `msg`, but the original string can't be changed (i.e. we can't change characters in a string, like we do with char arrays).

## Why do we want immutables?

Immutables are an idea that comes from functional programming languages and is somewhat new to Java. It has seen increase adoption in the Java world mostly because it makes it simpler to write predictable programs.

Let's look at a way a program using mutable objects can be unpredictable:

```java
MyClass obj = new MyClass();
obj.value = 4;
doSomething(obj);
doSomethingElse(obj);
```

This might look like a very predictable piece of code, but if we ask what's the value of `obj.value` when `doSomethingElse` is called, we might realize, it's not that simple.

Since `obj` is mutable, the call to `doSomething` might have changed `obj.value` without us knowing, which makes the call to `doSomethingElse` unpredictable.

Another scenario where immutables are useful is in multi-threaded software. One of the most common issues in multi-threaded programing are data races. Using immutables makes it impossible for data races to occur because two threads can't modify the same data, beacause it can't be modifed at all.

## Why not make everything immutable?

In most useful programs things aren't static; They change over time. If we model a person's clothes, we might want to change the color of their clothes from one moment to the other. With mutable objects we might do something like this:

```java
Clothes clothes = new Clothes();
clothes.color = "blue";

// ... Program keeps doing stuff
clothes.color = "green";
```

If we use immutable objects, we have to do something like this:

```java
Clothes clothes = new Clothes("blue");

// ... Program keeps doing stuff
clothes = clothes.copy("green");
```

Since we can't modify the object, we create a copy with different values and assign that copy to the variable.

The problem with copying an object is that it's more resource consuming than just changing the value of a variable. This overhead might be negligible in many cases, but when working on systems where speed is important, it might be counter productive to use immutables.

## Immutables in Java

One way to make immutable objects in java is to use classes that have all their properties defined as private and have no methods that modify any of these properties after construction. For example:

```java
public class MyClass {
  private int intProperty;
  private String stringProperty;

  MyClass(int i, String s) {
    intProperty = i;
    stringProperty = s;
  }
}
```

Once we construct an object of type `MyClass`, it can't be modified.

One thing that we need to be careful with is when our objects contain properties that are themselves mutable. For example:

```java
public class MyClass {
  private int intProperty;
  private String stringProperty;
  private List<String> listProperty;

  MyClass(int i, String s, List<String> l) {
    intProperty = i;
    stringProperty = s;
    listProperty = l;
  }
}
```

This is not an immutable type because `listProperty` is mutable.

## Immutables library

The [Immutables](https://immutables.github.io/) library provides an annotation processor that makes it easy to create immutable objects.

To get started with it, let's first see how to install the processor in [Bazel](https://ncona.com/2021/08/introduction-to-bazel).

We will need this directory structure

```
.
├── BUILD
├── ExamplePackage.java
├── MyClass.java
└── WORKSPACE
```

In `WORKSPACE` we'll download the maven artifact for `Immutables`:

```python
load('@bazel_tools//tools/build_defs/repo:http.bzl', 'http_archive')

RULES_JVM_EXTERNAL_TAG = '4.1'

http_archive(
    name = 'rules_jvm_external',
    strip_prefix = 'rules_jvm_external-%s' % RULES_JVM_EXTERNAL_TAG,
    url = 'https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip' % RULES_JVM_EXTERNAL_TAG,
)

load('@rules_jvm_external//:defs.bzl', 'maven_install')

maven_install(
    artifacts = [
      'org.immutables:value:2.8.8'
    ],
    repositories = [
        'https://repo1.maven.org/maven2',
    ],
)
```

The `BUILD` file creates the `immutables_processor` and adds it as a dependency for our binary:

```python
load("@rules_java//java:defs.bzl", "java_library", "java_plugin")

java_binary(
    name = 'example_package',
    srcs = [
      'ExamplePackage.java',
      'MyClass.java'
    ],
    main_class = 'example.ExamplePackage',
    deps = [
      ':immutables_processor',
      '@maven//:org_immutables_value'
    ]
)

java_plugin(
    name = "immutables_processor",
    generates_api = True,
    processor_class = "org.immutables.processor.ProxyProcessor",
    deps = [
        "@maven//:org_immutables_value",
    ],
)
```

Using `Immutables` annotations we create `MyClass.java`:

```java
package example;

import org.immutables.value.Value;
import java.util.List;

@Value.Immutable
public interface MyClass {
  int intProperty();
  String stringProperty();
  List<String> listProperty();
}
```

The preprocessor will create a class named `ImmutableMyClass` that can then be used to build immutables;

```java
package example;

import java.util.Arrays;

public class ExamplePackage {
  public static void main(String args[]) {
    MyClass a = ImmutableMyClass.builder()
        .intProperty(45)
        .stringProperty("Hello")
        .listProperty(Arrays.asList("one", "two"))
        .build();
  }
}
```

Besides the concise syntax that `Immutables` offers, it also makes sure that our objects are truly immutable. For example, this code will throw a runtime exception:

```java
public class ExamplePackage {
  public static void main(String args[]) {
    MyClass a = ImmutableMyClass.builder()
        .intProperty(45)
        .stringProperty("Hello")
        .listProperty(Arrays.asList("one", "two"))
        .build();

    a.listProperty().add("three");
  }
}
```

The exception happens because the `List` used inside the immutable is wrapped as an UnmodifiableCollection, so the `add` method is disallowed.

```
Exception in thread "main" java.lang.UnsupportedOperationException
	at java.base/java.util.Collections$UnmodifiableCollection.add(Collections.java:1060)
	at example.ExamplePackage.main(ExamplePackage.java:13)
```

The [Immutables guide](https://immutables.github.io/immutable.html) provides many examples of the different features it provides, so it's worth exploring it to learn more.

## Conclusion

In this article we learned what are immutables, when they are good and how to use them.

The trend I have seen lately (And I think might be a good approach) is that everything that can be made immutable is made immutable to start with. If performance issues arise, the issue is investigated and a mutable type is used if necessary.
