---
id: 3577
title: 'Go Language: Concurrency'
date: 2016-03-31T18:10:05+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3577
permalink: /2016/03/go-language-concurrency/
tags:
  - golang
  - programming
---
According to wikipedia concurrency can be defined like this:

_The property of program, algorithm, or problem decomposability into order-independent or partially-ordered components or units.[1] This means that even if the concurrent units of the program, algorithm, or problem are executed out-of-order or in partial order, the result will remain determinate._

or this:

_A form of computing in which several computations are executing during overlapping time periods—concurrently—instead of sequentially (one completing before the next starts)_

An example of a concurrent program could be a web server that can receive multiple requests &#8220;at the same time&#8221;. If the server wasn&#8217;t concurrent, users would have to wait for another request to be processed before the server could handle their request. 

Go is said to make concurrency very easy to program so today I&#8217;m going to explore it.

To explain concurrency it&#8217;s useful to have parts of a program that can execute asynchronously or in parallel. As an example I&#8217;m going to use a pair of functions that pretend to get some information from a database or service. Lets look at a simple example where everything is executed without concurrency:

<!--more-->

```golang
package main

import (
  "fmt"
  "time"
)

// These functions return hard-coded data but
// lets pretend they actually get the information
// from a database

// Returns a slice of slices containing a person's
// name and their country of origin
func getPeople() [][]string {
  time.Sleep(time.Second * 2)
  people := [][]string{{ "{{" }}"Hugo", "Mexico"}, {"Paco", "Brazil"}, {"Luis", "Canada"}}
  return people
}

// Returns countries we are interested in
func getInterestingCountries() []string {
  time.Sleep(time.Second * 4)
  countries := []string{"Brazil", "Mexico"}
  return countries
}

func main() {
  people := getPeople()
  countries := getInterestingCountries()

  var interestingPeople []string

  // Lets find the interesting people by matching
  // the people in the interesting countries
  for person := range people {
    for country := range countries {
      if people[person][1] == countries[country] {
        interestingPeople = append(interestingPeople, people[person][0])
      }
    }
  }

  // Prints [Hugo Paco]
  fmt.Println(interestingPeople)
}
```

This example calls two functions that give information about people and countries respectively. Then this data is processed and a result is printed. In lines 15 and 22 I added some Sleeps to simulate some latency in the database calls.

In this example everything is executed synchronously, so first the people are retrieved and then the countries. This means we have to wait 6 seconds before we can start processing the data. We can improve this using concurrency. Because the database calls can be done concurrently we only have to wait for the slowest one to complete before we can process the information. This means we would have to wait 4 seconds instead of 6 for this example.

## Channels

Go uses channels to communicate between Go routines (lightweight threads). Channels are the core of the concurrency model that go uses so we will use them to improve our example program. Before we start we need to learn a little go routines.

There is a very easy to execute something asynchronous to the main thread (in a go routine) in Go. You just need to use the go keyword:

```go
func main() {
  go someFunction()

  // Do some more stuff that will be executed
  // without waiting for someFunction to be finished
}
```

someFunction is being executed in a go routine so it doesn&#8217;t block the main thread. The problem is that you can&#8217;t communicate with the go routine when done this way. To solve that we need to use channels. Channels are declared like this:

```go
someChannel := make(chan string)
```

As you can see the channel has defined the type of data that will travel through it.

Channels can be bidirectional or unidirectional depending on the needs of the program. For our example we only need communication to travel one way. We need our functions that get data from a database to send the data to the channel and then the data should be received in the main function. Both functions need access to this channel (main to read and getPeople to write), to share this channel we are going to create it in main and then pass it to the other functions as an argument. Something like this:

```go
// Boilerplate stuff

func getPeople(c chan [][]string) {
  // The code here will also need to change
}

// Returns countries we are interested in
func getInterestingCountries(c chan []string) {
  // The code here will also need to change
}

func main() {
  peopleChannel = make(chan [][]string)
  countriesChannel = make(chan []string)
  getPeople(peopleChannel)
  getInterestingCountries(countriesChannel)

  // The code here will also change
}
```

Above you can see how we create two communication channels and pass them to getPeople and getInterestingCountries respectively. We are still not using them but this shows that our functions since they are going to be executed asynchronously don&#8217;t need to return anything. Instead they will send the information to main by using the channel.

