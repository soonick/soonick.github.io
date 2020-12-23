---
title: Introduction to Google App Engine
author: adrian.ancona
layout: post
date: 2020-12-23
permalink: /2020/12/introduction-to-google-app-engine
tags:
  - architecture
  - gcp
  - programming
  - projects
---

In a previous article I wrote about [Google Cloud Functions](/2020/11/introduction-to-google-cloud-functions/). They are good for single purpose endpoints, but if we want to run a full application without having to manage our infrastructure, [App Engine](https://cloud.google.com/appengine) is a better option.

App Engine natively supports some of the most popular programming languages (e.g. Java, Python, Go, ...), but also allows us to use any other programming language by supporting docker containers.

## Standard and flexible environments

App Engine offers two environment types. There is good documentation explaining [the difference betweent Standard and Flexible](https://cloud.google.com/appengine/docs/the-appengine-environments), so I'm just going to summarize what I think are the most important points:

<!--more-->

**Standard**

- Specific programming languages and versions
- Starts up in seconds
- No SSH access
- Scales down to 0 instances
- Pricing based on instance hours

**Flexible**

- Can use any programming language (Through Docker)
- Starts up in minutes
- Minimum 1 instance running
- Pricing based on CPU, memory and disk

## Getting started with standard environment

Google has a fleet of containers running the different supported environments. When Google sees a request for our application, it will copy our application to one of the available cointainers and forward the request to that container.

We will use [gcloud](/2020/09/introduction-to-google-cloud-cli/) to create a new App Engine app:

```
gcloud app create --project=[PROJECT_ID]
```

We will also need the `app-engine-go` component for this example, since we will be using `Golang`:

```
gcloud components install app-engine-go
```

We can now start a project:

```
mkdir ~/app-engine-example
cd ~/app-engine-example
go mod init app-engine-example.com/main
touch main.go
```

Add this to `main.go`:

```go
package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", indexHandler)

	port := "8080"
	log.Printf("Listening on port %s", port)

	if err := http.ListenAndServe(":" + port, nil); err != nil {
		log.Fatal(err)
	}
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	fmt.Fprint(w, "Cerveza, por favor")
}
```

We can now run the server:

```
go run main.go
```

If we hit `localhost:8080` we will get a response:

```
curl localhost:8080
```

Now that we know our app is working, we need to create an `app.yaml` file:

```
touch app.yaml
```

This file configures the runtime. Add this to the file:

```yaml
runtime: go114
```

We can now deploy the app:

```
gcloud app deploy
```

As part of the output we will get a target url that we can use to access our app.

## Getting started with flexible environment

As mentioned before, a flexible environment allows us to deploy a docker container to App Engine.

If we haven't already, we'll need to create an App Engine app:

```
gcloud app create --project=[PROJECT_ID]
```

Let's start building our application:

```sh
mkdir ~/flexible-env
cd ~/flexible-env
touch Dockerfile
```

It doesn't really matter what is inside the docker container, but I'll use nginx for my example since it's easy to set up. Let's start with our `Dockerfile`:

```docker
FROM nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY www /usr/share/nginx/html
```

We need our container to listen on port `8080`, so we need to configure Nginx to do that. Our `nginx.conf` file will look like this:

```js
events {}
http {
  server {
    listen 8080;

    location / {
      root /usr/share/nginx/html;
    }
  }
}
```

In the `Dockerfile` we specify that our static files are going to live in `www`. Let's create a file:

```
mkdir www
touch www/index.html
```

And let's add some content to `www/index.html`:

```
Un taco
```

We can test our app with docker:

```sh
docker build -t flexible-env .
docker run --name flexible-env-container -d -p 8080:8080 flexible-env
```

To test it:

```sh
curl http://localhost:8080/
```

If everything is working well, we can deploy our app. Let's create our `app.yaml`:

```yml
runtime: custom
env: flex
service: docker-app
```

This time we included the `service` attribute. By default, our app is deployed to the `default` service, which can't be deleted. Using a different service name will make it easier for us to delete it when we are done.

We can now deploy our app:

```sh
gcloud app deploy
```

The deploy might take a few minutes. After it is done, we are going to receive a target url we can use to test our server.

## Conclusion

I'm very surprised about how easy it is to onboard to App Engine. From what I see, a project can start running in App Engine by simply adding an `app.yaml` file.

I have a couple of very low traffic projects that I'm going to migrate to a standard environment soon to save some money.
