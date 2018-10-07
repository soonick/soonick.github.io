---
id: 3403
title: First steps in Go Language
date: 2016-01-13T06:52:09+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3403
permalink: /2016/01/first-steps-in-go-language/
categories:
  - Go
tags:
  - golang
  - programming
---
My company started using Go for some services and currently there is only one person that is familiar with the language. This means nobody is reviewing the code and nobody can contribute or fix stuff if it is necessary. To fix this, I have decided to learn Go.

## Install

The install steps might change depending on your operating system, so you are probably better reading the [official documentation](https://golang.org/doc/install). I&#8217;m going to show the steps I followed to install on my system just as an example.

I&#8217;m running a Fedora machine so I downloaded the binary from the [downloads page](https://golang.org/dl/) and extracted it to a folder. The next step is to add the Go binaries to the path. You can achieve this by adding two lines to ~/.bashrc:

<!--more-->

```bash
export GOROOT="$HOME/tools/go"
export PATH="$PATH:$GOROOT/bin"
```

Of course, change the path so it points to the folder were you extracted Go.

The next step is to create a workspace. This is simply a folder where your Go projects will live:

```
mkdir ~/workdir
```

And then add another environment variable to .bashrc:

```bash
export GOPATH="$HOME/workdir"
```

Now we need to create a folder for our project:

```
mkdir -p ~/workdir/src/github.com/user/hello
```

Then create a file called hello.go in in that folder with this content:

```go
package main

import "fmt"

func main() {
    fmt.Printf("hello, world\n")
}
```

We can now compile that file with this command:

```bash
go install github.com/user/hello
```

Note that you can run this command from anywhere. Go will look for the source code inside $GOPATH/src.

Compiling the code creates an executable file inside $GOPATH/bin. We can execute this file like any other binary:

```
$GOPATH/bin/hello
```

## Variables

Go is a statically typed language. This means that you must specify the type of a variable before you can use it. The type of this variable can&#8217;t change for the length of its life. Having this consistency makes it easier for compilers to detect errors and optimize your code under the hood.

Variables are declared like this:

```
var <name> <type>
```

So, you can do something like this:

```go
var word string
word = "Hello"
fmt.Println(word)
```

Variables have to be declared before you can use them, so doing this will fail:

```go
word = "Hello"
fmt.Println(word)
```

To make code shorter, Go allows you to implicitly declare a variable using the := operator. What this operator does is check the type of the value at the right and then declare a variable with the name on the left with that type. After the variable has been declared, the value is assigned as expected.

```go
word := "Hello"
fmt.Println(word)
```

Go, like python allows you to assign more than one value at the time, so this is completely valid:

```go
var word string
var place string
var amount int
word, place, amount = "Hello", "Mexico", 12
```

You can also initialize more than one variable at the same time, using the := operator. The interesting thing here is that you can use this operator even if there is only one new variable in the left side:

```go
var word string
word, place, amount := "Hello", "Mexico", 12
```

## functions

The syntax for creating a simple function that returns no arguments is very similar to other languages:

```go
func hello() {
  fmt.Println("Hello, playground")
}
```

Passing arguments should also be familiar if you come from a language like C:

```go
func numberThings(thing string, amount int) {
  fmt.Printf("I have %d %ss", amount, thing)
}
```

The only difference I see is that the type of the parameters is on the right instead of on the left as I am used to. The previous function can be called like this:

```go
numberThings("dog", 3)
```

And the result would be:

```
I have 3 dogs
```

Things start looking a little weird when you want to return a value:

```go
func six() int {
  return 6
}
```

You can see that the return type is specified before the opening brace. Another special thing about Go is that it can return more than one value:

```go
func sixRedDogs() (int, string, string) {
  return 6, "red", "dogs"
}
```

The previous function can be used like this:

```go
number, color, thing := sixRedDogs()
```

## Structs

Go is not an Object Oriented language, but it provides structures that allow you to create custom types that could resemble an object:

```go
type Shape struct {
  area float64
  perimeter float64
}
```

Using a struct is pretty straight forward. Lets look at some examples:

```go
var someShape Shape
someShape.area = 44.5

otherShape := Shape {
  area: 77.7,
}
```

## Pointers

In Go, opposite to what I am used to, everything is passed by value. This has very interesting repercussion when using structs as function arguments. Lets look at a simple program to understand what is happening:

```go
package main

import "fmt"

type Shape struct {
  area float64
  perimeter float64
}

func change(a Shape) {
  a.area = 5
}

func main() {
  var someShape Shape
  someShape.area = 44.5
  change(someShape)

  fmt.Println(someShape.area)
}
```

The output of this program is **44.5**. In most programming languages I have used in the past, because objects are passed by reference, this would have resulted in **5**. This default behavior is very useful if you want to make sure that a function doesn&#8217;t modify the values you are passing, but it also has performance implications because it has to create a new copy every time a struct is passed to a function.

There are times, however, that you might want the function to be able to modify the object you are passing. Also, the object you are passing may be very big, so creating a copy may cause performance issues. Because of that, Go allows you to use pointers. A pointer is variable that instead of containing a value, contains a memory address where that value lives. Passing this pointer around is faster because you only have to copy the memory address instead of all the values in the struct.

To get a pointer to a struct instead of getting the value, you can use the & operator. To make a function expect a pointer instead of a struct, you can use `*`. Lets see how our program changes when we use pointers:

```go
package main

import "fmt"

type Shape struct {
  area float64
  perimeter float64
}

func change(a *Shape) {
  a.area = 5
}

func main() {
  someShape := &Shape{}
  someShape.area = 44.5
  change(someShape)

  fmt.Println(someShape.area)
}
```

This time, the code returns **5**. Note that we use the & operator to create a pointer called someShape, but we can still modify its properties the same way we do if we are dealing with a value. The parameter for the change function was preceded by a * to indicate that it expects a pointer.

I think this is enough knowledge for a day. I&#8217;m going to continue learning about Go in another post.
