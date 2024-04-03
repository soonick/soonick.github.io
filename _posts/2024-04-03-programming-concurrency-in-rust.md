---
title: Programming Concurrency in Rust
author: adrian.ancona
layout: post
date: 2024-04-03
permalink: /2024/03/programming-concurrency-in-rust/
tags:
  - computer_science
  - programming
  - rust
---

One of Rust's most praised features is how it makes concurrent programming safe. In this article we are going to learn some ways to do concurrent programming and explain how Rust makes them safe compared to other programming languages.

## Working with threads

We can start new threads with `thread::spawn`:

```rust
use std::thread;
use std::time::Duration;

fn main() {
    thread::spawn(|| {
        println!("The spawned thread");
    });

    thread::sleep(Duration::from_millis(1));
}
```

This will print:

```bash
The spawned thread
```

<!--more-->

It's worth noting that the main thread doesn't wait for other threads to finish unless we specifically tell it to do it. The following code will most likely run without any output since the main thread will finish before the OS is able to start the thread we spawned.

```rust
use std::thread;

fn main() {
    thread::spawn(|| {
        println!("The spawned thread");
    });
}
```

If we want to wait for a thread to finish, we can use `join`. The following code will always print: `The spawned thread`, because the main thread waits for the thread we created before it exits.

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        println!("The spawned thread");
    });

    handle.join().unwrap();
}
```

## Closures

The `spawn` function takes a closure as an argument, so it's important to understand how closures work before we proceed.

A closure is an anonymous function that captures variables from the environment in which it's created. Let's look at a simple example:

```rust
fn borrow_number() {
    let num = 1;
    let closure = || println!("The number is {}", num);
    println!("Closure not executed yet");
    closure();
}
```

In this example, we create a closure on line 3 and assign it to a variable named `closure` (I'll explain more about the syntax later in this section). On line 5 we execute the closure

Closures, like variables, have lifetimes. This means, we can inadvertently create unsafe scenarios. Luckily, the compiler will alert us about those.

Let's look at an unsafe scenario:

```rust
fn unsafe_borrow() -> impl Fn(){
    let num = 2;
    || println!("The number is {}", num)
}
```

This function creates a closure and returns it. If we try to compile this code, we will get this message:

```bash
error[E0373]: closure may outlive the current function, but it borrows `num`, which is owned by the current function
  --> src/main.rs:12:5
   |
12 |     || println!("The number is {}", num)
   |     ^^                              --- `num` is borrowed here
   |     |
   |     may outlive borrowed value `num`
   |
note: closure is returned here
  --> src/main.rs:12:5
   |
12 |     || println!("The number is {}", num)
   |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
help: to force the closure to take ownership of `num` (and any other referenced variables), use the `move` keyword
   |
12 |     move || println!("The number is {}", num)
   |     ++++

```

Which means that the closure is borrowing the variable `num`, but it might not be valid by the time the closure is run. To solve this problem, we can do what the compiler suggests and use `move`:

```rust
fn move_number() -> impl Fn(){
    let num = 2;
    move || println!("The number is {}", num)
}
```

There is one interesting detail worth noting here. In the example above, `num` is an integer (most likely an `i32`), and integers in rust implement the `Copy` trait, which means they will be automatically copied when they are moved. For that reason, this code works:

```rust
fn integer_is_copied() -> impl Fn(){
    let num = 3;
    let closure = move || println!("The number is {}", num);
    println!("after moving integer: {}", num);
    closure
}
```

If we try to use a type that doesn't implement the `Copy` trait, we will get a compiler error. The following code will fail to compile:

```rust
fn borrow_of_moved() -> impl Fn(){
    let pass = String::from("tacos");
    let closure = move || println!("The password is {}", pass);
    println!("after move {}", pass);
    closure
}
```

The error message looks something like this:

```bash
error[E0382]: borrow of moved value: `pass`
  --> src/main.rs:23:31
   |
21 |     let pass = String::from("tacos");
   |         ---- move occurs because `pass` has type `String`, which does not implement the `Copy` trait
22 |     let closure = move || println!("The password is {}", pass);
   |                   ------- value moved into closure here  ---- variable moved due to use in closure
23 |     println!("after move {}", pass);
   |                               ^^^^ value borrowed here after move
 
