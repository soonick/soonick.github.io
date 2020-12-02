---
title: Introduction to Google Firestore
author: adrian.ancona
layout: post
date: 2020-12-02
permalink: /2020/12/introduction-to-google-firestore/
tags:
  - architecture
  - databases
  - gcp
  - golang
---

Firestore is Google's serverless document database offering.

## What does serverless mean?

Serverless means that we don't have to worry about managing the servers on which the database runs. All the management is done automatically by Google. The database will scale up or down depending on the demand.

## What's a document database?

A document database is a non-relational database that stores data in a semi-structured format. A common format used by many document databases is JSON.

In a relational database, we usually create tables with a defined structure (columns and types). In a document database, it's not necessary to specify the different columns.

<!--more-->

## Concepts

There are two concepts we need to be familiar with to model our Firestore database: `documents` and `collections`.

A `document` is similar to a JSON object. Each top level attribute is called a `field`. A document can't be bigger than 1MB.

A `collection` is a group of documents. We can think of it as a table without a schema, just a name.

A `document` can point to a `collection`, and `documents` in that `collection` can point to other `collections`.

## Creating a database

When we talk about creating a database, we are referring to making it possible to create `collections` and `documents` in Google Cloud. At the time of this writing, Firestore databases come in 2 flavors:

- `Native mode` - Recommended for mobile apps or browsers
- `Datastore mode` - Recommended for back-end servers

Currently there is no way to create a database in `datastore mode` using `gcloud` cli, so we need to do it from the cloud console. If we want to create a database in native mode we can use:

```
gcloud firestore databases create
```

This command triggers some initial setup that might take a few minutes.

Once we choose the mode for a Google Cloud project, it can't be changed. If we want to change it, we would need to create a new project and create another database there.

## Writing data

In relational databases we need to define our tables and schemas in advance. That's not the case on Firebase. Documents are created in collections. If a collection doesn't exist, it will be created on the fly.

Clients exist for various programming languages. We're going to use Golang in this article.

```sh
mkdir ~/project
cd ~/project
go mod init ncona.com/firestore
touch main.go
```

Let's write some data (`main.go`):

```go
package main

import (
  "log"
  "context"

  "cloud.google.com/go/firestore"
  "google.golang.org/api/option"
)

// Constants necessary to create the firestore client
const GcpCredentialsFile = "/tmp/my-key.json"
const ProjectId = "project-12345"

// When done with the client close it using:
// defer client.Close()
func createClient(ctx context.Context) *firestore.Client {
  client, err := firestore.NewClient(ctx, ProjectId, option.WithCredentialsFile(GcpCredentialsFile))

  if err != nil {
    log.Fatalf("Failed to create client: %v", err)
  }

  return client
}

func main() {
  ctx := context.Background()

  client := createClient(ctx)
  defer client.Close()

  _, err := client.Collection("tacos").Doc("1").Set(ctx, map[string]interface{}{
    "tortilla": "wheat",
    "meat": "pork",
    "salsa": "green",
  })
  if err != nil {
    log.Printf("Error updating data: %s", err)
  }
}
```

Note that `GcpCredentialsFile` must be a valid service account key with permissions for Firestore (roles/datastore.user), and `ProjectId` should be the id of the project where the database lives.

We can run our program with:

```
go run main.go
```

The `Set` operation creates a new record or replaces an existing one. The `Doc("1")` part of the command tells firestore to use `1` as a document identifier. There can't be two documents with the same identifier in a collection.

It's also possible to tell firestore to `merge` an existing document instead of replacing it:

```go
_, err := client.Collection("tacos").Doc("1").Set(ctx, map[string]interface{}{
  "price": "2"
}, firestore.MergeAll)
```

Each document we write is represented by a path. For the document we just created, this will be the path:

```
/tacos/1
```

## Retrieving data

Now that we have some data, let's try reading it. Let's create a new file:

```
touch read.go
```

With this content:

```go
package main

import (
  "context"
  "fmt"
  "log"

  "cloud.google.com/go/firestore"
  "google.golang.org/api/iterator"
  "google.golang.org/api/option"
)


// Constants necessary to create the firestore client
const GcpCredentialsFile = "/tmp/my-key.json"
const ProjectId = "project-12345"

// When done with the client close it using:
// defer client.Close()
func createClient(ctx context.Context) *firestore.Client {
  client, err := firestore.NewClient(ctx, ProjectId, option.WithCredentialsFile(GcpCredentialsFile))

  if err != nil {
    log.Fatalf("Failed to create client: %v", err)
  }

  return client
}

func main() {
  ctx := context.Background()

  client := createClient(ctx)
  defer client.Close()

  iter := client.Collection("tacos").Documents(ctx)
  for {
    doc, err := iter.Next()

    // We are done iterating. Break
    if err == iterator.Done {
      break
    }

    if err != nil {
      log.Fatalf("Failed to iterate: %v", err)
    }
    fmt.Println(doc.Data())
  }
}
```

We can run this program with:

```
go run read.go
```

And the output will be something like:

```
map[meat:pork salsa:red tortilla:corn]
```

The `Documents` command retrieves all the documents in the collection. This is most likely not what we want to do in most cases.

To get a single document se can use this code:

```go
ref, err := client.Collection("tacos").Doc("1").Get(ctx)

if err != nil {
  log.Print("Taco not found")
  return
}
fmt.Println(ref.Data())
```

To query for documents matching a criteria:

```go
func main() {
  ctx := context.Background()

  client := createClient(ctx)
  defer client.Close()

  iter := client.Collection("tacos").Where("meat", "==", "pork").Documents(ctx)
  for {
    doc, err := iter.Next()
    if err == iterator.Done {
      break
    }

    if err != nil {
      return
    }

    fmt.Println(doc.Data())
  }
}
```

In the example above, we used `==`, but we can also use:

- `<`
- `<=`
- `>`
- `>=`
- `!=`
- `array-contains`
- `array-contains-any`
- `in`
- `not-in`

It's also possible to use `limit` to specify how many documents to return:

```go
iter := client.Collection("tacos").Where("meat", "==", "pork").Limit(2).Documents(ctx)
```

## Indexes

A very brief note about indexes, because they work differently than in other databases. There are two types of indexes in firestore, `single-field indexes` and `composite indexes`.

As the name suggests, `single-field indexes` are indexes made of a single field. Firestore automatically creates `single-field indexes` for all the fields in a document, so we don't have to worry about creating these ourselves.

As opposed to `single-field indexes`, `composite indexes` are not created automatically. These are indexes formed by more than one field and need to be defined before they can be used.

# Conclusion

This article scratched the surface of what can be done with `Firestore`. There are many things about querying that I didn't cover, as well as other interesting topics like transactions and arrays. I'm planning on using it in a project, so hopefully I'll be writing about these topics in the future.
