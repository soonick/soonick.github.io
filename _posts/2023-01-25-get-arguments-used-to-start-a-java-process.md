---
title: Get arguments used to start a java process
author: adrian.ancona
layout: post
date: 2023-01-25
permalink: /2023/01/get-arguments-used-to-start-a-java-process
tags:
  - debugging
  - java
  - linux
---

There are times that we want to figure out what command line options where used to start a java process. There are a few ways we can do this. The examples below assume `PID` is set to the process id we want to inspect:

## ps

```bash
ps -f $PID

UID          PID    PPID  C STIME TTY      STAT   TIME CMD
adrian    316721  313854  0 16:15 pts/6    Sl+    0:00 /home/adrian/.cache/bazel/_bazel_adrian/28381a26654a75034a8803698f5ef496/execroot/__main__/bazel-out/k8-fastbuild/bin/main.runfiles/local_jdk/bin/java -classpath main.jar -Xdebug example.Main
```

## Using jps

`jps` doesn't allow us to list a single process id, but we can see the command line arguments for all java processes:

<!--more-->

```bash
jps -lvm
```

## Using jcmd

`jcmd` is the recommended way to inspect java processes. If we want to get information about the command line that was used to start a process we can use:

```bash
jcmd $PID VM.command_line

316721:
VM Arguments:
jvm_args: -Xdebug
java_command: example.Main
java_class_path (initial): main.jar
Launcher Type: SUN_STANDARD
```

There are some jvm options that are set by default without the need for a command line argument. We can use `jcmd` to inspect those too:

```bash
jcmd $PID VM.flags
jcmd $PID VM.system_properties
```
