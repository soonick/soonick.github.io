---
title: Dependency injection with Dagger and Bazel
author: adrian.ancona
layout: post
date: 2021-09-08
permalink: /2021/09/dependency-injection-with-dagger-and-bazel
tags:
  - dependency_management
  - design_patterns
  - java
  - programming
---

## Dependency Injection

Dependency injection refers to a technique for building objects in an object oriented language. The idea of this technique is to abstract the process of creating an object from clients of these objects.

There are four roles in dependency injection:

- `Client` - This is an object that needs to use other objects to achieve a task
- `Interface` - The client doesn't know which objects it receives, it interacts with those objects only through a known `interface`
- `Service` - An object that implements an `interface`. This object is passed to the `client`
- `Injector` - An object that takes care of constructing objects and passing them to `clients`

<!--more-->

Let's look at some code that doesn't use dependency injection:

```java
public class Zoo {
  private Animal animal;

  Zoo() {
    animal = new Elephant();
  }

  public void talk() {
    animal.talk();
  }
}
```

We can see above that the `Zoo` class has a `talk` method that makes an `animal` talk. To construct the animal, we had to know about the `Elephant` class and its constructor.

If we use dependency injection, the code looks like this:

```java
public class Zoo {
  private Animal animal;

  Zoo(Animal animal) {
    this.animal = animal;
  }

  public void talk() {
    animal.talk();
  }
}
```

The only difference here is that instead of `Zoo` building the animal, it expects it as a parameter during construction. This means that the construction of the `Animal` needs to be done somewhere else (the injector). A simple example of an injector looks like this:

```java
public class Injector {
  public static void main(String[] args) {
    // Construct the animal
    Elephant elephant = new Elephant();

    // Inject the service into the client
    Zoo zoo = new Zoo(elephant);

    // We can now do whatever we want with the client
    zoo.talk();
  }
}
```

## Why Dagger?

Dagger is a dependency injection framework for Java and Kotlin. The main selling point of Dagger against other Dependency Injection (DI) frameworks is that it's easier to debug. When there is a problem with other dependency injection libraries, the error messages are usually very hard to understand, which makes it hard to fix them. The code generated by Dagger and the stack traces shown when something is not working are a lot easier to follow.

Dagger and other DI frameworks work with code generation. This means that Dagger needs to look into our code and generate some code based on it. Once this code is generated, the compiler runs as usual. This can be a little confusing at times because we can get compilation errors on files that we didn't write. When this happens it's very unlikely there is a bug in the generated code. Most likely it means that we are using Dagger incorrectly. The error message should help us figure out which dependency is having problems.

## Setup

I assume some basic knowledge of Bazel. You can look at my [introduction to Bazel](/2021/08/introduction-to-bazel) if you need a refresher.

As I mentioned before, Dagger needs to do some code generation. To achieve this, we need to do some wiring. Let's start by creating a folder and a `WORKSPACE` file:

```sh
mkdir dagger-example
cd dagger-example
touch WORKSPACE
```

Add this to the `WORKSPACE` file:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

RULES_JVM_EXTERNAL_TAG = "2.5"
RULES_JVM_EXTERNAL_SHA = "249e8129914be6d987ca57754516be35a14ea866c616041ff0cd32ea94d2f3a1"
http_archive(
    name = "rules_jvm_external",
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    sha256 = RULES_JVM_EXTERNAL_SHA,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)

load("@rules_jvm_external//:defs.bzl", "maven_install")

###########################################################################
Everything above this line is standard maven setup. If you are not familiar
with this, I recommend you look at my introduction to Bazel
###########################################################################

DAGGER_TAG = "2.28.1"
DAGGER_SHA = "9e69ab2f9a47e0f74e71fe49098bea908c528aa02fa0c5995334447b310d0cdd"
http_archive(
    name = "dagger",
    strip_prefix = "dagger-dagger-%s" % DAGGER_TAG,
    sha256 = DAGGER_SHA,
    urls = ["https://github.com/google/dagger/archive/dagger-%s.zip" % DAGGER_TAG],
)

load("@dagger//:workspace_defs.bzl", "DAGGER_ARTIFACTS", "DAGGER_REPOSITORIES")

maven_install(
  artifacts = DAGGER_ARTIFACTS,
  repositories = DAGGER_REPOSITORIES,
)
```

To install the Dagger repository rule, we use the same method we used for Maven.

`@dagger//:workspace_defs.bzl` defines a list of Maven artifacts that we need to install for Dagger to work. We install those using `maven_install`.

