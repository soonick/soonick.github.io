---
title: Using testify for Golang tests
author: adrian.ancona
layout: post
# date: 2020-02-19
# permalink: /2020/02/using-testify-for-golang-tests/
tags:
  - automation
  - golang
  - programming
  - testing
---

A few weeks ago I wrote an article about [writing unit tests for Golang](/2020/01/unit-testing-golang-code/). In this article I'm going to explore using [`testify`](https://github.com/stretchr/testify) to make writing tests easier.

## Installation

I'm not going to cover how to install the [`testify`](https://github.com/stretchr/testify) library in this article. I wrote an article in the past explaining how to use [`dep`](/2017/09/dependency-management-with-golangdep/) for dependency management, you should follow that process to use `testify`.

<!--more-->

## Assertions

The `assert` package is the easiest to use. It provides functions that make it easy to verify that a variable has the expected value. [The documentation](https://godoc.org/github.com/stretchr/testify/assert) lists all the assertions available, so I won't cover them all. Instead, I'm going to show examples of uses of the ones that I use more often.

```go
package main

import (
	"testing"
	"github.com/stretchr/testify/assert"
)

func TestSomething(t *testing.T) {
	// All these assertions pass
	assert.Equal(t, "hello", "hello", "Values are equal")
	assert.NotEqual(t, "hello", "world", "Values are different")
	assert.Contains(t, "hello", "el", "String contains other given string")
	assert.True(t, true, "Value is true")
	assert.False(t, false, "Value is false")

	// All these assertions fail
	assert.Equal(t, "hello", "world", "Values are equal")
	assert.NotEqual(t, "hello", "hello", "Values are different")
	assert.Contains(t, "hello", "y", "String contains other given string")
	assert.True(t, false, "Value is true")
	assert.False(t, true, "Value is false")
}
```

The error messages for the failures are descriptive enough that it is easy to understand why the assertion failed:

```
--- FAIL: TestSomething (0.00s)
    main_test.go:17:
        	Error Trace:	main_test.go:17
        	Error:      	Not equal:
        	            	expected: "hello"
        	            	actual  : "world"

        	            	Diff:
        	            	--- Expected
        	            	+++ Actual
        	            	@@ -1 +1 @@
        	            	-hello
        	            	+world
        	Test:       	TestSomething
        	Messages:   	Values are equal
    main_test.go:18:
        	Error Trace:	main_test.go:18
        	Error:      	Should not be: "hello"
        	Test:       	TestSomething
        	Messages:   	Values are different
    main_test.go:19:
        	Error Trace:	main_test.go:19
        	Error:      	"hello" does not contain "y"
        	Test:       	TestSomething
        	Messages:   	String contains other given string
    main_test.go:20:
        	Error Trace:	main_test.go:20
        	Error:      	Should be true
        	Test:       	TestSomething
        	Messages:   	Value is true
    main_test.go:21:
        	Error Trace:	main_test.go:21
        	Error:      	Should be false
        	Test:       	TestSomething
        	Messages:   	Value is false
```

## Mocking

The mock package allows the creation of mock objects. These objects can be used to attach expectations to method calls.

As in most statically typed languages that don't allow monkey patching, creating a mock is somewhat time consuming.

Let's say we have a function that takes an object that implements the `Database` interface. It then tries to connect to this database and send a message to it:

```go
type Database interface {
	connect() error
	sendMessage(*string) error
}

func Talk(o Database, message *string) error {
	err := o.connect()

	if err != nil {
		return errors.New("Connection failed")
	}

	err = o.sendMessage(message)
	if err != nil {
		return errors.New("Sending message failed")
	}

	return nil
}
```

We want to test that `Talk` will return an `error` if it fails to connect or send the message. If everything goes well, it will return `nil`.

To make testing easier, we will create a mock that implements the `Database` interface (otherwise we would be connecting to a real database and we would run into many complications).

Let's look into how to create a mock step by step. First, we need to create a struct that extends `mock.Mock`:

```go
package main

import (
	"testing"
	"github.com/stretchr/testify/mock"
)

type MockDatabase struct {
	mock.Mock
}
```

This mock doesn't yet satisfy the `Database` interface, we need to manually write all method definitions:

```go
func (db *MockDatabase) connect() error {
	args := db.Called()
	return args.Error(0)
}

func (db *MockDatabase) sendMessage(message *string) error {
	args := db.Called(message)
	return args.Error(0)
}
```

Both method definitions are very similar. `db.Called` tells the mock that a method was called with a set of arguments and it returns the corresponding return arguments for that call (This will make a little more sense when we look into setting expectations).

The `args` object holds the values that we should return for that call, the only thing left to do is return them. We use `args.Error(0)` to retrieve the first return argument of type `error`. If we didn't know the type we could use `args.Get(0)`. If we had multiple return arguments, we can retrieve each of them based on the index. For example: `return args.Get(0), args.Error(1)`, for a method that returns a struct and an error.

Let's look at a test that verifies that no error is returned if the message is sent successfully:

```go
func TestSuccess(t *testing.T) {
	db := new(MockDatabase)
	message := "Hello"

	// Set expectations
	db.On("connect").Return(nil)
	db.On("sendMessage", &message).Return(nil)

	err := Talk(db, &message)

	assert.Equal(t, nil, err, "No error")
	db.AssertExpectations(t)
}
```

We start by creating a new instance of `MockDatabase`. The next interesting part is the setting of expectations:

```go
db.On("connect").Return(nil)
db.On("sendMessage", &message).Return(nil)
```

What we are doing here is telling the mock:
- When you see a call to `connect`, return `nil`
- When you see `sendMessage` called with the given memory address (`&message` will be translated to the memory address of the message variable) return `nil`

So, comming back to one of our mocked methods:

```go
func (db *MockDatabase) sendMessage(message *string) error {
	args := db.Called(message)
	return args.Error(0)
}
```

The first line will tell the mock: "There was a call to `sendMessage` with this memory address, what should I return. If the mock finds that return arguments were set, it will return those arguments. If it doesn't find any expectations for that call, the test will fail.

We can use `db.On...` to set different return values for each test, so we can test different things. Here are some tests I wrote:

```go
package main

import (
	"testing"
	"errors"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/assert"
)

type MockDatabase struct {
	mock.Mock
}

func (db *MockDatabase) connect() error {
	args := db.Called()
	return args.Error(0)
}

func (db *MockDatabase) sendMessage(message *string) error {
	args := db.Called(message)
	return args.Error(0)
}

func TestSuccess(t *testing.T) {
	db := new(MockDatabase)
	message := "Hello"

	// Set expectations
	db.On("connect").Return(nil)
	db.On("sendMessage", &message).Return(nil)

	err := Talk(db, &message)

	assert.Equal(t, nil, err, "No error")
	db.AssertExpectations(t)
}

func TestErrorOnConnect(t *testing.T) {
	db := new(MockDatabase)

	// Set expectations
	db.On("connect").Return(errors.New("Some error"))

	message := "Hello"
	err := Talk(db, &message)

	assert.NotEqual(t, nil, err, "An error is thrown if connection fails")
	db.AssertExpectations(t)
}

func TestErrorOnMessage(t *testing.T) {
	db := new(MockDatabase)
	message := "Hello"

	// Set expectations
	db.On("connect").Return(nil)
	db.On("sendMessage", &message).Return(errors.New("Some error"))

	err := Talk(db, &message)

	assert.NotEqual(t, nil, err, "An error is thrown if sendMessage fails")
	db.AssertExpectations(t)
}
```

In the tests above, I also used `db.AssertExpectations(t)`. This will fail if any of the expectations (set with `db.On...`) is not called. This is not necessary for all tests, and you might decide not to use it if your testing style is more loose.

The `mock` package provides a lot of functionality that I'm not covering here. If you have more sofisticated needs, you might want to take a look at the [documentation](https://godoc.org/github.com/stretchr/testify/mock).

## Conclusion

The standard Golang `test` package provides very limited functionality for writing tests. The `testify` package makes it easier to create cleaner tests by providing useful assertions and a way to create mocks that would otherwise require a lot of code.
