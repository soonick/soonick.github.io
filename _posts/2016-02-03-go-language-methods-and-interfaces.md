---
id: 3418
title: 'Go Language: Methods and Interfaces'
date: 2016-02-03T08:36:14+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3418
permalink: /2016/02/go-language-methods-and-interfaces/
tags:
  - golang
  - programming
---
A few weeks ago I started to learn Go and I wrote an [introductory post](http://ncona.com/2016/01/first-steps-in-go-language/). I&#8217;m going to continue where I left and explain how you can extend structures with methods and later how to use interfaces as arguments.

## Methods

Go doesn&#8217;t have classes or objects as we know them. It uses structs instead to create object-like structures:

```go
type Animal struct {
  color string
  size float64
}
```

This looks very similar to an object but something very important is missing. You can declare properties like this, but not methods. How will our animal do stuff without methods?. Golang actually does have methods, but you have to attach them to the struct after it is created:

<!--more-->

```go
func (animal *Animal) makeSound() {
  fmt.Println("Beep")
}
```

And then you can call it as you do in other languages:

```go
func main() {
  robot := new(Animal)
  robot.makeSound()
}
```

For my previous example I didn&#8217;t access any of the attributes of the struct, but you can see that we actually declare a name for the struct object for which we are adding the method. We can use this reference to access properties of the struct. Lets add a new method:

```go
func (animal *Animal) saySize() {
  fmt.Printf("I am this big: %f", animal.size)
}
```

You can see how we are using animal.size to get the size for the current struct. Here is an example usage:

```go
func main() {
  robot := Animal{
    size: 9000.1,
  }
  dog := Animal{
    size: 3.2,
  }
  robot.saySize()
  dog.saySize()
}
```

There is not much more to say about methods. They can work pretty similar to functions but are attached to structs and can be called using a dot(.).

## Interfaces

Go supports interfaces also in a different way than I am used to. When talking about interfaces, I usually think about how you define an interface in Java that states which methods should be implemented by whoever is to fulfill the interface and then the classes declaring that they implement an interface when they are defined.

In Go, interfaces work similarly, but they are looser. They are similar in the fact that they also define methods that need to be fulfilled:

```go
type SoundMaker interface {
  makeSound()
}
```

We declared and interface that requires the makeSound method to be present. This interface is only useful when you use it as a method argument:

```go
func soundTwice(thing SoundMaker) {
  thing.makeSound()
  thing.makeSound()
}
```

This example is not very exciting, but it shows how you can expect interfaces as arguments instead of basic types or structs. The advantage of this is that soundTwice can accept anything that makes a sound(has a makeSound method), it doesn&#8217;t really care what it is.

To prove this, we can use our animal that already knows how to make sounds. Lets look at how all the code behaves together:

```go
package main

import "fmt"

type SoundMaker interface {
  makeSound()
}

type Animal struct {
  color string
  size float64
}

func (animal *Animal) makeSound() {
  fmt.Println("Beep")
}

func soundTwice(thing SoundMaker) {
  thing.makeSound()
  thing.makeSound()
}

func main() {
  robot := new(Animal)
  soundTwice(robot)
}
```

This code will output:

```
Beep
Beep
```

The SoundMaker interface expects just one method to be implemented, and this method doesn&#8217;t receive nor return arguments, but you can have your interface expect as many methods as you want and each method can receive and return arguments as necessary. As a rule for sanity, try to keep your interfaces small so they can be reused more often.

Here is an example of an interface with two methods that actually receive and return arguments:

```go
type Calculator interface {
  add(int int) int
  randomNumber() float64
}
```

One useful thing about object oriented methods is that you can reuse code by inheriting from another class. Go doesn&#8217;t support inheritance, but it allows some kind of composition by using embeded types (also called anonymous types). Basically if we wanted to say that we have a Dog that is an Animal, we would do this:

```go
type Dog struct {
  Animal
}
```

This gives Dog access to all properties and methods of Animal as if they were his. This means that it automatically fulfills the SoundMaker interface and for that reason can do this:

```go
chihuahua := new(Dog)
soundTwice(chihuahua)
```

This is all for today. I&#8217;ll try to write another post soon about more advanced topics.
