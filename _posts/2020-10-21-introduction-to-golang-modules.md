---
title: Introduction to Golang modules
author: adrian.ancona
layout: post
date: 2020-10-21
permalink: /2020/10/introduction-to-golang-modules/
tags:
  - golang
  - programing
---

Modules are the new way of doing dependency management in Golang.

A module is a collection of packages that are distributed together (e.g. a single binary). A module contains a `go.mod` file at its root.

With modules, it is not necessary to have our code in `$GOPATH/src` anymore, so we can create a project anywhere.

Let's start a new project:

```
mkdir ~/project
```

And make it a module:

```
cd ~/project
go mod init mymodule/hello
```

<!--more-->

This creates a `go.mod` file. Mine looks like this:

```
module mymodule/hello

go 1.15
```

Let's create a main file in our module:

```
touch main.go
```

And add this content:

```go
package main

import "fmt"

func main() {
    fmt.Println("hello world")
}
```

We can run our application:

```
go run main.go
```

Since the point of modules is managing dependencies, let's add a dependency to our application:

```go
package main

import "fmt"
import "rsc.io/quote"

func main() {
  fmt.Println(quote.Hello());
}
```

Next time we try to run it, all the dependencies will be downloaded and the dependencies' versions will be added to `go.mod`:

```
module mymodule/hello

go 1.15

require rsc.io/quote v1.5.2 // indirect
```

There is also a file named `go.sum` created. This file contains information about all the dependencies (including dependencies of dependencies):

```
golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c h1:qgOY6WgZOaTkIIMiVjBQcw93ERBE4m30iBm00nkL0i8=
golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c/go.mod h1:NqM8EUOU14njkJ3fqMW+pc6Ldnwhi/IjpwHt7yyuwOQ=
rsc.io/quote v1.5.2 h1:w5fcysjrx7yqtD/aO+QwRjYZOKnaM9Uh2b40tElTs3Y=
rsc.io/quote v1.5.2/go.mod h1:LzX7hefJvL54yjefDEDHNONDjII0t9xZLPXsUe+TKr0=
rsc.io/sampler v1.3.0 h1:7uVkIFmeBqHfdjD+gZwtXXI+RODJ2Wc4O7MPEh/QiW4=
rsc.io/sampler v1.3.0/go.mod h1:T1hPZKmBbMNahiBKFy5HrXp6adAjACjK9JXDnKaTXpA=
```

Both files should be checked into version control to provide reproducible builds.

We can also see all the dependencies in our module using `go list`:

```
go list -m all
```

To see the available versions of a specific module:

```
go list -m -versions rsc.io/sampler
```

We can upgrade a package to a specific version:

```
go get rsc.io/sampler@v1.3.1
```

To upgrade to the latest version, just omit the version

```
go get rsc.io/sampler
```

## Conclusion

In this article we learned how to create a simple module and manage its dependencies. The system seems simple to use, and not having to put all our code in $GOPATH/src is a nice new feature.
