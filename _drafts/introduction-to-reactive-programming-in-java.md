---
title: Introduction to Reactive Programming in Java
author: adrian.ancona
layout: post
# date: 2021-01-13
# permalink: /2021/01/introduction-to-aws-dynamo-db
tags:
  - architecture
  - design_patterns
  - java
  - programming
---

## Reactive Programming

I'm a little embarrased to admit it, but Reactive Programming is a concept I learned about very recently.

At the place where I work, we have a [GraphQL](/2021/11/introduction-to-graphql) server where Reactive Programming is used to communicate with our back-end services.

I couldn't easily figure out how this worked at first sight, so I'm hoping writing this article will help me understand it.

If we search the internet for `Reactive Programming`, we will find a lot of references to streams and real-time updates. Although this was probably the original intended scenario for Reactive Programming, it doesn't help us understand the paradigm.

An simpler way to think about Ractive Programming is as a system that `reacts` to events. These events can be anything: measurements from a sensor, user's input, etc.

In the case of my company's GraphQL server the events are HTTP requests. When an event is received, it usually spawns a number of back-end requests and return a result.

There is a clear definition of an event (receive an HTTP request) and a reaction (Make backend calls and create a response), but how is this better to the traditional request-response model that most servers follow? To answer this, we need to take a close look at how most servers work.

Let's say we have a [Spring Boot](https://ncona.com/2021/11/building-a-spring-boot-server-with-bazel) server configured to use a single thread (This is not something we want to do in a real server, but it makes the explanation simpler):

```java
package com.example.demo;

import java.util.Collections;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@SpringBootApplication
public class DemoApplication {
  public static void main(String[] args) {
    SpringApplication app = new SpringApplication(DemoApplication.class);
    app.setDefaultProperties(Collections.singletonMap("server.tomcat.max-threads", "1"));
    app.run(args);
  }

  @GetMapping("/greet-delayed")
  public String helloDelayed(@RequestParam(value = "name", defaultValue = "World") String name) throws Exception {
    Thread.sleep(10000);
    return String.format("Hello %s!\n", name);
  }

  @GetMapping("/greet")
  public String hello(@RequestParam(value = "name", defaultValue = "World") String name) throws Exception {
    return String.format("Hello %s!\n", name);
  }
}
```

Our server has 2 endpoints `/greet`, which returns a greeting right away, and `/greet-delayed`, which waits 10 seconds and then returns a greeting.

If we send a request to `/greet-delayed`:

```sh
curl http://localhost:8080/greet-delayed?name=adrian
```

And immediately send a request to `/greet`:

```sh
curl http://localhost:8080/greet?name=carlos
```

We'll notice something interesting. The request to `/greet` doesn't return right away, it actually waits for the call request to `/greet-delayed` to finish and then it returns.

[<img src="/images/posts/reactive-programming-waiting-for-thread.png" alt="Spring Boot waiting for thread" />](/images/posts/reactive-programming-waiting-for-thread.png)

The image above shows how `/greet` is waiting for thread before it can be processed, while Thread 1 spends most of its time sleeping.

Depending on where you come from this behavior might be a surprise or be completely intuitive. Some programming languages use asynchronous APIs that free threads when IO (Network calls, read from disk, etc.) operations needs to be done. While the IO operation is in progress, the thread can be used to do other work that needs to be done. To achive something similar in java, we use Reactive Programming.

To help us decide if we want to use Reactive Programming in our next project, here are some usual scenarios where Reactive Programming is used:

- Processing input from sensors
- Processing users' input (e.g. mouse movement or keyboard clicks)
- Processing data from a data producer
- Processing and responding to IO bound events (i.e. Network or disk requests)

We now know Reactive Programming can be used for those scenarios, but why would we use it? What makes it better that other approaches? Let's take a closer look to answer those questions.

## 
