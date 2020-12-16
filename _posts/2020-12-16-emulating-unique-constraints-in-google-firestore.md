---
title: Emulating Unique Constraints in Google Firestore
author: adrian.ancona
layout: post
date: 2020-12-16
permalink: /2020/12/emulating-unique-constraints-in-google-firestore/
tags:
  - databases
  - gcp
  - golang
---

Compared to most popular databases, Google Firestore is very minimalistic.

A very important feature that it lacks, is that of unique constraints (unique indexes). This feature is particularly important when we are building a system that allows users to pick a `username`. If we don't enforce uniqueness we could end with two users with the same `username`, which is not what we want.

## Using Document ID and transactions

If we are able to use the `username` as the user id, then things are a little easier. We can follow these steps to create a new user (wrapped in a transaction):

- Get user by ID (username)
- If it exists, user is taken, return an error
- If it doesn't exist, add it

Before we proceed with this solution, there are a few things that are important to know about transactions in firestore:

<!--more-->

- Reads before writes - We must perform all reads before any write
- Only queries by ID - We can only get documents by ID in a transactions. We can't lock a whole table by doing a query
- Optimistic concurrency - Steps are performed without locks. Before committing, Firestore checks if any of the resources involved in the transaction have changed. If they have, it starts over, if they haven't, it commits all changes atomically.

Let's see what would happen if we don't use a transaction and a user tries to pick a `username` that has already been taken:

```go
package main

import (
  "context"
  "errors"
  "log"

  "cloud.google.com/go/firestore"
  "google.golang.org/api/option"
  "google.golang.org/grpc/codes"
  "google.golang.org/grpc/status"
)

// Constants necessary to create the firestore client
const GcpCredentialsFile = "/tmp/key.json"
const ProjectId = "project-1234"

// When done with the client close it using:
// defer client.Close()
func createClient(ctx context.Context) *firestore.Client {
  client, err := firestore.NewClient(ctx, ProjectId, option.WithCredentialsFile(GcpCredentialsFile))

  if err != nil {
    log.Fatalf("Failed to create client: %v", err)
  }

  return client
}

func saveUser(username string) error {
  ctx := context.Background()

  client := createClient(ctx)
  defer client.Close()

  _, err := client.Collection("users").Doc(username).Get(ctx)
  if err == nil {
    log.Printf("User %s already taken", username)
    return errors.New("DuplicateEntry")
  }

  if err != nil && status.Code(err) != codes.NotFound {
    log.Printf("Error retrieving data from DB. %v", err)
    return err
  }

  _, err = client.Collection("users").Doc(username).Set(ctx, map[string]interface{}{
    "username": username,
  })

  return err
}

func main() {
  // Sequential:
  // Try to save user and then we try to save another user with the same name.
  // In this case there is no problem since we will notice the user is already
  // taken
  username := "carlos"
  err := saveUser(username)
  if err != nil {
    log.Printf("This won't happen since its the first time we create the user")
    return
  } else {
    log.Printf("%s saved successfully", username)
  }

  err = saveUser(username)
  if err != nil {
    log.Printf("User not saved because it already exists. %v", err)
  }
}
```

In this case things work well because we check if the user exists before we try to save it.

Let's now see what happens if the two users try to pick the same `username` at the same time:

