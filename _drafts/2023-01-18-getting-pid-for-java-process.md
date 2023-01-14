---
title: Getting PID for Java Process
author: adrian.ancona
layout: post
date: 2023-01-18
permalink: /2023/01/getting-pid-for-java-process
tags:
  - debugging
  - java
  - linux
  - programming
---

We can use `ps` to get all the processes running in a host. The problem is that all java processes just say `java` by default. For example:

```bash
ps -e | grep java

 309158 ?        00:00:16 java
 309527 ?        00:00:05 java
 313028 pts/3    00:00:00 java
 313346 ?        00:00:03 java
```

We can use the `-f` modifier to do full-format listing, which will print all the command line arguments used to start the process:

```bash
ps -fe | grep java

adrian    309158   87625  0 15:03 ?        00:00:16 bazel(getting-pid-for-java-process) -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/adrian/.cache/bazel/_bazel_adrian/2cff94953bdedc4a1c6a41ce83e93da8 -Xverify:none -Djava.util.logging.config.file=/home/adrian/.cache/bazel/_bazel_adrian/2cff94953bdedc4a1c6a41ce83e93da8/javalog.properties -Dcom.google.devtools.build.lib.util.LogHandlerQuerier.class=com.google.devtools.build.lib.util.SimpleLogHandler$HandlerQuerier -XX:-MaxFDLimit -Djava.library.path=/usr/share/bazel/ -Dfile.encoding=ISO-8859-1 -jar /usr/share/bazel/A-server.jar --max_idle_secs=10800 --noshutdown_on_low_sys_mem --connect_timeout_secs=30 --output_user_root=/home/adrian/.cache/bazel/_bazel_adrian --install_base=/usr/share/bazel --install_md5=754af2f3778d588aa4604927527eee4e --output_base=/home/adrian/.cache/bazel/_bazel_adrian/2cff94953bdedc4a1c6a41ce83e93da8 --workspace_directory=/home/adrian/repos/ncona-code-samples/getting-pid-for-java-process --default_system_javabase=/usr/lib/jvm/java-11-openjdk-amd64 --failure_detail_out=/home/adrian/.cache/bazel/_bazel_adrian/2cff94953bdedc4a1c6a41ce83e93da8/failure_detail.rawproto --deep_execroot --expand_configs_in_place --idle_server_tasks --write_command_log --nowatchfs --nofatal_event_bus_exceptions --nowindows_enable_symlinks --client_debug=false --product_name=Bazel --noincompatible_enable_execution_transition --option_sources=install_Ubase:/etc/bazel/bazelrc:trust_Uinstall_Ubase:/etc/bazel/bazelrc
adrian    309527  309158  0 15:03 ?        00:00:05 /home/adrian/.cache/bazel/_bazel_adrian/2cff94953bdedc4a1c6a41ce83e93da8/execroot/__main__/external/local_jdk/bin/java -XX:+UseParallelOldGC -XX:-CompactStrings --add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED --add-opens=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED --patch-module=java.compiler=external/remote_java_tools_linux/java_tools/java_compiler.jar --patch-module=jdk.compiler=external/remote_java_tools_linux/java_tools/jdk_compiler.jar --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED -jar external/remote_java_tools_linux/java_tools/JavaBuilder_deploy.jar --persistent_worker
adrian    313028  311741  0 15:35 pts/3    00:00:00 /home/adrian/.cache/bazel/_bazel_adrian/2cff94953bdedc4a1c6a41ce83e93da8/execroot/__main__/bazel-out/k8-fastbuild/bin/main.runfiles/local_jdk/bin/java -classpath main.jar example.Main
adrian    313346  309158  5 15:35 ?        00:00:02 /home/adrian/.cache/bazel/_bazel_adrian/2cff94953bdedc4a1c6a41ce83e93da8/execroot/__main__/external/local_jdk/bin/java -XX:+UseParallelOldGC -XX:-CompactStrings --add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.comp=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.main=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED --add-opens=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED --patch-module=java.compiler=external/remote_java_tools_linux/java_tools/java_compiler.jar --patch-module=jdk.compiler=external/remote_java_tools_linux/java_tools/jdk_compiler.jar --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED -jar external/remote_java_tools_linux/java_tools/JavaBuilder_deploy.jar --persistent_worker
adrian    313431  312937  0 15:36 pts/8    00:00:00 grep --color=auto java
```

The problem now is that there is a lot of information so it is a little hard to find the process we are looking for.

<!--more-->

## JPS

Jps is a command line application that comes with the JDK and can be used to list the applications currently running on the JVM:

```bash
jps

313028 Main
309527 JavaBuilder_deploy.jar
313346 JavaBuilder_deploy.jar
313625 Jps
```