```

Like functions, closures can receive arguments:

```rust
fn closure_with_args() {
    let num = 4;
    let closure = |another_num| println!("Captured number: {} Argument number: {}", num, another_num);
    closure(5);
}
```

Here, we can more clearly see that the bars (`|`) are actually delimiters for the closure's arguments. Let's look at some possible ways to define closures:

```rust
fn different_syntax() {
    let c1 = || println!("c1");
    let c2 = |num| println!("c2: {}", num);
    let c3 = |num1, num2| {
        println!("c3: {}", num1);
        println!("c3: {}", num2);
    };
    let c4 = || 45; // We are returning this value
    let c5 = |num: i32| -> i32 {
        println!("c5: {}", num);
        99
    };
    c1();
    c2(1);
    c3(2, 3);
    c4();
    c5(4);
}
```

Variables can be used inside a closure in one of three way: take ownership (move), borrow and borrow mutably. The compiler decides which way is used based on the body of the function and the lifetime of the closure. So far we have seen variables being borrowed and moved. Let's take a look at an example where a variable is borrowed mutably:

```rust
fn borrowed_mutably() {
    let mut num = 5;
    println!("The number is {}", num);
    let mut closure = || {
        num += 1;
        println!("The number inside closure is {}", num);
    };
    closure();
    println!("The number after closure execution is {}", num);
}
```

Note that in this case the `closure` variable becomes mutable too.

The output of this code is:

```bash
The number is 5
The number inside closure is 6
The number after closure execution is 6
```

## Mutexes

Mutexes are a common way to share memory between threads. In this section we are going to see how they can be used in Rust.

Mutexes in Rust can only be accessed through RAII ([Resource Acquisition Is Initialization](https://en.wikipedia.org/wiki/Resource_acquisition_is_initialization)) guards. This makes them safer than plain mutexes in other languages, since we can't access the protected data without locking it first.

A simple example shows how we can only access the data if we lock the mutex first:

```rust
use std::sync::Mutex;

fn main() {
    let m = Mutex::new(123);
    let num = m.lock().unwrap();
    println!("num:  {}", num);
}
```

After creating the mutex, use `lock()` to lock it and get its value.

We can also modify that value if we want to:

```rust
use std::sync::Mutex;

fn main() {
    let m = Mutex::new(123);
    let mut num = m.lock().unwrap();
    *num += 1;
    println!("num:  {}", num);
}
```

The `lock()` function blocks until the mutex is unlocked, so we can easily create a deadlock if we are not careful:

```rust
use std::sync::Mutex;

fn main() {
    let m = Mutex::new(123);
    let num = m.lock().unwrap();
    let num2 = m.lock().unwrap();
}
```

The code above will never finish, since we lock the mutex in line `5` and line `6` will wait for the mutex to be released forever.

We can avoid this problem by making sure the mutex is released before acquiring it again. For example:

```rust
use std::sync::Mutex;