To communicate between channels you can use the <- operator. Lets make getInterestingCountries write to the channel: 

```go
func getInterestingCountries(c chan []string) {
  time.Sleep(time.Second * 4)
  countries := []string{"Brazil", "Mexico"}
  c <- countries
}
```

That was easy. getInterestingCountries didn&#8217;t change much from the original version. The only difference is that instead of returning now it writes to the channel. One important thing to mention here is that writing to a channel and reading from a channel are blocking operations. This means that when you write to a channel the go routine stops until someone reads the value. The same thing is true for reads which makes the changes in main also very straight forward:

```go
func main() {
  peopleChannel := make(chan [][]string)
  countriesChannel := make(chan []string)
  go getPeople(peopleChannel)
  go getInterestingCountries(countriesChannel)
  people := <- peopleChannel
  countries := <- countriesChannel

  // More code here
}
```

Note that in lines 4 and 5 we are using the go keyword to execute the function asynchronously. By using concurrency this code would take 4 seconds to execute instead of 6. Lets see everything together:

```go
package main

import (
  "fmt"
  "time"
)

// These functions return hard-coded data but
// lets pretend they actually get the information
// from a database

// Returns a slice of slices containing a person's
// name and their country of origin
func getPeople(c chan [][]string) {
  time.Sleep(time.Second * 2)
  people := [][]string{{ "{{" }}"Hugo", "Mexico"}, {"Paco", "Brazil"}, {"Luis", "Canada"}}
  c <- people
}

// Returns countries we are interested in
func getInterestingCountries(c chan []string) {
  time.Sleep(time.Second * 4)
  countries := []string{"Brazil", "Mexico"}
  c <- countries
}

func main() {
  peopleChannel := make(chan [][]string)
  countriesChannel := make(chan []string)
  go getPeople(peopleChannel)
  go getInterestingCountries(countriesChannel)
  people := <- peopleChannel
  countries := <- countriesChannel

  var interestingPeople []string

  // Lets find the interesting people by matching
  // the people in the interesting countries
  for person := range people {
    for country := range countries {
      if people[person][1] == countries[country] {
        interestingPeople = append(interestingPeople, people[person][0])
      }
    }
  }

  // Prints [Hugo Paco]
  fmt.Println(interestingPeople)
}
```

This example works pretty well and I think can be used in production applications reliably, but there are some small things that would make the code a little better. Here is an improved version with comments:

```go
package main

import (
  "fmt"
  "time"
)

// The function will return a channel.
// By using <- before the chan keyword
// we specify this channel to be
// receive-only
func getPeople() <- chan [][]string {
  c := make(chan [][]string)

  // We execute the body in a go routine
  go func() {
    time.Sleep(time.Second * 2)
    people := [][]string{{ "{{" }}"Hugo", "Mexico"}, {"Paco", "Brazil"}, {"Luis", "Canada"}}
    c <- people
  }()

  return c
}

func getInterestingCountries() <- chan []string {
  c := make(chan []string)

  go func() {
    time.Sleep(time.Second * 4)
    countries := []string{"Brazil", "Mexico"}
    c <- countries
  }()

  return c
}

func main() {
  // Thanks to the changes we made in getPeople and
  // getInterestingCountries now main is a little cleaner
  peopleChannel := getPeople()
  countriesChannel := getInterestingCountries()
  people := <- peopleChannel
  countries := <- countriesChannel

  var interestingPeople []string

  for person := range people {
    for country := range countries {
      if people[person][1] == countries[country] {
        interestingPeople = append(interestingPeople, people[person][0])
      }
    }
  }

  fmt.Println(interestingPeople)
}
```

This new version shows how we can make the consumers of our functions look better by making some changes in the functions we call.

When writing the above example for the first time I made a mistake. I wrote this:

```go
people := <- getPeople()
countries := <- getInterestingCountries()
```

Instead of this:

```go
peopleChannel := getPeople()
countriesChannel := getInterestingCountries()
people := <- peopleChannel
countries := <- countriesChannel
```

It might seem like the same, but it is not. If we remember that <- is blocking then we will notice that in the first version getInterestingCountries won't execute until getPeople returns which means everything is executed sequentially. This is something to beware of.
