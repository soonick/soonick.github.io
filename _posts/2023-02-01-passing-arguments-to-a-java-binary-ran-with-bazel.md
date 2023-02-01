---
title: Passing Arguments To a Java Binary Ran With Bazel
author: adrian.ancona
layout: post
date: 2023-02-01
permalink: /2023/02/passing-arguments-to-a-java-binary-ran-with-bazel
tags:
  - debugging
  - java
  - linux
---

When we create a java binary with bazel, we can run it using a command like this:

```bash
bazel run :main
```

Sometimes an application requires very specific JVM flags to run correctly (For example: `-Xmx:512m`). These can be set like this:

```bash
bazel run :main --jvmopt="-Xmx:512m" 
```

If we need to set more than one flag, we use this syntax:

```bash
bazel run :main --jvmopt="-Xmx:512m" --jvmopt="-Xms:256m"
```
