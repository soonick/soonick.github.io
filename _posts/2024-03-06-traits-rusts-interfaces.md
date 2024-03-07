---
title: Traits, Rust's Interfaces
author: adrian.ancona
layout: post
date: 2024-03-06
permalink: /2024/03/traits-rusts-interfaces/
tags:
  - programming
  - rust
---

As the title says, `traits` are Rust's alternative to Interfaces. They allow us to use polymorphism in Rust. We can create a trait like this:

```rust
trait Calculator {
    fn add(&self, left: i32, right: i32) -> i32;
}
```

To implement the trait we use the `impl` keyword on a struct:

```rust
struct GoodCalculator {}

impl Calculator for GoodCalculator {
    fn add(&self, left: i32, right: i32) -> i32 {
        left + right
    }
}
```

<!--more-->

Traits (like interfaces) are useful as function parameters, so different types can be passed. The simplest way to receive a trait as a parameter is using the `impl` keyword like this:

```rust
fn add_using_calculator(calculator: &impl Calculator) {
    println!("The result of adding {} and {} is: {}", 10, 5, calculator.add(10, 5));
}
```

When we need a type to implement multiple interfaces, we can use this syntax:

```rust
fn add_and_print(the_thing: &(impl Calculator + Printer)) {
    the_thing.print();
    println!("The result of adding {} and {} is: {}", 10, 5, the_thing.add(10, 5));
}
```

Another syntax:

```rust
fn add_and_print<T: Calculator + Printer>(the_thing: &T) {
    the_thing.print();
    println!("The result of adding {} and {} is: {}", 10, 5, the_thing.add(10, 5));
}
```

When we have multiple arguments using the following syntax is preferred:

```rust
fn add_and_print<T>(the_thing: &T)
where
    T: Calculator + Printer
{
    the_thing.print();
    println!("The result of adding {} and {} is: {}", 10, 5, the_thing.add(10, 5));
}
```

## Abstract methods / Default implementations

Sometimes we want to provide default implementations for some methods on our traits. This can easily be done:

```rust
trait SoundMaker {
    fn print(&self) {
        println!("Default implementation")
    }
}
```

## Conclusion

Traits in Rust, work similarly to interfaces in Golang. I added [some code using the above examples to Github](https://github.com/soonick/ncona-code-samples/tree/master/traits-rusts-interfaces) so you can see it in action.
