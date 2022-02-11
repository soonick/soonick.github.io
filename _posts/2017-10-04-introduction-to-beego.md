---
id: 4355
title: Introduction to Beego
date: 2017-10-04T08:40:11+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4355
permalink: /2017/10/introduction-to-beego/
tags:
  - docker
  - golang
  - programming
---
I tried GoLang for the first time a little less than two years ago and I didn&#8217;t get a very good first impression of it. One of the things that I disliked the most is that back then the community seemed to be overly focused in performance even when that meant creating unreadable code.

One of the things that bothered me the most was that the community was against creating web frameworks with opinions. Because of this lack of standardization, I had to relearn how things are done every time I looked at a new web project written in Go.

Today I decided to look again into the state of web frameworks and there seems to be a few promising options out there. I saw a good amount of people recommending Beego, so I decided to give it a try.

<!--more-->

## Development environment

To start playing with Beego, lets create a Dockerfile that will allow us to easily start building our application:

```docker
FROM golang:1.9.0-alpine3.6

RUN apk update \
  && apk add ca-certificates wget unzip git \
  && update-ca-certificates

# Install golang/dep
WORKDIR /root
RUN wget https://github.com/golang/dep/releases/download/v0.3.0/dep-linux-amd64.zip
RUN unzip dep-linux-amd64.zip -d bin
ENV PATH="/root/bin:${PATH}"

WORKDIR /go/src/app
COPY . .

RUN go get github.com/beego/bee
ENV PATH="${GOPATH}:${PATH}"

RUN dep ensure

CMD ["go-wrapper", "run"]
```

This will create an image with all we need to run our simple Beego app. We now need to create a main.go file:

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, 世界")
}
```

Because the Dockerfile uses Dep, we also need to create an empty Gopkg.toml file:

```bash
touch Gopkg.toml
```

We can now build the image and run the app:

```bash
docker build -t beego-image .
docker run --rm -it -p 8080:8080 --name beego-container -v $(pwd):/go/src/app beego-image
```

At this point, this is just a hello world app that doesn&#8217;t use beego, but we&#8217;ll get there soon.

## The bee tool

Beego comes with a CLI tool that provides some pretty useful functionality for developers. The Dockerfile above already takes care of installing it, so we can use it to create our API server. First we need a terminal inside the docker container:

```bash
docker run --rm -it -p 8080:8080 --name beego-container -v $(pwd):/go/src/app beego-image sh
```

And then we can create our app:

```
cd ..
bee api app
```

I use _cd .._ to move to the _/go/src_ folder (since /go/src/app is the container&#8217;s WORKDIR). By running _bee api app_, a folder named app will be created (in this scenario, it is not created because it already exists) and inside it, the files needed for an API server. The output of the command shows the files that were created:

```
______
| ___ \
| |_/ /  ___   ___
| ___ \ / _ \ / _ \
| |_/ /|  __/|  __/
\____/  \___| \___| v1.9.0
2017/09/11 11:24:27 INFO     ▶ 0001 Creating API...
    create   /go/src/app
    create   /go/src/app/conf
    create   /go/src/app/controllers
    create   /go/src/app/tests
    create   /go/src/app/conf/app.conf
    create   /go/src/app/models
    create   /go/src/app/routers/
    create   /go/src/app/controllers/object.go
    create   /go/src/app/controllers/user.go
    create   /go/src/app/tests/default_test.go
    create   /go/src/app/routers/router.go
    create   /go/src/app/models/object.go
    create   /go/src/app/models/user.go
    create   /go/src/app/main.go
2017/09/11 11:24:27 SUCCESS  ▶ 0002 New API successfully created!
```

Since these new files were created from inside the docker container, they all have root as the owner. This is probably not something you want. To fix it, close the docker terminal, go back to your project folder (outside the container) and run this command:

```bash
sudo chown -R $(whoami):$(whoami) .
```

The bee CLI tool also has a file watcher that will recompile the project when a file changes, so lets modify the CMD line in the Dockerfile to use it:

```
CMD dep ensure && bee run
```

We can now rebuild the image (to install the dependencies) and run the application:

```
docker build -t beego-image .
docker run --rm -it -p 8080:8080 --name beego-container -v $(pwd):/go/src/app beego-image
```

If we go to _http://localhost:8080/_ we will see a 404 page served by beego.

## Routing

User&#8217;s interaction with your application will start with the router. The router defines what is going to happen when a user visits a URL, so it is important to understand how it works.

First of all we have _main.go_ that initializes the routes and then starts the server:

```go
package main