```go
package main

import (
  "context"
  "errors"
  "log"
  "time"

  "cloud.google.com/go/firestore"
  "google.golang.org/api/option"
  "google.golang.org/grpc/codes"
  "google.golang.org/grpc/status"
)

// Constants necessary to create the firestore client
const GcpCredentialsFile = "/tmp/key.json"
const ProjectId = "project-1234"

// When done with the client close it using:
// defer client.Close()
func createClient(ctx context.Context) *firestore.Client {
  client, err := firestore.NewClient(ctx, ProjectId, option.WithCredentialsFile(GcpCredentialsFile))

  if err != nil {
    log.Fatalf("Failed to create client: %v", err)
  }

  return client
}

func saveUser(username string) <- chan error {
  errorChannel := make(chan error)

  go func() {
    ctx := context.Background()
    client := createClient(ctx)
    defer client.Close()


    _, err := client.Collection("users").Doc(username).Get(ctx)
    if err == nil {
      log.Printf("User %s already taken", username)
      errorChannel <- errors.New("DuplicateEntry")
      return
    }

    // Inject a delay here to show the race condition
    time.Sleep(200 * time.Millisecond)

    if err != nil && status.Code(err) != codes.NotFound {
      log.Printf("Error retrieving data from DB. %v", err)
      errorChannel <- err
      return
    }

    _, err = client.Collection("users").Doc(username).Set(ctx, map[string]interface{}{
      "username": username,
    })

    errorChannel <- err
  }()

  return errorChannel
}

func main() {
  // Concurrent:
  // Try to save user and then we try to save another user concurrently.
  // Since none of the threads see the existing user, they both try to save a new
  // user. Both users think they got the username, but only one actually got it
  username := "carlos"
  errorChannel1 := saveUser(username)
  errorChannel2 := saveUser(username)
  err1 := <- errorChannel1
  err2 := <- errorChannel2

  if err1 == nil && err2 == nil {
    // This is a race condition
    log.Printf("Seems like everything went well, but only one of them was actually saved")
  } else {
    log.Printf("User already existed")
  }
}
```

In the case above, we have a problem. One of the users thinks they got the username they selected, but they didn't.

We can use transactions to prevent this problem:

```go
package main

import (
  "context"
  "errors"
  "log"
  "time"

  "cloud.google.com/go/firestore"
  "google.golang.org/api/option"
  "google.golang.org/grpc/codes"
  "google.golang.org/grpc/status"
)

// Constants necessary to create the firestore client
const GcpCredentialsFile = "/tmp/key.json"
const ProjectId = "project-1234"

// When done with the client close it using:
// defer client.Close()
func createClient(ctx context.Context) *firestore.Client {
  client, err := firestore.NewClient(ctx, ProjectId, option.WithCredentialsFile(GcpCredentialsFile))

  if err != nil {
    log.Fatalf("Failed to create client: %v", err)
  }

  return client
}

func saveUser(username string) <- chan error {
  errorChannel := make(chan error)

  go func() {
    ctx := context.Background()
    client := createClient(ctx)
    defer client.Close()

    ref := client.Collection("users").Doc(username)
    // We use RunTransaction to start a transaction
    txError := client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
      _, err := tx.Get(ref) // Get inside a transaction
      if err == nil {
        log.Printf("User %s already taken", username)
        return errors.New("DuplicateEntry")
      }

      if err != nil && status.Code(err) != codes.NotFound {
        log.Printf("Error retrieving data from DB. %v", err)
        return err
      }

      // Inject a delay. Even when this delay, the race condition will be prevented
      // by the transactions. There will be a clear winner
      time.Sleep(200 * time.Millisecond)

      return tx.Set(ref, map[string]interface{}{ // Set inside a transaction
        "username": username,
      })
    })

    errorChannel <- txError
  }()

  return errorChannel
}

func main() {
  // Concurrent:
  // Try to save user and then we try to save another user concurrently.
  // One of the threads will see that there is no user and try to save, but
  // because it detects that there was a change in the data, it will fail
  username := "carlos"
  errorChannel1 := saveUser(username)
  errorChannel2 := saveUser(username)
  err1 := <- errorChannel1
  err2 := <- errorChannel2

  if err1 == nil {
    log.Printf("Thread 1 saved the user")
  } else {
    log.Printf("Thread 1 failed to saved the user. %v", err1)
  }

  if err2 == nil {
    log.Printf("Thread 2 saved the user")
  } else {
    log.Printf("Thread 2 failed to saved the user. %v", err2)
  }
}
```

