---
title: Profiling Java Applications
author: adrian.ancona
layout: post
# date: 2023-02-08
# permalink: /2023/02/profiling-java-applications
tags:
  - debugging
  - java
  - programming
---

In this article we are going to learn how to profile java applications using [jcmd](https://docs.oracle.com/javase/8/docs/technotes/guides/troubleshoot/tooldescr006.html) and [jmc (JDK Mission Control)](https://www.oracle.com/java/technologies/jdk-mission-control.html)

## Installing the tools

The `jcmd` cli is included in the JDK so there is nothing special we need to do to install it.

To install the `jmc` we need to first download it from the [jmc downloads page](https://www.oracle.com/java/technologies/javase/products-jmc8-downloads.html), then we just need to follow the instructions in [their installation guide](https://www.oracle.com/java/technologies/javase/jmc8-install.html).

## Java Flight Recorder

Java Flight Recorder (JRF) is a tool for collecting profiling data about a JVM application. It claims to have a low overhead (1% or less) so it can be used to profile applications running in production.

Java Flight Recorder contains a lot of different types of information that can be used when debugging an application. We'll explore some of them here.

## Creating a Java Flight Recorder Dump

It's very easy to record a JFR dump using `jcmd`. We just need to [know the id of the process we want to analyze](/2023/01/getting-pid-for-java-process). Once we have the process id, we can use this command:

```bash
jcmd $PID JFR.start duration=300s filename=/tmp/recording.jfr
```

The command will start a new recording that will last 5 minutes (300 seconds). The result of the recording will be dumped to `/tmp/recording.jfr`. It's important to wait for the recording to finish, otherwise the file will not be correct. I usually use the sleep command to know when the recording is ready:

```bash
sleep 300 && echo "Recording is ready"
```

## Analyzing the recording

Now that we have a `.jfr` file, we can open it with JDK Mission Control:

[<img src="/images/posts/jmc-open-file.png" alt="Open file form JDK Mission Control" />](/images/posts/jmc-open-file.png)

There are a lot of things we can discover looking at JDK Mission Control. Let's start with a quick tour and then we'll dive deeper into some of them.

### Threads

In the threads tab we can see the state of all the threads used for running the application. This can be used to detect things like deadlocks.

[<img src="/images/posts/jmc-threads-tab.png" alt="JDK Mission Control - Threads Tab" />](/images/posts/jmc-threads-tab.png)

Notice how the output includes things like `VM Thread` and `JFR Recorder Thread`. Even when those threads were not created by the application, there are running in the same JVM process so they are listed there.

### Memory

The memory tab features a list of objects and the amount of memory they are consuming. We can also find information like heap usage over time or when garbage collection was ran.

[<img src="/images/posts/jmc-memory-tab.png" alt="JDK Mission Control - Memory Tab" />](/images/posts/jmc-memory-tab.png)

### Method profiling

This tab allows us to find the methods that are using using the most CPU time and stack traces for those methods.

[<img src="/images/posts/jmc-method-profiling-tab.png" alt="JDK Mission Control - Method Profiling Tab" />](/images/posts/jmc-method-profiling-tab.png)

### Exceptions

Here we can find which exceptions are being thrown by the application:

[<img src="/images/posts/jmc-exceptions-tab.png" alt="JDK Mission Control - Exceptions Tab" />](/images/posts/jmc-exceptions-tab.png)

### Garbage collection

The memory tab gives us some information about garbage collection. In this tab we can find more details, like: what kind of garbage collection was running and how long it took.

[<img src="/images/posts/jmc-garbage-collection-tab.png" alt="JDK Mission Control - Garbage Collection" />](/images/posts/jmc-garbage-collection-tab.png)
