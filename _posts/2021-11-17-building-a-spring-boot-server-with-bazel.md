---
title: Building a Spring Boot server with Bazel
author: adrian.ancona
layout: post
date: 2021-11-17
permalink: /2021/11/building-a-spring-boot-server-with-bazel
tags:
  - architecture
  - java
  - programming
  - server
---

Spring is a very popular Java Framework that is often used to build servers. It's widely used by many companies because it provides a rich toolbox that can help achieve a great variety of tasks.

In this article, we're going to learn how to create a simple Spring server using Bazel as build system.

## Building the server

If you have never used Bazel, I recommend you take a look at my [introduction to Bazel](https://ncona.com/2021/08/introduction-to-bazel) to get familiar with it.

Spring has a tool called `spring intializr` that helps [create a Spring Boot project from scratch](https://start.spring.io/). The problem is that at the time of this writing it only supports `Maven` and `Gradle`.

<!--more-->

Since we can't use that tool, we're going to create a folder for our application and add a `WORKSPACE` file:

```python
load('@bazel_tools//tools/build_defs/repo:http.bzl', 'http_archive')

RULES_JVM_EXTERNAL_TAG = '4.1'
RULES_JVM_EXTERNAL_SHA = 'f36441aa876c4f6427bfb2d1f2d723b48e9d930b62662bf723ddfb8fc80f0140'

http_archive(
  name = 'rules_jvm_external',
  strip_prefix = 'rules_jvm_external-%s' % RULES_JVM_EXTERNAL_TAG,
  sha256 = RULES_JVM_EXTERNAL_SHA,
  url = 'https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip' % RULES_JVM_EXTERNAL_TAG,
)

load('@rules_jvm_external//:defs.bzl', 'maven_install')

maven_install(
  artifacts = [
    'org.springframework.boot:spring-boot-autoconfigure:2.1.3.RELEASE',
    'org.springframework.boot:spring-boot-starter-web:2.1.3.RELEASE',
    'org.springframework.boot:spring-boot:2.1.3.RELEASE',
    'org.springframework:spring-web:5.1.5.RELEASE',
  ],
  repositories = [
    'https://repo1.maven.org/maven2',
  ],
  fetch_sources = True,
)
```

In this file we can see how we load our `spring` dependencies. The next thing we need is a `BUILD` file:

```python
java_binary(
  name = 'app',
  main_class = 'com.example.demo.DemoApplication',
  srcs = glob(['src/**/*.java']),
  deps = [
    '@maven//:org_springframework_boot_spring_boot',
    '@maven//:org_springframework_boot_spring_boot_autoconfigure',
    '@maven//:org_springframework_boot_spring_boot_starter_web',
    '@maven//:org_springframework_spring_web'
  ],
)
```

Here we create a java binary using the files in the `src` folder. Let's create the file `src/main/java/com/example/demo/DemoApplication.java` with this content:

```java
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
  public static void main(String[] args) {
    SpringApplication.run(DemoApplication.class, args);
  }
}
```

And we can now run our Spring Boot application:

```
bazel run :app
```

Our app doesn't yet do anything, but we have built and ran our app with Bazel.

We can modify our java file so the server listens to an endpoint:

```java
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@SpringBootApplication
public class DemoApplication {
  public static void main(String[] args) {
    SpringApplication.run(DemoApplication.class, args);
  }

  @GetMapping("/greet")
  public String hello(@RequestParam(value = "name", defaultValue = "World") String name) {
    return String.format("Hello %s!", name);
  }
}
```

We now have a `greet` endpoint that we can hit:

```sh
curl http://localhost:8080/greet?name=adrian
```

## Conclusion

In this article we learned how to build a simple Spring Boot server with Bazel. We didn't touch much into all the features that Spring has, but this can serve as the foundation we use to explore the framework.
