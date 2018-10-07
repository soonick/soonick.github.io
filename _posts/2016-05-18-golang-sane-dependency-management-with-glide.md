---
id: 3647
title: 'Golang: Sane dependency management with Glide'
date: 2016-05-18T20:38:17+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3647
permalink: /2016/05/golang-sane-dependency-management-with-glide/
categories:
  - Go
tags:
  - automation
  - golang
  - programming
---
In a previous article I wrote an article explaining [how to do dependency management wrong by following Go&#8217;s recommendations](http://ncona.com/2016/04/golang-dependency-management-done-wrong/). This week I&#8217;m going to explore a better way to manage your dependencies.

Last year the Go community decided to try to fix the dependency management problem they had. Since this problem came from the root, the solution had to come from the same place. The big problem came from the fact that dependencies were pulled from GOPATH. This gave go users no way to have two versions of the same library or application installed in the same computer.

To fix this the **vendor** folder was created. This allows projects to store dependencies in a folder named **vendor** inside the project folder. This can be done recursively, so dependencies can store their own dependencies and so on. This allows each project to have it&#8217;s own dependencies without affecting other projects.

This resembles same dependency management systems, like npm. The problem is that the community didn&#8217;t provide any tooling to help you manage the dependencies. It is your responsibility to download the dependencies and put them in the vendor folder. Luckily other projects were born to help make this easier.

<!--more-->

## Glide

[Glide](https://glide.sh/) is a package manager that aims to do something like the npm tool does for node. It will download dependencies from different sources and lock the versions so other people on your project can download the exact same versions and updates to the dependencies don&#8217;t break your project.

Lets learn to use glide with the same example as [my previous article about golang dependency management](http://ncona.com/2016/04/golang-dependency-management-done-wrong/).

This is the project folder for my example:

```
~/workdir/src/github.com/myuser/playground/
```

And the main.go file looks like this:

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

We don&#8217;t want to use the standard way of downloading dependencies, so we need to use Glide. You can get the binary from [Glide&#8217;s downloads page](https://github.com/Masterminds/glide/releases). Once you have downloaded the binary and added the folder to your path you can go to your project folder and use glide to generate a glide.yaml file:

```
glide init
```

Your file will look something like this:

```
package: github.com/myuser/echo-playground
import:
- package: github.com/labstack/echo
  subpackages:
 - engine/standard
```

This file contains a manifest of the dependencies of this project. Now it is time to download the dependencies:

```
glide update
```

A vendor folder will be created and glide.lock file will be created. The glide.lock file is important and should be commited to your repo. This file tells glide exactly which versions to download. This provides us with reproducible builds. When a team member wants to download the dependencies they would need to run:

```
glide install
```

To download the versions specified in the lock file.

If in the future you need another dependency you can download it using this command:

```
glide get github.com/foo/bar
```

Updating a dependency is a little trickier. There is a command that updates all the dependencies in glide.yaml to the latest version:

```
glide up
```

But this might not be what you want to do.

It is common that you want to update a dependency because there is some new functionality you need from it. Running glide up will indeed update that dependency but it will also update all the other dependencies on your project, which might be problematic. There are talks about adding an argument to **glide up** so a package to update can be specified but that functionality is not ready by the time of this writing.

The only way I know of walking around this issue is by specifying a version inside glide.yaml. If a version is specified in glide.yaml, that version will be used all the time until manually changed. The **glide up** command won&#8217;t change this version, but if the version inside glide.yaml is something like **^1.2.3** then it is possible that a new minor version is downloaded and the lock file is updated. This might be the desired behavior but it is something to keep in mind.
