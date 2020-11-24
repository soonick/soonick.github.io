---
title: Running Google Firestore locally
author: adrian.ancona
layout: post
date: 2020-12-09
permalink: /2020/12/running-google-firestore-locally/
tags:
  - automation
  - databases
  - gcp
  - golang
---

In a previous article, [we started playing with Google Firestore](/2020/12/introduction-to-google-firestore/). In this article we are going to learn how we can test our applications without the need to talk to Google Cloud.

Note that the local version of Google Firestore is intended for testing only and shouldn't be used for production systems. It doesn't provide the reliability or scalability features that the real Firestore does.

## Firebase emulator suite

Google provides this suite to help developers test applications without having to use production data or incur cost. The suite doesn't only emulate the database, but also cloud functions and real-time functionality, to name a couple. In this article we're only going to focus on the Firestore database.

<!--more-->

## Firebase CLI

We start by installing the [Firebase CLI](https://firebase.google.com/docs/cli):

```
curl -sL https://firebase.tools | bash
```

We can then start an instance of Firestore:

```
firebase emulators:start --only firestore
```

As part of the output we will get something like this:

```
┌───────────┬────────────────┐
│ Emulator  │ Host:Port      │
├───────────┼────────────────┤
│ Firestore │ localhost:8080 │
└───────────┴────────────────┘
```

Port `8080` is the default for Firestore. When the emulator starts it will look for a file named `firebase.json` where we can override the port:

```json
{
  "emulators": {
    "firestore": {
      "port": "9999"
    }
  }
}
```

One important thing to keep in mind about the emulator is that the data will be lost every time the emulator is stoped.

## Connecting to the emulator

In [Introduction to Google Firestore](/2020/12/introduction-to-google-firestore/) we learned how to create a firestore client:

```go
// Constants necessary to create the firestore client
const GcpCredentialsFile = "/tmp/my-key.json"
const ProjectId = "project-12345"

// When done with the client, close it using:
// defer client.Close()
func createClient(ctx context.Context) *firestore.Client {
  client, err := firestore.NewClient(ctx, ProjectId, option.WithCredentialsFile(GcpCredentialsFile))

  if err != nil {
    log.Fatalf("Failed to create client: %v", err)
  }

  return client
}
```

To tell our app that we want to use the emulator, we need to set an environment variable:

```bash
export FIRESTORE_EMULATOR_HOST=localhost:8080
```

This will cause the credentials to be ignored, and the client will connect to the emulator instead.

## Conclusion

This was a quick article to show how we can easily start a local version of Google Firestore that can be used for testing. The emulator provides a lot of advanced features, but I haven't had the need for them, so I haven't dived into them.
