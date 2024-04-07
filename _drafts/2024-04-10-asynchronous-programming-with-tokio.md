---
title: Asynchronous Programming with Tokio
author: adrian.ancona
layout: post
date: 2024-04-10
permalink: /2024/04/asynchronous-programming-with-tokio/
tags:
  - programming
  - rust
---

If you are interested in learning about asynchronous programming in more depth, I recommend reading [Asynchronous Programming in Rust](https://rust-lang.github.io/async-book/).

## Asynchronous programming

When we run code that makes network requests, these request are sent through the network.

Sending the request and waiting for the response is done by the network peripheral and doesn't require the CPU. This means, the CPU is free to do other things while it waits.

Code written synchronously will send a request and then block the thread waiting for a response. For example:

```rust
fn main() {
    let resp = reqwest::blocking::get("https://httpbin.org/ip")?.text()?;
    println!("{:#?}", resp);
}
```

<!--more-->

The code above, makes the request and blocks the thread until a response is ready.

With asynchronous programming, we can take advantage of the thread and use it to do something while we wait for a response.

## What's Tokio

Asynchronous code requires a `runtime` to execute. More specifically, it requires a `scheduler` that executes tasks, a `timer` that executes code after a specified period of time and a `driver` that takes care of executing asynchronous I/O tasks and responding to events from these tasks. Tokio provides all these things.

## Using Tokio

A minimal example of using Tokio runtime looks like this:

```rust
fn main() {
    let rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(async {
        println!("Hello world!");
    });
}
```

The result of running this code is simply printing `Hello world!` to the console.

The first instruction creates the Tokio runtime:

```rust
let rt = tokio::runtime::Runtime::new().unwrap();
```

In the next instruction we use `block_on` to have the main function wait until the given async function ends.

```rust
rt.block_on(async {
    println!("Hello world!");
})
```

The keyword `async` creates an `async` block, which is a block of code that needs to be executed by an asynchronous runtime.

Of course, this is a very complicated way to print a string to the console. We're just using it to show how the Tokio runtime works.

It is uncommon to create the runtime explicitly like we did above. We will most of the time find code written like this:

```rust
#[tokio::main]
async fn main() {
    println!("Hello world!");
}
```

The `#[tokio::main]` procedural macro takes an `async` version of `main` and rewrites it to something similar to our first example.

A more real-world example, where asynchronous programming is actually useful, is executing HTTP requests in parallel. For example:

```rust
#[tokio::main]
async fn main() {
    let r1 = reqwest::get("https://httpbin.org/ip").await;
    let r2 = reqwest::get("https://google.com").await;
    println!("{}", r1.unwrap().status());
    println!("{}", r2.unwrap().status());
}
```

In this example, we are calling `reqwest` to make requests, since it provides an asynchronous API. Calling `await` on the result of `reqwest.get` converts it into a task that will be executed by Tokio runtime.

The first request is started and a Future is returned. The second request is immediately started and also returns a Future.

When we call `unwrap` on `r1`, the future will be resolved if it's available. If not, Tokio runtime will continue running other tasks. The main function will be resumed once the `r1` future is resolved. Same thing for `r2`.

## Conclusion

Tokio allows us to write asynchronous code without having to worry too much about the implementation.

To take advantage of this, we need to use libraries (in the last example we used `reqwest`) that provide functions that are compatible with Tokio runtime. This means that sometimes we'll find libraries that are not compatible with Tokio. Luckly, Tokio is the most popular runtime for Rust, so this shouldn't happen too often.

As usual, [runnable examples can be found in Github](https://github.com/soonick/ncona-code-samples/tree/master/asynchronous-programming-with-tokio).
