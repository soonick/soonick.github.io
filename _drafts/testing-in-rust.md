---
title: Testing in Rust
author: adrian.ancona
layout: post
# date: 2019-01-30
# permalink: /2019/02/introduction-to-rust/
tags:
  - programming
  - rust
  - testing
---

In this article, we are going to learn how to write and run tests for Rust.

## Unit tests

Rust made the interesting decision that unit tests should be written in the same files as the code under test. Let's imagine we have a module with a function named `add`:

```rust
pub fn add(left: i64, right: i64) -> i64 {
    left + right
}
```

If we want to test that function, we would modify the file to look like this:

<!--more-->

```rust
pub fn add(left: i64, right: i64) -> i64 {
    left + right
}

#[cfg(test)]
mod tests {
    use super::{
        add
    };

    #[test]
    fn first_test() {
        let result = add(2, 2);
        assert!(result == 4);
    }
}
```

The `#[cfg(test)]` parameter tells the compiler to only compile that code when we are running tests. The `#[test]` parameter is used to specify a function as being a test.

We can run our tests using `cargo`:

```bash
cargo test

    Finished test [unoptimized + debuginfo] target(s) in 0.01s
     Running unittests src/lib.rs (target/debug/deps/testing-d359a3188418919d)

running 1 test
test tests::first_test ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests testing

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

We can see in the example above, the use of `assert!`. This is a macro that panics if the passed argument is false. Currently, there are three native assertions in Rust: `assert`, `assert_eq`, `assert_ne`. Here are some examples:


```rust
pub fn add(left: i64, right: i64) -> i64 {
    left + right
}

#[cfg(test)]
mod tests {
    use super::{
        add
    };

    #[test]
    fn first_test() {
        let result = add(2, 2);
        assert!(result == 4);
    }

    #[test]
    fn assert_eq() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }

    #[test]
    fn assert_ne() {
        let result = add(2, 2);
        assert_ne!(result, 3);
    }
}
```

Assertions can contain custom messages to make it easier to understand what the problem is. For example:

```rust
#[test]
fn assert_with_message() {
    let result = add(2, 2);
    assert!(result == 4, "Expected 4, actual value was {}", result);
}
```

Another thing worth noting is that, since we are writing tests within the module, it's possible to access private members. For example:

```rust
pub fn add(left: i64, right: i64) -> i64 {
    private_add(left, right)
}

fn private_add(left: i64, right: i64) -> i64 {
    left + right
}

#[cfg(test)]
mod tests {
    use super::{
        private_add
    };

    #[test]
    fn test_private_fn() {
        let result = private_add(2, 2);
        assert_eq!(result, 4);
    }
}
```

Sometimes we want to test that our code panics given certain conditions. We can test that with `should_panic`. For example:

```rust
pub fn divide(left: i64, right: i64) -> i64 {
    left / right
}

#[cfg(test)]
mod tests {
    use super::{
        divide
    };

    #[test]
    #[should_panic]
    fn test_panic() {
        divide(2, 0);
    }

    #[test]
    #[should_panic(expected="divide by zero")]
    fn test_panic_with_message_matching() {
        divide(2, 0);
    }
}
```

In the second example we specified the `divide by zero` message. In this case, the test will pass if the panic message contains the given string.

If for some reason, we want to ignore a test (maybe it's flaky and we don't want to block all builds while we fix it), we can use the `#[ignore]` parameter. For example:

```rust
    #[test]
    #[ignore]
    fn ignored_failing_test_with_message() {
        let result = add(2, 2);
        assert_eq!(result, 3, "Expected 3, actual value was {}", result);
    }
```

If we are troubleshooting a specific test, we can filter the tests we want to run by specifying a string to match against the name of the test. For example:

```bash
cargo test test_private_fn
```

## Doc Tests

Rust has a nice feature, where it automatically runs code that is defined using `///` comments. This has the benefit that if our code changes and the examples in our comments are not valid anymore, we will be alerted about it.

An example of how to write doc tests:

```rust
/// Divides the first number by the second number. Panics if second number is 0
///
/// # Example
///
/// ```
/// assert_eq!(2, testing::divide(8, 4));
/// ```
pub fn divide(left: i64, right: i64) -> i64 {
    left / right
}
```

The output of running `cargo test` will look something like this:

```bash
   Doc-tests testing

running 1 test
test src/lib.rs - divide (line 5) ... ok
```

## Integration tests

When we want to write tests that spawn multiple functions, files, or modules, we can create integration tests. Integration tests live in a `tests` folder at the same level of the `src` folder:

```
project_folder
├── Cargo.lock
├── Cargo.toml
├── src
│   └── main.rs
└── tests
    └── some_test.rs
```

When we run `cargo test`, cargo will automatically run all tests inside the `tests` folder.

Since all code under the `tests` folder is a test, we don't need to use `#[cfg(test)]`. An example integration test looks like this:

```rust
use testing;

#[test]
fn integration_test() {
    let result = testing::add(2, 2);
    assert_eq!(result, 4);
}
```

## Mocking with Mockall

Mocking is a commonly used tool when writing tests. In Rust, the most popular tool for doing this is [Mockall](https://docs.rs/mockall/latest/mockall/).

The simplest way to use it, is applying the `#[automock]` parameter to a trait. After doing this, a mock named `Mock<Name of the trait>` will be made available. With the mock we can do things like expect a method to be called or return a specified value when calling a function. An example usage:

```rust
use mockall::{
    automock,
};

#[automock]
trait Calculator {
    fn add(&self, left: i64, right: i64) -> i64;
    fn subtract(&self, left: i64, right: i64) -> i64;
}

#[cfg(test)]
mod tests {
    use super::{
        Calculator,
        MockCalculator,
    };
    use mockall::predicate::eq;

    #[test]
    fn test_mock_expectations_are_met() {
        let mut mock = MockCalculator::new();
        mock.expect_add()
            .with(eq(1), eq(2))
            .return_const(3);

        assert_eq!(mock.add(1, 2), 3);
    }
}
```

For scenarios where we need a mock that implements multiple traits, we can use the `mock!` macro. For example:

```rust
use mockall::{
    mock
};

trait Calculator {
    fn add(&self, left: i64, right: i64) -> i64;
    fn subtract(&self, left: i64, right: i64) -> i64;
}

trait Beeper {
    fn beep(&self);
}

mock! {
    BeeperCalculator {}

    impl Calculator for BeeperCalculator {
        fn add(&self, left: i64, right: i64) -> i64;
        fn subtract(&self, left: i64, right: i64) -> i64;
    }

    impl Beeper for BeeperCalculator {
        fn beep(&self);
    }
}

#[cfg(test)]
mod tests {
    use super::{
        Beeper,
        Calculator,
        MockBeeperCalculator,
    };

    #[test]
    fn test_mock_multiple_traits() {
        let mut mock = MockBeeperCalculator::new();
        mock.expect_add().return_const(3);
        mock.expect_beep().return_const(());

        mock.add(1, 2);
        mock.beep();
    }
}
```

## Conclusion

I think test code living in the same file as the code it's testing is not great, because it can make it harder to navigate code files. Most likely Rust chose that standard because it makes tests more visible.

You can find a runnable version of the examples in this article in [my examples repo in github](https://github.com/soonick/ncona-code-samples/tree/master/testing-in-rust).
