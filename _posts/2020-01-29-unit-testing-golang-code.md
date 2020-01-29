---
title: Unit testing Golang code
author: adrian.ancona
layout: post
date: 2020-01-29
permalink: /2020/01/unit-testing-golang-code/
tags:
  - automation
  - golang
  - programming
  - testing
---

In this article I'm going to explain how to write and run unit tests for Golang code using `go test`. If you are completely new to the language, I recommend you take a look at my [introduction to Golang](/2016/01/first-steps-in-go-language/) article.

## Packages

Testing in the Golang world revolves around packages, so we need to understand what a package is before we can understand how to test code.

A package is nothing more than a way of grouping related code. In Golang, a folder can only contain a single package. If we try to define two files in a folder belonging to different packages, the compiler will complain.

<!--more-->

Let's say we have folder where we are starting a new project. In this folder we'll have a `main.go` file that is part of the `main` package:

```go
package main

import "fmt"

func main() {
	fmt.Println("hello")
}
```

Let's say we want to create a package where we will add some log-in functions (`login.go`):

```go
package login

import "fmt"

func Me() {
	fmt.Println("adrian")
}
```

If we put this file in the same folder as `main.go` and try to compile the project, we'll get an error because we have more than one package in a single folder:

```
can't load package: package github.com/user/project: found packages login (login.go) and main (main.go) in /go/src/github.com/user/project
```

To fix the error, let's create a `login` folder inside the project and move `login.go` to this folder. We can now use our new package from `main.go`:

```go
package main

import "fmt"
import "github.com/user/project/login"

func main() {
	fmt.Println("hello")
	login.Me()
}
```

In case of package name collisions, the package name can be aliased to something else. For example:

```go
import something "github.com/user/project/login"
```

## Test files

A test file should be part of the same **package** as the file under test. Because a package is analogous to a folder, it means that test files must go in the same folder as the files being tested. If the name of the file under test is `login.go`, the corresponding test file should be `login_test.go`.

Inside the test file, we can write test cases in this form:

```go
package login

import (
	"testing"
)

func TestSomething(t *testing.T) {
	t.Error("Test failed")
}
```

To run all the test in our project we can use this command:

```
go test ./...

--- FAIL: TestSomething (0.00s)
    login_test.go:8: Test failed
FAIL
FAIL	github.com/user/project/login	0.002s
```

## The testing package

Our test function receives a `testing.T` argument. This object contains functions that we can use inside our test to verify assumptions. There is [good documentation about the testing package](https://golang.org/pkg/testing/#T), but I'm going to mention the some I consider important.

- `Fail()` - Marks the test as failed but continues execution.
- `FailNow()` - Marks the test as failed and stops execution.
- `Error(args ...interface{})` - Prints the arguments and then calls `Fail()`.
- `Fatal(args ...interface{})` - Prints the arguments and then calls `FailNow()`.
- `Skip(args ...interface{})` - Skips the test if it hasn't failed yet.

This is a very simple set of functions that allow us to write our tests. There are other libraries, like [`testify`](https://github.com/stretchr/testify) that provide easier to use assertions and mocking functionality, but I'm not going to cover those in this article.

## Setup and Teardown

Most testing frameworks provide a way to do some setup before one or multiple tests are run, and to cleanup afterwards. Golang provides some help for doing this, but it's a little different to how other frameworks do it.

If what we need is to do some setup before any test on the file is run and then cleanup after all tests are done, we can use `TestMain`.

```go
func TestMain(m *testing.M) {
    setup()
    code := m.Run()
    shutdown()
    os.Exit(code)
}
```

If a test file contains a `TestMain` function, it won't run the test on that file. Instead it will only call `TestMain`. Calling `m.Run()` from within `TestMain` will run all tests in the current file.

In the example above it can be seen that some setup is done, then the tests are run and finally some cleanup is done. `m.Run()` will return a failed code if any test fails; `os.Exit` should be called with this code, so the run doesn't exit with code 0 if a test failed.

If per-test setup and teardown is necessary, it is recommended to handle this inside the test itself:

```go
func TestSomething(t *testing.T) {
	setup()
	t.Error("Test failed")
	shutdown()
}
```

## Conclusion

The tools that Golang provides out of the box are enough to write most test cases and get us started, but they are pretty bare-bones. I will explore in other articles some other libraries that can be used to make writing tests easier.
