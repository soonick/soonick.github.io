---
title: Introduction to Rust
author: adrian.ancona
layout: post
date: 2024-02-21
permalink: /2024/02/introduction-to-rust/
tags:
  - computer_science
  - programming
  - rust
---

[Rust](https://www.rust-lang.org/) is a relatively new programming language that promises to be as fast as C, but less complex and error prone.

Rust compiles directly to machine code, so it doesn't require a virtual machine. This makes it faster than languages like Java or Python. It also doesn't use a garbage collector, which makes it faster and more predictive than other compiled languages like Golang.

On top of speed and predictability, Rust also promises a programming model that ensures memory and thread safety, which makes it great for complex applications.

## Installation

The recommended way to install rust in Linux and Mac is using this command:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

We will be greeted by this prompt asking to choose an option:

```bash
1) Proceed with installation (default)
2) Customize installation
3) Cancel installation
```

<!--more-->

We can choose the default (option `1`).

When the installation finishes, we will need to close our terminal and open a new one. Then we can use this command to verify the installation was successful:

```bash
rustc --version
```

## Hello world

Now that we have rust installed, let's create a file named `hello_world.rs`, with this content:

```bash
fn main() {
    println!("Hello, world!");
}
```

We can then compile and run the program with:

```bash
rustc hello_world.rs && ./hello_world
```

One thing to notice from our hello world code is that there is an exclamation mark (`!`) after `println`. For now, we just need to know that `println` is a macro, and we need to use that notation (`!`) when calling macros.

## Cargo, Rust's build system

When we installed Rust, Cargo was automatically installed:

```bash
cargo --version
```

Cargo allows us to create and interact with Rust projects in a standard way.

We can create a new project and run it with:

```bash
cargo new cargo_demo
cd cargo_demo
cargo run
```

If we inspect the `cargo_demo` folder we will see a few files that were created for us.

`cargo.toml` is a configuration file for our project. It let's us set some properties, and it also keeps track of the project's dependencies:

```toml
[package]
name = "cargo_demo"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
```

`cargo.lock` is used to manage dependencies. This file should never be edited manually.

By default cargo generates a project that uses git as version control. For this reason a `.git` folder and `.gitignore` file are created.

Finally, the code lives inside the `src` folder. The generator creates a single file named `main.rs`.

## Variables

Variables in Rust have some peculiar behaviors. We'll explore those in this section.

They are immutable and their type is implied based on the context:

```rust
fn main() {
    let x = 5;
}
```

The code above will create an immutable variable named `x` of type `i32` and value `5`.

Immutable variables can't be changed. To make a variable mutable, we can use the `mut` keyword:

```rust
fn main() {
    let mut x = 5;
    x = 10;
}
```

By using the `mut` keyword, we can modify the value of `x`.

An immutable variable might sound like a constant, but there are a few differences between constants and immutable variables in Rust. These statements are true for constants:

- They use the `const` keyword
- They can't be made mutable
- Their type must be specified
- They may only be set to constant expressions (Values that can be known at compile time)

An example of a constant declaration:

```rust
const MY_NUMBER: u32 = 23;
```

Another interesting aspect of variables in Rust is how shadowing works. The following code is valid in Rust as well as in many other programming languages:

```rust
fn main() {
    let x = 1;

    if true {
        let x = 2;
        println!("x is {x}");
    }

    println!("x is {x}");
}
```

The output is:

```bash
x is 2
x is 1
```

The re-declaration of `x` in the inner scope `shadows` the previous declaration of `x`.

On the other hand, rust allows re-declaring variables in the same scope:

```rust
fn main() {
    let x = 1;
    println!("x is {x}");

    let x = 2;
    println!("x is {x}");
}
```

The output is:

```bash
x is 1
x is 2
```

This works in Rust. In other programming languages we would probably get an error telling us that a variable with the name `x` has already been declared in that scope.

## Functions

We've already seen the `fn` keyword used in the definition of the `main` function. We can also create our own functions that receive arguments and return a value. For example:

```rust
fn add(x: i32, y: i32) -> i32 {
    x + y
}
```

As is normal in compiled languages, we need to define the types of the arguments and the return value.

The most surprising thing (in my opinion) is the implicit return of the last statement inside a function (with the caveat that it shouldn't be ended with a semicolon (`;`)). We can still use the `return` keyword for early returns when necessary. For example:

```rust
fn add(x: i32, y: i32) -> i32 {
    if x == 0 || y == 0 {
        return 0
    }

    x + y
}
```

## Structs

When it comes to Object Orientation, Rust is more similar to Golang than it is to C++.

This is an example of how we can create and use a simple struct:

```rust
struct Animal {
    number_of_legs: u8,
    color: String,
}

fn main() {
    let dog = Animal {
        number_of_legs: 4,
        color: String::from("brown"),
    };

    println!("Animal color: {}, number of legs {}", dog.color, dog.number_of_legs);
}
```

Similar to Golang, method definition is done outside the struct. For example:

```rust
struct Animal {
    number_of_legs: u8,
    color: String,
    sound: String,
}

impl Animal {
    fn talk(&self) {
        println!("{}", self.sound)
    }
}

fn main() {
    let dog = Animal {
        number_of_legs: 4,
        color: String::from("brown"),
        sound: String::from("Woof"),
    };

    dog.talk();
}
```

Note how we use `impl` to start defining methods for a struct.

We can create a method that acts as a constructor by returning a `Self`:

```rust
struct Animal {
    number_of_legs: u8,
    color: String,
    sound: String,
}

impl Animal {
    fn talk(&self) {
        println!("{}", self.sound)
    }

    fn create_dog(color: String) -> Self {
        Self {
            number_of_legs: 4,
            color: color,
            sound: String::from("Woof"),
        }
    }
}

fn main() {
    let dog = Animal::create_dog(String::from("brown"));

    dog.talk();
}
```

Privacy in Rust is managed at the package / crate / module level, not at the struct level. Structs, methods and attributes are always locally accessible and by default not accessible by other modules. To illustrate this, let's dig into packages.

## Packages, Crates and Modules

A `Package` is a cargo project that can contain multiple binaries and at most, one library. Binaries and libraries are called `Crates` in Rust. A crate can contain multiple `Modules`, which are defined by a directory structure in the file system.

We created a package in the past with this command:

```bash
cargo new cargo_demo
```

A package contains a `cargo.toml` file that defines the crates inside of it. Cargo also created the file `src/main.rs`. By convention, this means we are creating a binary crate. If we wanted to create a library, we would put it in `src/lib.rs`. If we wanted to create a package with multiple binaries, we would create the folder `src/bin/` and add our binaries in that folder.

For a newly created project, we will get this folder structure:

```
cargo_demo
├── Cargo.lock
├── Cargo.toml
└── src
    └── main.rs
```

Let's create a new module by creating the folder `src/zoo` and the files `src/zoo/animal.rs` and `src/zoo.rs`:

```
cargo_demo
├── Cargo.lock
├── Cargo.toml
└── src
    ├── zoo
    │   └── animal.rs
    ├── main.rs
    └── zoo.rs
```

We need to include the module `animal` inside `zoo.rs`:

```rust
pub mod animal
```

Notice the usage of `pub` to make the module accessible by other modules.

We can then add this to `animal.rs`:

```rust
pub struct Animal {
    number_of_legs: u8,
    color: String,
    sound: String,
}

impl Animal {
    pub fn talk(&self) {
        println!("{}", self.sound)
    }

    pub fn create_dog(color: String) -> Self {
        Self {
            number_of_legs: 4,
            color: color,
            sound: String::from("Woof"),
        }
    }
}
```

Here, we make the `Animal` struct public, as well as the `talk` and `create_dog` methods. Otherwise, we wouldn't be able to access them from outside this module.

Finally, we can use the newly defined module in `main.rs`:

```rust
use crate::zoo::animal::Animal;

pub mod zoo;

fn main() {
    let dog = Animal::create_dog(String::from("brown"));

    dog.talk();
}
```

If we tried to access a field from `Animal`. For example:

```rust
use crate::zoo::animal::Animal;

pub mod zoo;

fn main() {
    let dog = Animal::create_dog(String::from("brown"));
    println!("{}", dog.sound)
}
```

We would get an error:

```
error[E0616]: field `sound` of struct `Animal` is private
 --> src/main.rs:7:24
  |
7 |     println!("{}", dog.sound)
  |                        ^^^^^ private field
```

## Ownership

The way Rust manages resource ownership is probably its main selling point. At the cost of some initially unintuitive rules, it provides a safer way to manage resources.

Rust is similar to C++ in that it has the ability to create destructors that can be used to free resources when a variable goes out of scope. When we are talking about collections or structs, the destructor will be run in all of the children recursively before it's run in the parent.

A destructor can be defined for a struct like so:

```rust
impl Drop for Animal {
    fn drop(&mut self) {
        println!("Cleaning animal's poop")
    }
}
```

`drop` will be called automatically when an `Animal` goes out of scope.

To be able to call destructors safely, Rust has some strict ownership rules. Consider this code:

```rust
let s1 = String::from("hello");
let s2 = s1;

println!("{}, world!", s1);
```

It will surprisingly, return an error:

```
error[E0382]: borrow of moved value: `s1`
  --> src/main.rs:12:28
   |
9  |     let s1 = String::from("hello");
   |         -- move occurs because `s1` has type `String`, which does not implement the `Copy` trait
10 |     let s2 = s1;
   |              -- value moved here
11 |
12 |     println!("{}, world!", s1);
   |                            ^^ value borrowed here after move
```

What happens here is that String is a type of varying size that goes on the heap. This means that `s1` is actually a pointer. When we assign `s1` to `s2`, the data in the heap doesn't move, `s2` is assigned the same data as `s1` (another pointer to the data in the heap), and `s1` is invalidated. This is similar to move semantics in C++, but done automatically.

What we want to do instead is assign `s2` a reference to `s1`:

```rust
let s1 = String::from("hello");
let s2 = &s1;

println!("{}, world!", s1);
```

Or clone the string:

```rust
let s1 = String::from("hello");
let s2 = s1.clone();

println!("{}, world!", s1);
```

This default behavior becomes trickier when dealing with functions. Look at this scenario:

```rust
fn main() {
    let s1 = String::from("hello");
    print_string(s1);
    println!("{}", s1);
}

fn print_string(input: String) {
    println!("{}", input);
}
```

If we try to run it, we get this error:

```rust
error[E0382]: borrow of moved value: `s1`
 --> src/main.rs:4:20
  |
2 |     let s1 = String::from("hello");
  |         -- move occurs because `s1` has type `String`, which does not implement the `Copy` trait
3 |     print_string(s1);
  |                  -- value moved here
4 |     println!("{}", s1);
  |                    ^^ value borrowed here after move
  |
note: consider changing this parameter type in function `print_string` to borrow instead if owning the value isn't necessary
 --> src/main.rs:7:24
  |
7 | fn print_string(input: String) {
  |    ------------        ^^^^^^ this parameter takes ownership of the value
  |    |
  |    in this function
  = note: this error originates in the macro `$crate::format_args_nl` which comes from the expansion of the macro `println` (in Nightly builds, run with -Z macro-backtrace for more info)
help: consider cloning the value if the performance cost is acceptable
  |
3 |     print_string(s1.clone());
  |                    ++++++++
```

When we call `print_string`, we are moving `s1` into the function, so it's invalidated and can't be used anymore.

The right way to achieve what we intended is to use a reference instead:

```rust
fn main() {
    let s1 = String::from("hello");
    print_string(&s1);
    println!("{}", s1);
}

fn print_string(input: &String) {
    println!("{}", input);
}
```

If we want to modify a passed reference, we need to make it mutable. This example works as expected:

```rust
fn main() {
    let mut s1 = String::from("hello");
    modify_string(&mut s1);
    println!("{}", s1);
}

fn modify_string(input: &mut String) {
    input.push_str("-bye");
}
```

One thing to keep in mind about mutable references is that, when we have a mutable reference to a variable, we can't have any other reference at the same time. This will almost never be a problem for a single threaded program, but it becomes important when working with multiple threads. That's something we'll cover in more detail in another article.

## Conclusion

I've been wanting to take a look at Rust for while and I'm happy I finally got the time. At a first glance it feels to me like a mix of C++ and Golang.

Personally I prefer the way C++ and Java do Object Orientation, but it seems like Rust went with the Golang way.

Although I'm just getting started, I can see how Rust can make programming safer with the way it prevents modifications of variables by forcing the user to be explicit about their intentions.

In general, I dislike garbage collection, so I'm happy that Rust went with destructors instead.