The next step is to use Dagger for a build. Let's create a `BUILD` file:

```sh
touch BUILD
```

And add this content:

```python
load("@dagger//:workspace_defs.bzl", "dagger_rules")

dagger_rules()

java_binary(
    name = "dagger_example",
    srcs = glob(["*.java"]),
    main_class = "example.Main",
    deps = [
      ":dagger",
    ],
)
```

In this file, we need to load and call `dagger_rules`. After that, we just need to add `:dagger` as a dependency of the targets that need it.

Now that everything is set up, we can start learning how to use Dagger.

## How to use it

Before we start writing code, let's start by picturing our graph of dependencies. In this simple example, we have this graph:

```
(Main) ---> (Zoo) ---> (Animal)
```

In other words: Our entry point, needs a `Zoo` and our `Zoo` needs an `Animal`.

In Dagger we create the root of our dependency graph by creating a `Component`. Our component is going to be a file named `MyZoo.java` with this content:

```java
package example;

import dagger.Component;

@Component(modules = {
  ZooModule.class,
})
interface MyZoo{
  Zoo zoo();
}
```

A few things to notice about this code:
- It defines an interface
- The name of the interface doesn't matter
- It declares a method that returns a `Zoo`, but the method doesn't have a body
- The interface is annotated with `@Component`
- The component annotation receives a list of `modules` (We'll cover `modules` soon)

This component triggers the generation of a class named `DaggerMyZoo`, that can be used to create `Zoo` objects. The implementation of our `zoo()` method is written by Dagger.

This is how our `Main.java` uses this component:

```java
package example;

public class Main{
  public static void main(String[] args) {
    Zoo zoo = DaggerMyZoo.create().zoo();
    zoo.talk();
  }
}
```

`DaggerMyZoo.create()` builds the Dagger component. Then we can call `zoo()` to get our `Zoo` object.

The code above is short, but it can be hard to understand if we are not familiar with Dagger. Hopefully after reading this article everything will be clear.

The obvious next question is: How is `Zoo` built if we haven't created an `Animal`? This is where `ZooModule.java` comes in:

```java
package example;

import dagger.Provides;
import dagger.Module;

@Module
interface ZooModule {
  @Provides
  public static Animal provideAnimal(Elephant elephant) {
    return elephant;
  }
}
```

A module needs to be annotated with `@Module`. The other important thing is the `provideAnimal` method. There are a few things going on there. First of all, the `@Provides` annotation is required so Dagger knows that this is a provider. This method returns an `Animal`, so it's a provider of `Animal`s. Whatever this method returns is going to be used when constructing an object that requires an `Animal`.

In our scenario, the `provideAnimal` method receives an `Elephant` and returns it. Where does this elephant come from? Dagger knows how to create objects of classes annotated with `@Inject`. Let's look at our `Elephant.java`:

```java
package example;

import javax.inject.Inject;

class Elephant implements Animal {
  @Inject
  Elephant() {}

  public void talk() {
    System.out.println("Hello, I'm an elephant");
  }
}
```

Most of this class is easy to understand. The important details are:
- `Elephant` is an `Animal`
- The constructor is annotated with `@Inject`

In this case, the constructor takes no arguments, so Dagger can simply instantiate it. If it needed any arguments, Dagger can inject those arguments as long as it has providers for all of them.

The `Animal` interface for this example is very simple:

```java
package example;

interface Animal {
  void talk();
}
```

Because we are also injecting `Zoo`, we need to annotate the constructor with `@Inject` too:

```java
package example;

import javax.inject.Inject;

public class Zoo {
  private Animal animal;

  @Inject
  Zoo(Animal animal) {
    this.animal = animal;
  }

  public void talk() {
    animal.talk();
  }
}
```

That's it!. It's a very simple example, but hopefully, it's complete enough that it provides the foundation to understand larger applications.

## Binds

The `Binds` annotation is used widely, so it's useful to explain it here. In the example above we used `@Provides` to create an `Animal`. We could have used `@Binds` and the code would look like this:

```java
package example;

import dagger.Binds;
import dagger.Module;

@Module
interface ZooModule {
  @Binds Animal bindAnimal(Elephant elephant);
}
```

Since the only thing we want is to return an `Elephant` any time an `Animal` is requested, Dagger can generate the body for us if we use `@Binds` instead of `@Provides`.

## Conclussion

Dependency injection can be a little hard to understand if we are not familiar with it. For this reason, it's very important to be familiar with the DI framework used in our codebase if we want to understand how objects are created.
