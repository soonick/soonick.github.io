---
title: Error Handling in Rust
author: adrian.ancona
layout: post
date: 2024-12-18
permalink: /2024/12/error-handling-in-rust/
tags:
  - debugging
  - programming
  - rust
---

## Unrecoverable errors

These errors are a sign that the developer made a mistake. An example of this, could be trying to access an index that is out of bounds. For example:

```rust
fn get_number() -> usize {
    return 5;
}

fn main() {
    let numbers = [1, 2];
    println!("{}", numbers[get_number()]);
}
```

<!--more-->

If we run that code, we will get the following error, and the program will crash:

```
thread 'main' panicked at src/main.rs:7:20:
index out of bounds: the len is 2 but the index is 5
```

We can trigger an unrecoverable error manually, by using `panic!`:

```rust
fn main() {
    panic!("Something went wrong!");
}
```

In this case, we'll get the following output:

```
thread 'main' panicked at src/main.rs:2:5:
Something went wrong!
```

## Recoverable errors

These errors, mean, something went wrong, but the program can continue execution. An example could be sending an HTTP request. There are many reasons why this could fail, and the program can proceed a different way depending on the cause of the error.

For recoverable errors, Rust uses the `Result` type. The Result type, is an enum that looks like this:

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

Where `T` is a type that will be returned in case of success, and `E` is a type that will be returned in case of error.

Since `Result` is an enum, we can use `match` to do different things depending on if the result is a success or an error:

```rust
use std::env;

fn main() {
    match env::current_dir() {
        Ok(t) => {
            print!("The current directory is: {}", t.display());
        },
        Err(e) => {
            print!("There was an error: {}", e);
        }
    }
}
```

In the example above, we print the current directory if we are able to get it. Otherwise, we print an error message. It's the same as doing:

```rust
use std::env;

fn main() {
    let res = env::current_dir();
    match res {
        Ok(t) => {
            print!("The current directory is: {}", t.display());
        },
        Err(e) => {
            print!("There was an error: {}", e);
        }
    }
}
```

## Creating our results

As we already saw, `Result` is an enum with two different values and each value can hold a variable of a generic type:

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

Following this, we can create a `Result` with the value `Ok` like this:

```rust
Ok(some_variable);
```

And a `Result` with the value `Err` with:

```rust
Err(some_variable)
```

As an example, this code will sometimes return an error, and sometimes it will return a value:

```rust
use rand::Rng;

fn do_something() -> Result<bool, i8> {
    let num: i8 = rand::thread_rng().gen_range(0..3);
    if num == 0 {
        return Ok(true);
    } else {
        return Err(num);
    }
}

fn main() {
    match do_something() {
        Ok(r) => {
            println!("The result is: {}", r);
        },
        Err(e) => {
            println!("The error is: {}", e);
        }
    }
}
```

We can see from this example that the types for the value and error can be anything we want.

## Propagating errors

The `Result` type, works like any other generic type. If a function returns a `Result<bool, i8>` we can return this result from another function, and it will be propagated as expected:

```rust
fn do_nothing() -> Result<bool, i8> {
    do_something()
}

fn do_something() -> Result<bool, i8> {
    let num: i8 = rand::thread_rng().gen_range(0..3);
    if num == 0 {
        return Ok(true);
    } else {
        return Err(num);
    }
}
```

In this case, `do_nothing` simply propagates the `Result` returned from `do_something`.

We get more flexibility when we use the `?` operator. It allows us to get a success value or return the result with a simple syntax:

```rust
fn change_result_type() -> Result<String, i8> {
    let r = do_something()?;
    if r {
        return Ok("All good".to_string());
    } else {
        return Ok("Not so good".to_string());
    }
}

fn do_something() -> Result<bool, i8> {
    let num: i8 = rand::thread_rng().gen_range(0..3);
    if num == 0 {
        return Ok(true);
    } else {
        return Err(num);
    }
}
```

Notice how `change_result_type` returns `Result<String, i8>`, which is different from the return type for `do_something`. In the example above, `change_result_type` is equivalent to the following code:

