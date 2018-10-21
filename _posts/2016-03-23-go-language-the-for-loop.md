---
id: 3581
title: 'Go Language: The For loop'
date: 2016-03-23T13:26:59+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3581
permalink: /2016/03/go-language-the-for-loop/
tags:
  - golang
  - programming
---
One of the first things I heard about Go that sounded interesting is that it has only one way to create loops. Go only provides the **for** statement. This sounds a little weird, but the truth is that they just decided to use the **for** keyword for while loops instead of having a separate while keyword. Lets see an example:

```go
package main

import (
  "fmt"
)

func main() {
  people := []string{"Hugo", "Paco", "Luis"}

  // Like a for
  numPeople := len(people)
  for i := 0; i < numPeople; i++ {
    fmt.Println(people[i])
  }

  // Like a while
  numPeople = len(people)
  i := 0
  for i < numPeople {
    fmt.Println(people[i])
    i++
  }
}
```

<!--more-->

You can see in line 12 that you can use the for loop as you are used to. Having the initialization followed by the condition to stay in the loop and then an expression that is executed after the loop.
  
In line 19 you can see that only the condition is given. In this case it behaves like a while.

Another useful structure I&#8217;m used to is the foreach, which allows you to loop through all elements in an array. You can use the for loop combined with a range to do the same thing:

```go
package main

import (
  "fmt"
)

func main() {
  people := []string{"Hugo", "Paco", "Luis"}

  for _, val := range people {
    fmt.Println(val)
  }
}
```

All the examples I showed have the same effect. They print the names in the people slice.
