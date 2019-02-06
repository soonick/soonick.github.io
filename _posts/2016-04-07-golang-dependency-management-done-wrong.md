---
id: 3622
title: 'Golang: Dependency management done wrong'
date: 2016-04-07T07:17:04+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3622
permalink: /2016/04/golang-dependency-management-done-wrong/
tags:
  - golang
  - productivity
  - programming
  - dependency_management
  - automation
---
I have just begun my journey in the Go universe and so far I have found a few things that I don&#8217;t really like. I consider this natural because as I get familiar with a way of working I find it hard to accept other ways without questioning them very heavily first.

I&#8217;m not an expert in doing dependency management, but when a friend told me how Go decided to do it, it really hurt my soul. Before I begin telling you why it did and why I believe it is the wrong way to do dependency management let me add a disclaimer:

> The Go team realized that the out of the box way of doing dependency management was not ideal so they came up with a solution. If you are going to start a project that has dependencies in other projects you should use [Golang&#8217;s new proposal for package management](https://github.com/golang/go/wiki/PackageManagementTools).

<!--more-->

## Dependencies

I will assume you have already done a &#8220;Hello world&#8221; program with Go so you already have your workdir setup. Now we can create a new project in the workdir:

```
~/workdir/src/github.com/myuser/playground/
```

Lets create a main.go file in our playground project and add a simple &#8220;Hello world&#8221; server using the echo web framework:

```go
package main

import (
    "net/http"

    "github.com/labstack/echo"
    "github.com/labstack/echo/engine/standard"
)

func main() {
    e := echo.New()

    e.Get("/", func(c echo.Context) error {
        return c.String(http.StatusOK, "Hello, World!\n")
    })

    e.Run(standard.New(":1323"))
}
```

Here is where the fun starts. We have 3 dependencies for this server. One of them is part of the Go standard library(net/http) and the other two are external dependencies. Go decided to make it really easy for developers to work with external dependencies. You just need to add the package you need in the import block and go will get it for you. To run this server you only need to do this:

```
cd ~/workdir/src/github.com/myuser/playground/
go get .
go run main.go
```

It is really convenient that declaring the dependency in the code and running those commands is all you need to run your application. For a novice programmer this could seem like heaven, but for someone who knows better this smells like trouble.

**It works, what is the problem?** At this point it might seem like everything is working fine, but we are leaving the health of our app in the hands of the maintainers of our dependencies. Even if the maintainers are really good people and do their best not to break us, sometimes it is unavoidable. As a matter of fact there is a big notice in the echo README that warns people that the master branch now points to v2 of echo and that it might break people using v1. This little thing can have disastrous consequences in a program running in production. If you had a server using v1, one day out of nowhere you try to deploy a new version of your server and realize that everything is broken.

The risk of this happening when you just grab the latest version of master is huge, so how is it possible that the Go team decided to go with this approach and not notice how bad of an idea it was right away? I heard a rumor that the way some teams avoided being bitten by backwards incompatible changes in their dependencies was by checking them in into version control. This is not as bad as it sounds and it actually has some benefits. By checking in your dependencies you don&#8217;t have to rely on any other services to make a deploy. When you don&#8217;t check-in your dependencies you need github to be up in order to get the dependencies, if your dependencies are checked-in you already have all you need.

Cool, so lets check-in the dependencies. This is a possibility, but there are other issues to consider with the way Go works out of the box. Lets see what happened when we ran

```
got get .
```

If you go to ~/workdir/src/github.com/ you will see that there are three new folders there: labstack, mattn and valyala. It is understandable that we have the labstack folder since we included labstack/echo in our code, but what about mattn and valyala?. What happened here is that echo itself requires mattn and valyala. This might seem fine, but it is another big problem. If the program you are building required mattn and the version of mattn you need is different than the version echo needs then you are in big trouble.

Lets ignore that big problem for now and decide we want to check-in the dependencies for our program. Since the dependencies are not in the same folder as our project we would need to check-in the whole ~/workdir/src/github.com/, as a matter of fact you might have dependencies that come from other sources that are not github so you might want to check-in the whole ~/workdir/src/ directory. Now we are in another dilemma. If we are working in different projects we probably don&#8217;t want to check all the projects into a single repository.

**How have people been able to use Go in production?** Well, what some projects did to escape this madness was to copy the source code from the dependencies into a folder inside their version controlled repository and then check it in. This would in essence be a different package than the original one so you would have full control over it and you can update it when needed. You also have to consider that when using this package you would have to change the import from github.com/labstack/echo to something like dependencies/labstack/echo. You have to do this not only for the code you are writing but also for the code on all your dependencies, the dependencies of your dependencies and so on. This can probably be automated, but still seems not ideal.

Luckily as I mentioned earlier, there are now alternatives. When you start a new Go project make sure to use one of the alternatives instead of doing what Go provides by default.
