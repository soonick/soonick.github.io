---
title: Firestore Transactions in Rust
author: adrian.ancona
layout: post
date: 2024-12-25
permalink: /2024/12/firestore-transactions-in-rust/
tags:
  - databases
  - programming
  - rust
---

I'm working a project that uses Firestore, so I'm using the [firestore crate](https://crates.io/crates/firestore) to help me interact with my database.

There are two examples showing the use of transactions in the source code:

- [transactions.rs](https://github.com/abdolence/firestore-rs/blob/master/examples/transactions.rs)
- [read-write-transactions.rs](https://github.com/abdolence/firestore-rs/blob/master/examples/read-write-transactions.rs)

There are some parts of those examples that are a little confusing, so I'm writing this article to try and shed some light.

I was not the only one confused by this, and luckily someone brought this up in [a Github issue](https://github.com/abdolence/firestore-rs/issues/135) before I had to.

<!--more-->

## Transactions in Firestore

Firestore's transactions have a lot of limitations compared with relational databases:

- When a transaction contains reads and writes, all reads must come before any writes
- Transactions can't lock a whole collection
- Transactions don't contain locks. If a transaction fails, it will be retried a finite number of times before it fails

## Writing transactional code

To write transactional code in Rust, we use the `run_transaction` method of `FirestoreDb`:

```rust
let tx_res = main_db.run_transaction(|db, _tx| {
    ...
}
```

Any code run using `db` inside `run_transaction`, will run as a single transaction.

`db_transaction` receives a closure as an argument. This closure must return a boxed future, so it's usually called like this:

```rust
let tx_res = main_db.run_transaction(|db, _tx| {
    async move {
        ...
    }.boxed();
}
```

Here is an example of updating a user's field using a transaction:

```rust
let tx_res = main_db.run_transaction(|db, tx| {
    async move {
        // Get the user
        let found_user_opt: Option<User> = match db
            .fluent()
            .select()
            .by_id_in(COLLECTION_NAME)
            .obj()
            .one("jose")
            .await {
                Ok(f) => f,
                Err(err) => {
                    println!("Error finding user: {}", err);
                    return Ok::<bool, BackoffError<FirestoreError>>(false);
                }
            };

        if found_user_opt.is_some() {
            println!("User found");
        } else {
            println!("User not found");
            return Ok(false);
        }

        // Update a field
        let mut found_user = found_user_opt.unwrap();
        found_user.views = found_user.views + 1;

        // Write the update
        match db.fluent()
            .update()
            .in_col(COLLECTION_NAME)
            .document_id("jose".to_string())
            .object(&found_user)
            .add_to_transaction(tx) {
                Ok(_) => {},
                Err(err) => {
                    panic!("Error updating user: {}", err);
                }
            };

        return Ok(true);
    }.boxed()
}).await;
```

There are some things here that are not very intuitive. In line `25`, we can see that `add_to_transaction` is used. If we had omitted it, the code wouldn't work.

The `select` statement is part of the transaction, even when it doesn't contain a call to `add_to_transaction`.

Insert operations don't use `add_to_transaction` either, but they can use used inside a transaction:

```rust
let tx_res = main_db.run_transaction(|db, _tx| {
    async move {
        // Get the user
        let found_user_opt: Option<User> = match db
            .fluent()
            .select()
            .by_id_in(COLLECTION_NAME)
            .obj()
            .one("jose")
            .await {
                Ok(f) => f,
                Err(err) => {
                    println!("Error finding user: {}", err);
                    return Ok::<bool, BackoffError<FirestoreError>>(false);
                }
            };

        if found_user_opt.is_some() {
            println!("User found");
        } else {
            println!("User not found");
            return Ok(false);
        }

        let carlos = User {
            username: "carlos".to_string(),
            views: 0,
        };

        match db.fluent()
            .insert()
            .into(COLLECTION_NAME)
            .document_id("carlos".to_string())
            .object(&carlos)
            .execute::<()>()
            .await {
                Ok(_) => {
                    println!("Carlos inserted");
                },
                Err(err) => {
                    panic!("Error inserting carlos: {}", err);
                }
            };

        return Ok(true);
    }.boxed()
}).await;
```

This by itself makes the API confusing, but there is more.

We can't select and insert the same document in a transaction. In the following example, we try to insert a user if the username isn't already taken:

```rust
let tx_res = main_db.run_transaction(|db, _tx| {
    async move {
        // Get the user
        let found_user_opt: Option<User> = match db
            .fluent()
            .select()
            .by_id_in(COLLECTION_NAME)
            .obj()
            .one("jose")
            .await {
                Ok(f) => f,
                Err(err) => {
                    println!("Error finding user: {}", err);
                    return Ok::<bool, BackoffError<FirestoreError>>(false);
                }
            };

        if found_user_opt.is_some() {
            println!("User found");
            return Ok(false);
        } else {
            println!("User not found");
        }

        let jose = User {
            username: "jose".to_string(),
            views: 0,
        };

        match db.fluent()
            .insert()
            .into(COLLECTION_NAME)
            .document_id("jose".to_string())
            .object(&jose)
            .execute::<()>()
            .await {
                Ok(_) => {
                    println!("Jose inserted");
                },
                Err(err) => {
                    panic!("Error inserting jose: {}", err);
                }
            };

        return Ok(true);
    }.boxed()
}).await;
```

This code fails with this confusing error message:

```
Database general error occurred: Error code: Aborted. status: Aborted, message: "Transaction lock timeout.",
```

The error doesn't explain anything. The reality is that selecting and then inserting a document in the same transaction is just not allowed at the time.

## Conclusion

Firestore is a cheap storage option, but it comes with some challenges. Some of those are mentioned in this article.

Furthermore, the firestore crate uses an API that seems inconsistent. This is probably a reflection of the limitations of the Firestore API itself, but makes adoption a little challenging.

As usual, you can find complete versions of the code in this article in [my examples' repo](https://github.com/soonick/ncona-code-samples/tree/master/firestore-transactions-in-rust).