```rust
fn change_result_type() -> Result<String, i8> {
    match do_something() {
        Ok(r) => {
            if r {
                return Ok("All good".to_string());
            } else {
                return Ok("Not so good".to_string());
            }
        },
        Err(e) => {
            return e;
        }
    }
}
```

It's important to keep in mind, that for this to work, the error types must be the same. In this example, the error type for `change_result_type` and `do_something` is `i8`.

## Using traits as return types

So far, we have been using concrete types on our `Result`s, but it's also possible to use traits.

It's common to use the trait `std::error::Error` as error type, but there are some gotchas we need to keep in mind.

Let's say we want to write a function that uses `std::error::Error` as error type:

```rust
fn do_something() -> Result<bool, std::error::Error> {
    env::current_dir()?;
    Ok(true)
}
```

The example above might look valid, but it will fail compilation with this error:

```
error[E0277]: the size for values of type `(dyn std::error::Error + 'static)` cannot be known at compilation time
 --> src/main.rs:3:22
  |
3 | fn do_something() -> Result<bool, std::error::Error> {
  |                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ doesn't have a size known at compile-time
  |
  = help: the trait `Sized` is not implemented for `(dyn std::error::Error + 'static)`
```

The most important thing to understand from this error message is that Rust only allows returning concrete, types because it needs to know the size of the type. Since a trait can be any of multiple types, we need a little trick to make it work.

The trick consists of wrapping our return type in a `Box`. A `Box` is simply a container pointing to some information that's stored in the heap.

So, the correct code looks like this:

```rust
fn do_something() -> Result<bool, Box<dyn std::error::Error>> {
    env::current_dir()?;
    Ok(true)
}
```

Notice that we also prefixed `std::error::Error` with the keyword `dyn`. This is just because Rust tries to be explicit about when things are allocated to the heap. Anytime something is in the heap, we will see that keyword.

## Defining our own error types

When we define an error type, we want to make sure we implement the `std::error::Error` trait. The easiest way looks like this:

```rust
use std::fmt;

#[derive(Debug, Clone)]
struct OurError;

impl fmt::Display for OurError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Just a custom error")
    }
}

impl std::error::Error for OurError {}
```

We start by defining our struct. We use `derive` to automatically implement `Debug` and `Clone`. The `std::error::Error` trait extends the `Debug` trait, so we need to implement it and this is the easiest way. The `Clone` trait is not strictly necessary, but it will most likely be useful in the future.

We follow by implementing the `fmt::Display` trait, which is also extended by `std::error::Error`. This makes our error easy to print for debugging.

Finally, we specify that `OurError` implements the `std::error::Error` trait.

We can now return our custom error as desired:

```rust
fn do_something() -> Result<bool, Box<dyn std::error::Error>> {
    Err(Box::new(OurError))
}
```

## Handling different errors

Since traits can be used as return types, it comes that there might be different kinds of errors contained in them. It's common to want to handle different kinds of errors differently.

Sadly, the way to do this is Rust is very cumbersome. Let's say we have a function and we expect it to return two different kinds of errors. In that case, we need to start by defining an enum with the expected error types:

```rust
#[derive(Debug, Clone)]
enum CustomErrorEnum {
    OurError(OurError),
    ErrorTwo(ErrorTwo),
}
```

Then we can make our function return this enum as error type:

```rust
fn do_something() -> Result<bool, CustomErrorEnum> {
    Err(CustomErrorEnum::ErrorTwo(ErrorTwo))
}
```

Finally, we can handle the different error types explicitly:

```rust
fn main() {
    match do_something() {
        Ok(_) => {
            println!("All good");
        },
        Err(CustomErrorEnum::OurError(e)) => {
            println!("Got OurError: {}", e);
        },
        Err(CustomErrorEnum::ErrorTwo(e)) => {
            println!("Got ErrorTwo: {}", e);
        },
    }
}
```

This need for creating enums can be annoying, but it's the only way I found to achieve this.

## Conclusion

I found two things about error handling in Rust not that great:

- The need for using `Box` when returning an interface
- The inability of differentiating error types without creating a custom enum

I hope these are things that can be improved in future versions.

As usual, you can find working versions of all the code shown here in [my examples' repo](https://github.com/soonick/ncona-code-samples/tree/master/error-handling-in-rust).
