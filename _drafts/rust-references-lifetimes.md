---
title: Rust References Lifetimes
author: adrian.ancona
layout: post
# date: 2019-01-30
# permalink: /2019/02/introduction-to-rust/
tags:
  - programming
  - rust
---

Rust has a mechanism called `borrow checker` that makes sure references are not used when they are not valid anymore. The borrow checker uses lifetimes to do its job internally.

Let's look at a simple example where the borrow checker detects a possibly invalid reference:

```rust
fn main() {
    let r;

    {
        let i = 1;
        r = &i;
    }

    println!("{}", r);
}
```

If we compile this, we'll get the following error:

```
error[E0597]: `i` does not live long enough
 --> src/main.rs:6:13
  |
5 |         let i = 1;
  |             - binding `i` declared here
6 |         r = &i;
  |             ^^ borrowed value does not live long enough
7 |     }
  |     - `i` dropped here while still borrowed
8 |
9 |     println!("{}", r);
  |                    - borrow later used here
```

The message says that `r = &i` is "borrowing" from `i`. Later in the code, we try to use `r`, but `i` is invalid (because it's gone out of scope), which makes `r` invalid too. This shows that a reference is not allowed to outlive the variable it borrows from.

So far, it's pretty simple. It becomes trickier when the compiler is unable to infer the lifetime of a reference without the programmer's help.

## Functions that return references

When we write a function that returns a reference, the returned reference is always one of the received arguments. The reason for this is that all variables created inside the function will go out of scope when the function execution finishes.

This means, the lifetime of the returned reference is the same as the lifetime of one of the arguments. When we have a single argument, the compiler knows to use that arguments lifetime.

We can see that this is true by compiling this code:

```rust
fn ditto(input: &str) -> &str {
    input
}

fn main() {
    let str = String::from("Ditto");
    let str2 = ditto(&str);
    drop(str);
    println!("{}", str2);
}
```

We will get the following error message:

```
error[E0505]: cannot move out of `str` because it is borrowed
 --> src/main.rs:8:10
  |
6 |     let str = String::from("Ditto");
  |         --- binding `str` declared here
7 |     let str2 = ditto(&str);
  |                      ---- borrow of `str` occurs here
8 |     drop(str);
  |          ^^^ move out of `str` occurs here
9 |     println!("{}", str2);
  |                    ---- borrow later used here
```

The error message is telling us that `str2` (the reference returned by ditto) is a borrow of `str`, so it can't be used after `str` has been dropped.

If a function has more than one argument, things become a little more interesting. Probably surprisingly, the following code will fail to compile:

```rust
fn return_best(input1: &str, input2: &str) -> &str {
    if input1 > input2 {
        input1
    } else {
        input2
    }
}

fn main() {
    let str1 = "One";
    let str2 = "Two";
    let str3 = return_best(&str1, &str2);
    println!("{}", str3);
}
```

This is the error we'll get:

```
error[E0106]: missing lifetime specifier
 --> src/main.rs:1:47
  |
1 | fn return_best(input1: &str, input2: &str) -> &str {
  |                        ----          ----     ^ expected named lifetime parameter
  |
  = help: this function's return type contains a borrowed value, but the signature does not say whether it is borrowed from `input1` or `input2`
help: consider introducing a named lifetime parameter
  |
1 | fn return_best<'a>(input1: &'a str, input2: &'a str) -> &'a str {
  |               ++++          ++               ++          ++
```

The compiler is telling us: "I'm getting two references as arguments and I don't know what's the lifetime of the returned reference. Please tell me". The last part of the error message suggests a way to fix it:

```rust
fn return_best<'a>(input1: &'a str, input2: &'a str) -> &'a str {
    if input1 > input2 {
        input1
    } else {
        input2
    }
}
```

The code above uses lifetime annotations to tell the compiler our intentions. Let's take a closer look at the function signature:

```rust
fn return_best<'a>(input1: &'a str, input2: &'a str) -> &'a str {
```

First of all, we can see that there are some angle brackets (`<>`) between the function name and the arguments list. Inside the angle brackets we are specifying a generic lifetime (`'a`). Generic lifetimes start with a single quote `'` and are generally a single letter.

Then, we can see that we changed our arguments to use `&'a str` instead of `&str`. This basically means: `input1` and `input2` are string references and since both use the lifetime `'a`, it will be the overlap between the lifetimes of both arguments.

Finally, we changed the returned type from `&str` to `&'a str`. We already mentioned that the `'a` is the overlap of the lifetime of both arguments, so that will be the returned lifetime.

We can see that the lifetime of `'a` is equal to the overlap of both arguments, by trying to compile this code:

```rust
fn return_best<'a>(input1: &'a str, input2: &'a str) -> &'a str {
    if input1 > input2 {
        input1
    } else {
        input2
    }
}

fn main() {
    let str1 = String::from("One");
    let str3;
    {
        let str2 = String::from("Two");
        str3 = return_best(&str1, &str2);
    }
    println!("{}", str3);
}
```

We get the following error message, which tells us that we are trying to use `str3` when it might already be invalid:

```
error[E0597]: `str2` does not live long enough
  --> src/main.rs:14:35
   |
13 |         let str2 = String::from("Two");
   |             ---- binding `str2` declared here
14 |         str3 = return_best(&str1, &str2);
   |                                   ^^^^^ borrowed value does not live long enough
15 |     }
   |     - `str2` dropped here while still borrowed
16 |     println!("{}", str3);
   |                    ---- borrow later used here
```

## Lifetimes in struct definitions

If we want to create structs that hold references we need to annotate them:

```rust
struct HoldReference<'a> {
    something: &'a str,
}
```

This helps the compiler figure out the lifetime of the whole struct.

## Conclusion

This article helps us understand the relationships between the lifetimes of different variables and how the compiler uses them to help us avoid mistakes.

This article helped me get through some compiler errors I was getting while writing some code; but I can't help but wonder "Could the compiler figure out the lifetimes without the need for annotations?". I tried to find some information about why the annotations are required in cases where the lifetime might be obvious, and from my understanding, these are the reasons:

- Annotations make the compiler's life easier
- In cases where generics are used, it might not be so simple for the compiler to figure out the correct lifetime

Find runnable versions of the examples above in [my code samples repo](https://github.com/soonick/ncona-code-samples/tree/master/rust-references-lifetimes).