import (
    _ "app/routers"

    "github.com/astaxie/beego"
)

func main() {
    if beego.BConfig.RunMode == "dev" {
        beego.BConfig.WebConfig.DirectoryIndex = true
        beego.BConfig.WebConfig.StaticDir["/swagger"] = "swagger"
    }
    beego.Run()
}
```

The most important thing happening here is the importing of app/routers. This folder contains all the routers defined by the application. There are a few [ways to define routes in Beego](https://beego.me/docs/mvc/controller/router.md). We are going to explore the one the app generator is using. Lets look at _app/routers/router.go_:

```go
package routers

import (
    "app/controllers"

    "github.com/astaxie/beego"
)

func init() {
    ns := beego.NewNamespace("/v1",
        beego.NSNamespace("/object",
            beego.NSInclude(
                &controllers.ObjectController{},
            ),
        ),
        beego.NSNamespace("/user",
            beego.NSInclude(
                &controllers.UserController{},
            ),
        ),
    )
    beego.AddNamespace(ns)
}
```

There are a few things to learn here. We can see the use of _beego.NewNamespace_ to create a route namespace. We can also see that namespaces can be nested, so the route _/v1/object_ will use _controllers.ObjectController_.

Which method gets called in the controller can be decided in a few ways. The method used by the generated server is annotations in the controller:

```go
package controllers

import (
    "app/models"
    "encoding/json"

    "github.com/astaxie/beego"
)

// Operations about object
type ObjectController struct {
    beego.Controller
}

// @router / [get]
func (o *ObjectController) GetAll() {
    obs := models.GetAll()
    o.Data["json"] = obs
    o.ServeJSON()
}
```

First of all _ObjectController_ gets some functionality from _beego.Controller_. Then it uses an annotation on top of the GetAll method to specify that this method will be called when a GET request to / is received.

The GetAll method just gets the data from the model and renders it as JSON. The response looks like this:

```json
{
  "hjkhsbnmn123": {
    "ObjectId": "hjkhsbnmn123",
    "Score": 100,
    "PlayerName": "astaxie"
  },
  "mjjkxsxsaa23": {
    "ObjectId": "mjjkxsxsaa23",
    "Score": 101,
    "PlayerName": "someone"
  }
}
```

For getting information about a specific object the Get method is defined:

```go
// @router /:objectId [get]
func (o *ObjectController) Get() {
    objectId := o.Ctx.Input.Param(":objectId")
    if objectId != "" {
        ob, err := models.GetOne(objectId)
        if err != nil {
            o.Data["json"] = err.Error()
        } else {
            o.Data["json"] = ob
        }
    }
    o.ServeJSON()
}
```

A call to _GET /v1/object/hjkhsbnmn123_ would call this method. You can see how the annotation defines the :objectId parameter and then it is retrieved in the method body.

If you don&#8217;t want to use an annotation, you can also define the method to execute when defining the route:

```go
beego.Router("/api/something", &SomethingController{}, "patch:UpdateTheThing")
```

The example above will call the _UpdateTheThing_ method in _SomethingController_ when it receives a _PATCH_ request on _/api/something_.

The last option is the default behavior. Beego will by default executes methods based on the requested verb. When GET /, Get() will be executed. When PUT /, Put() will be executed, etc&#8230;

## Conclusion

Beego is not as easy to use a Ruby on Rails, but it is a lot better than doing development without any guidelines. From what I have seen, it provides good tools to get started and enough guidelines to help developers move fast.

I have only scratched the surface but I already want to learn more about how it works. I will probably be focusing on other parts of the framework in other posts (models, parameters, etc&#8230;)
