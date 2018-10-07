---
id: 3471
title: 'Go Language: Arrays'
date: 2016-02-17T18:34:21+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3471
permalink: /2016/02/go-language-arrays/
categories:
  - Go
tags:
  - golang
  - programming
---
Arrays are an interesting case in Go, because you are usually encouraged to not use them and use slices instead. Arrays in Go have a few rules that make them feel counter intuitive but I&#8217;m going to start with the parts that look normal. You can declare an array and assign values to it like this:

```go
var a [3]int
a[0] = 5
a[1] = 11
a[2] = 22
```

<!--more-->

You can also use this syntax which has the same effect:

```go
a := [3]int{5, 11, 22}
```

If you use fmt.Println on the array you will see this output:

```
[5 11 22]
```

So far I think everything makes sense. Lets look at something that is not that intuitive:

```go
var a [3]int
a[0] = 5
a[1] = 11
a[2] = 22

b := [3]int{1, 2, 3}
c := [3]int{5, 11, 22}

// This is false
fmt.Println(a == b)

// This is true
fmt.Println(a == c)
```

It is expected that a == b is false. Nevertheless, in other languages where arrays are references I would expect that a == c would be false too. In Go, arrays are treated as values and each item on the array is compared with the items on the other array. Since the values are the same, a == c.

Things become even more interesting when working with functions. When passing an array to a function all items are copied to a new array:

```go
// This function receives a copy
// of the array passed as argument,
// so modifying it doesn't affect
// the original array
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

The previous example can make sense if you get used to the idea of having a copy passed to the function instead of a reference. Things get confusing when you do this:

```go
// This time the original array
// is modified
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

This time we didn&#8217;t specify the size of the array and the result was that the original array was modified. The trick here is that by not specifying the size of the array we actually created a slice. Slices as opposed to arrays are passed by reference, so changes made to them are actually reflected in the original array.

It is interesting to know how arrays behave, but since you will be using slices more than arrays, I will cover them in a more detailed post.