The example above shows how to avoid a conflict between 2 users trying to pick the same `username`. Let's now see the slightly more complicated scenario where we can't use the `username` as Document ID.

## Using transactions without relying on Document ID

There are some scenarios where we don't want to (or can't) use the `username` as Document ID. I stumbled into this scenario in a system that uses Open ID for sign in. In that case, the system uses the Open ID user identifier as the Document ID. The `username` is just a field in the document.

Even though the title of the section mentions not relying on Document ID, this is a small lie. We are going to use a Document ID, but we are going to create a different collection for this.

We will have our main `users` collection where we will use a random ID as Document ID, but we are going to create another collection named `users-usernames` where we will store the `username` and use a similar technique to the one in the previous section.

Since we already showed the race condition in the previous section, we are just going to see the solution here:

```go
package main

import (
  "context"
  "errors"
  "log"
  "os/exec"
  "time"

  "cloud.google.com/go/firestore"
  "google.golang.org/api/option"
  "google.golang.org/grpc/codes"
  "google.golang.org/grpc/status"
)

// Constants necessary to create the firestore client
const GcpCredentialsFile = "/tmp/key.json"
const ProjectId = "project-1234"

// When done with the client close it using:
// defer client.Close()
func createClient(ctx context.Context) *firestore.Client {
  client, err := firestore.NewClient(ctx, ProjectId, option.WithCredentialsFile(GcpCredentialsFile))

  if err != nil {
    log.Fatalf("Failed to create client: %v", err)
  }

  return client
}

func saveUser(username string) <- chan error {
  errorChannel := make(chan error)

  go func() {
    ctx := context.Background()
    client := createClient(ctx)
    defer client.Close()

    // Generate a UUID (Only works on linux)
    uuidByteArray, err := exec.Command("uuidgen").Output()
    if err != nil {
      log.Printf("Error generating UUID. %v", err)
      errorChannel <- err
      return
    }

    uuid := string(uuidByteArray)

    ref := client.Collection("users-usernames").Doc(username)
    userRef := client.Collection("users").Doc(uuid)
    // We use RunTransaction to start a transaction
    txError := client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
      // First check if the username is taken
      _, err := tx.Get(ref)
      if err == nil {
        log.Printf("User %s already taken", username)
        return errors.New("DuplicateEntry")
      }

      if err != nil && status.Code(err) != codes.NotFound {
        log.Printf("Error retrieving data from DB. %v", err)
        return err
      }

      // Inject a delay. Even when this delay, the race condition will be prevented
      // by the transactions. There will be a clear winner
      time.Sleep(200 * time.Millisecond)



      // If the user is not taken, we create it
      err = tx.Set(ref, map[string]interface{}{
        // Save the user id so we know who got the username
        "user-id": uuid,
      })
      if err != nil {
        log.Printf("Error saving into `user-usernames`. %v", err)
        return err
      }

      // Finally, save the `user`
      return tx.Set(userRef, map[string]interface{}{
        // Save the username here
        "username": username,
      })
    })

    errorChannel <- txError
  }()

  return errorChannel
}

func main() {
  // Concurrent:
  // Try to save user and then we try to save another user concurrently.
  // One of the threads will see that there is no user and try to save, but
  // because it detects that there was a change in the data, it will fail
  username := "carlos"
  errorChannel1 := saveUser(username)
  errorChannel2 := saveUser(username)
  err1 := <- errorChannel1
  err2 := <- errorChannel2

  if err1 == nil {
    log.Printf("Thread 1 saved the user")
  } else {
    log.Printf("Thread 1 failed to saved the user. %v", err1)
  }

  if err2 == nil {
    log.Printf("Thread 2 saved the user")
  } else {
    log.Printf("Thread 2 failed to saved the user. %v", err2)
  }
}
```

## Conclusion

Although it is possible to write code to overcome the lack of unique indexes in Google Firestore, the code ends up being a lot more complicated than the SQL equivalent. While we wait for the feature to be supported, we have to resource to tricks like these.


