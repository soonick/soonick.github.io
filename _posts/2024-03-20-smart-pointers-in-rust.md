---
title: Smart Pointers in Rust
author: adrian.ancona
layout: post
date: 2024-03-20
permalink: /2024/03/smart-pointers-in-rust/
tags:
  - programming
  - rust
---

Rust is considered safe because it makes sure variable ownership is managed correctly in our code. In the most basic case, Rust enforces these rules:

- Each value in Rust has an owner.
- There can only be one owner at a time.
- When the owner goes out of scope, the value will be dropped.

The problem is that there are some scenarios where we need to break these rules. This is where smart pointers help us.

## What are smart pointers?

Smart pointers are structs that manage some internal data.

They are called pointers because they implement the [Deref trait](https://doc.rust-lang.org/std/ops/trait.Deref.html), so they can be used like pointers (Using the `&` and `*` syntax).

<!--more-->

They are called smart, because they manage the lifecycle of their internal data. This typically means, among other things, implementing the [Drop trait](https://doc.rust-lang.org/std/ops/trait.Drop.html) so resources are released correctly when the pointer goes out of scope.

## Box<T>

I've found the `Box` smart pointer to be useful to do cheap transfers of ownership.

In rust, when we transfer ownership of a variable, the whole variable is copied to a different memory location:

```rust
fn main() {
    let text = String::from("Some text");
    println!("The text is at: {:p}", &text); // This prints a memory location

    let new_text = text; // This invalidates text variable
    println!("The text is at: {:p}", &new_text); // This prints a different memory location
}
```

In the example above, the line `let new_text = text;` moves all the data from `text` to a different location. If `text` contained a very large text, moving the data could be costly.

If we use a `Box`, the move happens in constant time, since only the pointer needs to be moved:

```rust
fn box_move() {
    let b1 = Box::new(String::from("Another text"));
    println!("b1 is at {:p}, b1 points to: {:p}. The text is: {}", &b1, b1, b1);
    let b2 = b1;
    println!("b2 is at {:p}, b2 points to: {:p}. The text is: {}", &b2, b2, b2);
}
```

In the example above, the address for the boxes changes, but the address for the string remains the same.


## Rc<T>

There are scenarios where we need a variable to have multiple owners. Rc (Reference counted) smart pointers allow us to achieve this without sacrificing safety:

```rust
fn rc_pointer() {
    let pointer = Rc::new(String::from("More text"));
    // Reference count here is 1
    println!("pointer is at {:p}, pointer points to: {:p}, reference count is: {}", &pointer, pointer, Rc::strong_count(&pointer));
    {
        let pointer_clone = Rc::clone(&pointer);
        // pointer_clone is at a different address than pointer, but the underlying
        // data is at the same address. Reference count here is 2
        println!("pointer is at {:p}, pointer points to: {:p}, reference count is: {}", &pointer_clone, pointer_clone, Rc::strong_count(&pointer_clone));

        // Reference count here is 2
        println!("pointer is at {:p}, pointer points to: {:p}, reference count is: {}", &pointer, pointer, Rc::strong_count(&pointer));
    }

    // Since pointer_clone has gone out of scope, reference count was decreased to 1
    println!("pointer is at {:p}, pointer points to: {:p}, reference count is: {}", &pointer, pointer, Rc::strong_count(&pointer));
}
```

The example above shows how by cloning an `Rc` we can have multiple variables owning the same underlying data. `Rc` automatically decreases the reference count when an owner goes out of scope so resources are correctly freed when there are no more owners.

## Conclusion

Smart pointers are very easy to use and help us achieve some things that are often necessary.

Find runnable versions of the examples above in [my code samples repo](https://github.com/soonick/ncona-code-samples/tree/master/smart-pointers-in-rust).
