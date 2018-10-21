---
id: 3562
title: 'Go Language: Slices'
date: 2016-03-16T17:21:04+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3562
permalink: /2016/03/go-language-slices/
tags:
  - golang
  - programming
---
A few weeks ago I talked about [arrays in Go](http://ncona.com/2016/02/go-language-arrays/). This time I&#8217;m going to cover slices, which are built on top of arrays.

In my previous post I showed the difference between doing this:

```go
func doSomething(arr [3]int) {
    arr[0] = 5
}

func main() {
    a := [3]int{1, 2, 3}

    doSomething(a)

    // Prints [1 2 3]
    fmt.Println(a)
}
```

<!--more-->

and this:

```go
func doSomething(arr []int) {
    arr[0] = 5
}

func main() {
    a := []int{1, 2, 3}

    doSomething(a)

    // Prints [5 2 3]
    fmt.Println(a)
}
```

They seem similar, but the first example is using arrays and the second example is using slices. It all starts with the way slices are declared:

```go
// These are arrays
a := [3]int{1, 2, 3}
b := [...]int{1, 2, 3}

// This is a slice
c := []int{1, 2, 3}
```

Slices can also be created by slicing arrays or slices:

```go
// A slice created from an array
a := [5]int{5, 6, 7, 8, 9}
var sliceOfA []int
sliceOfA = a[2:3]
fmt.Println(sliceOfA) // prints [7]

// A slice created from a slice
b := []int{10, 11, 12, 13}
sliceOfB := b[1:4]
fmt.Println(sliceOfB) // prints [11 12 13]
```

You can see in these examples that you can create a slice by using the [:] operator on an array or slice. For example, when you say a[2:3], you are saying, give me the elements in a from index 2 to (3 &#8211; 1), which in this case is only the index 2.

An important thing to keep in mind about slices is that they share the memory with the original array or slice. This means that if you change a value on the original variable, the slice will be affected too:

```go
b := []int{10, 11, 12, 13}
sliceOfB := b[1:4]
fmt.Println(sliceOfB) // prints [11 12 13]

b[2] = 9
fmt.Println(sliceOfB) // prints [11 9 13]
```

## Internals

The fact that creating a slice doesn&#8217;t use extra memory is very interesting so lets see how this works.

Slices always work with an array behind the scenes. A slice consists of three pieces of information:

  * A pointer to the the index of the array where this slice starts
  * The length of the slice
  * The capacity, which is the maximum length a slice can be expanded to

Lets look at an example:

```go
b := []int{10, 11, 12, 13, 14, 15}
sliceOfB := b[1:4]
fmt.Println(sliceOfB) // prints [11 12 13]
fmt.Println(len(sliceOfB)) // prints 3
fmt.Println(cap(sliceOfB)) // prints 5
```

The pointer of sliceOfB points to 1 as specified when creating the slice (b[1:4]). We can also see that the slice has a length of 3 and a capacity of 5. This means the slice can be easily expanded to use all its capacity:

```go
sliceOfB = sliceOfB[:cap(sliceOfB)]
```