fn main() {
    let m = Mutex::new(123);

    {
        let mut num = m.lock().unwrap();
        *num += 1;
    }

    let num = m.lock().unwrap();
    println!("num:  {}", num);
}
```

Mutexes are usually used in multi-threaded applications, which makes things a little more complicated. Let's look at an example where a mutex is shared between multiple threads:

```rust
fn mutex_multiple_threads() {
    let last_thread = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for i in 1..10 {
        let last_thread = Arc::clone(&last_thread);
        let handle = thread::spawn(move || {
            let mut num = last_thread.lock().unwrap();
            *num = i;
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!(
        "Last thread to set the value was: {}",
        *last_thread.lock().unwrap()
    );
}
```

In the example above, we create a mutex that will hold the number of the thread that executed last. When we create the thread we use `Arc`, which stands for `Atomic Reference Counted`:

```rust
let last_thread = Arc::new(Mutex::new(0));
```

An `Arc` works like an Rc (Reference Counted) smart pointer but it's atomic; i.e. It's safe to use between multiple threads.

We use `Arc::clone`, the same way we would use `Rc::clone`:

```rust
let last_thread = Arc::clone(&last_thread);
```

In this example, we set `num` to the number of the thread that is running. Since threads run concurrently, we don't really know what `num` will be set to at the end of the program. The only thing we know for sure is that it will be set to a number between 1 and 10.

## Channels

Channels are a way to communicate between threads that's become very popular recently because it's generally safer than using shared memory.

Functionality for channel communication is available in the `std::sync::mpsc` crate. `mpsc` stands for `Multiple Producers, Single Consumer`, which describes how channels work in Rust.

Let's look at a simple example that sends a message from one thread to another:

```rust
fn single_message() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        if tx.send("Hello world!").is_err() {
            println!("There was an error sending message");
        }
    });

    match rx.recv() {
        Ok(mes) => println!("Message: {}", mes),
        Err(err) => println!("There was an error receiving mesage. Error: {}", err)
    };
}
```

There are a few things to unwrap from this example. The first thing to notice is the use of `channel()` to create a transmitter and a receiver:

```rust
let (tx, rx) = mpsc::channel();
```

We move the transmitter into a thread and use `send` to send a message:

```rust
thread::spawn(move || {
    if tx.send("Hello world!").is_err() {
        println!("There was an error sending message");
    }
});
```

The `recv` function will wait until there is a message and then return the message or an error:

```rust
match rx.recv() {
    Ok(mes) => println!("Message: {}", mes),
    Err(err) => println!("There was an error receiving mesage. Error: {}", err)
};
```

We also see some error handling in the code. I included error handling in this example because there are some common scenarios where sending and receiving of messages might fail.

We could fail to send a message if the receiver is already closed:

```rust
fn closed_receiver() {
    let (tx, rx) = mpsc::channel();

    drop(rx);
    let handle = thread::spawn(move || {
        if tx.send("Hello world!").is_err() {
            println!("There was an error sending message");
        }
    });
    handle.join().unwrap();
}
```

Or fail to receive a message if the transmitter is closed:

```rust
fn closed_transmitter() {
    let (tx, rx) = mpsc::channel::<String>();

    drop(tx);
    match rx.recv() {
        Ok(mes) => println!("Message: {}", mes),
        Err(err) => println!("There was an error receiving mesage. Error: {}", err)
    };
}
```

So far, we have used a channel to send a single message, but we can send multiple messages:

```rust
fn multiple_messages() {
    let (tx, rx) = mpsc::channel();

    thread::spawn(move || {
        if tx.send("Hello world!").is_err() {
            println!("There was an error sending message");
        }

        if tx.send("Are you still there?").is_err() {
            println!("There was an error sending message");
        }

        if tx.send("Ok, bye!").is_err() {
            println!("There was an error sending message");
        }
    });

    for res in rx {
        println!("Message: {}", res);
    }

    println!("Finished reading messages. Most likely the transmitter closed");
}
```

Note how we use a for loop on `rx` to read all the messages. We can do this because `rx` is an iterator. When there are no more messages (`tx` goes out of scope), the for loop ends and the function exits.

We mentioned previously that MPSC stands for Multiple Producers, Single Consumer. Let's see how we can have more than one producer:

```rust
fn multiple_transmitters() {
    let (tx, rx) = mpsc::channel();

    let tx_clone = tx.clone();
    thread::spawn(move || {
        for i in 1..5 {
            if tx_clone.send(format!("Thread 1: {}", i)).is_err() {
                println!("There was an error sending message");
            }
            thread::sleep(Duration::from_millis(1));
        }
    });

    thread::spawn(move || {
        for i in 1..5 {
            if tx.send(format!("Thread 2: {}", i)).is_err() {
                println!("There was an error sending message");
            }
            thread::sleep(Duration::from_millis(1));
        }
    });

    for res in rx {
        println!("Message: {}", res);
    }

    println!("Finished reading messages. Most likely the transmitter closed");
}
```

The first thing to notice here is the use of `tx.clone()` to create a clone of the transmitter. We then use the clone (`tx_clone`) inside the first thread and the original (`tx`) in the second thread.

We introduced some sleeps, so the output makes it clear that the threads are being executed concurrently.

## Conclusion

In this article we learned a few topics related to concurrency. All the examples, are available in [my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/programming-concurrency-in-rust).

I was planning on covering async programming in this article, but I noticed the current state of Rust makes it hard to explain without doing it in the context of a specific crate.

I will try to write an article about this topic in the future, most likely using Tokyo as framework. In the meantime, I recommend reading [Asynchronous Programming in Rust](https://rust-lang.github.io/async-book/) to understand the concepts of Asynchronous programming.
