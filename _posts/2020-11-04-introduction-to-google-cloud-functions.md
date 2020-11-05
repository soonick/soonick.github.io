---
title: Introduction to Google Cloud Functions
author: adrian.ancona
layout: post
date: 2020-11-04
permalink: /2020/11/introduction-to-google-cloud-functions/
tags:
  - architecture
  - gcp
  - programming
---

Cloud Functions are Google's offering for serverless architecture (similar to AWS lambdas).

## What is serverless?

Before we look into how to use Cloud Functions, we should understand some things about it.

Code needs servers to run, so `serverless` doesn't mean there are no servers, it means that we don't need to manage those servers ourselves.

In a usual server based architecture, we might create a service and deploy it to a machine. This service will be running in the machine all the time waiting for requests. This has the disadvantage that even if there are no requests, the machine would need to be up, and incurring cost.

On the other hand, if we use Cloud Functions, we write a service and register it with Google. Google will then listen to the endpoint this service cares about and will only start it when there are requests. If it detects that there haven't been requests for some time, it will stop the service again.

<!--more-->

While Google Compute Engine instances are billed by time, Cloud Functions are billed by execution time. If a Cloud Function is not being executed, then it is not being billed. This sounds very attractive, but there are draw backs, namely:

- Running a Compute Engine instance for a full month is most of the time cheaper than having a Cloud Function executing for one month straight. This means that if we need a service to be always doing work, it's better to get a whole machine for it.
- Cloud Functions need to warm up. If a Cloud Function hasn't been used for a while, Google will stop the server that was running it. Next time we get a new request, a new server needs to be started, which takes some time. This will make this first request take long (This time varies a lot, but usually less than 4 seconds)

For these reasons, serverless shouldn't be used in all scenarios.

## Creating a Cloud Function

To make it easy to work on our Cloud Function, we need a way to run the function from our development machine.

Let's start by creating a module:

```
mkdir test-functions
cd test-functions
go mod init test.com/functions
```

Now, we can create a file for our function:

```
touch tacos.go
```

With this content:

```go
package functions

import (
	"net/http"
	"fmt"
)

func DoYouLikeTacos(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Of course I like tacos!\n")
}
```

To be able to test our functions from our development machine, we need to create a server. Let's create a file for it:

```
mkdir cmd
touch cmd/main.go
```

And add this content:

```go
package main

import (
  "log"
  "context"
  "github.com/GoogleCloudPlatform/functions-framework-go/funcframework"
  "test.com/functions"
)

func main() {
  ctx := context.Background()

  // Our function will be executed when a request to /do-you-like-tacos is received
  if err := funcframework.RegisterHTTPFunctionContext(
      ctx, "/do-you-like-tacos", functions.DoYouLikeTacos); err != nil {
    log.Fatalf("funcframework.RegisterHTTPFunctionContext: %v\n", err)
  }

  // The server will run on port 8080
  port := "8080"
  if err := funcframework.Start(port); err != nil {
    log.Fatalf("funcframework.Start: %v\n", err)
  }
}
```

To run the server:

```
cd cmd
go run main.go
```

Once the server is running, we can use curl to test it:

```
curl localhost:8080/do-you-like-tacos
```

The output should be:

```
Of course I like tacos!
```

This example is very simple, but we can have our fucntion do whatever we want.

We can also add more functions by adding more files and updating our `main.go` server. Let's create another function just to show it.

```
cd ..
touch cerveza.go
```

With this content:

```go
package functions

import (
	"net/http"
	"fmt"
)

func Thirsty(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Cerveza, por favor\n")
}
```

And add this to `cmd/main.go`:

```go
  if err := funcframework.RegisterHTTPFunctionContext(
      ctx, "/thirsty", functions.Thirsty); err != nil {
    log.Fatalf("funcframework.RegisterHTTPFunctionContext: %v\n", err)
  }
```

Run the server:

```
cd cmd
go run main.go
```

And hit the new url:

```
curl localhost:8080/thirsty
```

## Deploying to Google Cloud

Once we have our functions ready, we want to make them available to the public by deploying them to Google Cloud.

From the root of our project we can use this command:

```
gcloud functions deploy DoYouLikeTacos \
    --runtime go113 --trigger-http --allow-unauthenticated
```

This will spit out a bunch of information. The most important part is the URL:

```
httpsTrigger:
  url: https://us-central1-proj-1234567.cloudfunctions.net/DoYouLikeTacos
```

We can curl this endpoint, the same way we did for our local endpoint:

```
curl https://us-central1-proj-1234567.cloudfunctions.net/DoYouLikeTacos
```

Let's take a closer look to the command we used to deploy our function:

```
gcloud functions deploy DoYouLikeTacos \
    --runtime go113 --trigger-http --allow-unauthenticated
```

- `DoYouLikeTacos` is the name of the function we are deploying. The tool will search the package for a function with that name.
- `--runtime go113` tells google to use Golang 1.13. We can see the available runtimes in the help (`gcloud functions deploy --help`)
- `--trigger-http` means that an http endpoint will be assigned to the function
- `--allow-unauthenticated` means that the function will be available for everybody without authentication. Note that the function code itself could expect some kind of authentication independently of this flag

## Conclusion

This was a quick introduction to Google Cloud Functions. We learned how to create a function, test it locally and deploy it to Google Cloud.

Complete applications can be built using Cloud Functions, so I'll explore a little more in another article.
