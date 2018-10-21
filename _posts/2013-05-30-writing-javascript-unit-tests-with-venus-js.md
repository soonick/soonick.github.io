---
id: 1398
title: Writing JavaScript unit tests with venus.js
date: 2013-05-30T04:01:26+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1398
permalink: /2013/05/writing-javascript-unit-tests-with-venus-js/
tags:
  - automation
  - debugging
  - javascript
  - node
  - programming
  - projects
---
JavaScript used to be a language mainly for handling minor interactions or animations in the browser, but not anymore. Now you can see full applications built using JavaScript. Frameworks like backbone have brought architecture to the browser and you can even see JavaScript being used in the server with frameworks like node. As JavaScript becomes a language for building real applications, it becomes important to also adopt professional practices like having a way write and run unit tests.

## Venus

Venus is a test runner that makes it very easy to run your tests and plug them into a CI system. Venus is written in JavaScript and runs on Node. It lets you choose which tools you want to use to organize your tests, write assertions or create mocks.

You can get more information about venus at [venus&#8217; website](http://www.venusjs.org/ "Venus.js website") and you can [get the code at github](https://github.com/linkedin/venus.js).

<!--more-->

Since Venus allows you to choose any libraries you want to use I will choose to use [mocha](http://visionmedia.github.io/mocha/ "Mocha") to organize my tests, [expect.js](https://github.com/LearnBoost/expect.js/ "Expects.js") to write my assertions and [sinon.js](http://sinonjs.org/ "Sinon.js") for mocking and stubing, so I will explain a little about them.

## Mocha

Mocha is a framework that helps you organize your test suite. It allows you to create groups of tests and provides hooks for before, beforeEach, after, etc. A mocha suite looks like this:

```js
describe('Some module name', function() {
  describe('You can have as many nested describes as you want', function() {
    before(function() {
      // This will be executed before any other test in this describe block
    })

    afterEach(function() {
      // This will be executed after each of your tests
    });

    it('Whatever you are testing', function(){
      // Your test code here
    })
  })
})
```

Sounds simple because it is. For all I care that is all mocha does.

## Expect.js

Expect.js is an assertion library that allows us to verify if a value is what we expect it to be. I am not going to go through all the assertions that it provides but here are a few examples:

```js
expect(1).to.be.ok(); // Passes
expect(0).to.be.ok(); // Fails
expect(1).not.to.be(true) // Passes
expect(1).to.be(2) // Fails
```

There are a lot of different assertions available, so I recommend you take a look at their documentation.

## Sinon.js

This is probably the most interesting and most fun. I use sinon mostly for mocking functions, which is basically replacing a function call with the return of a dummy value, which is very useful when you want to do real unit tests. Another thing that I usually do with sinon is create expectations of how many times or with which arguments I expect a function call to be. Here is a very simple example:

```js
// This is node.js code
var sinon = require('sinon');

// This is the object we will mock
var obj = {};
obj.function1 = function(){};
obj.function2 = function() { return this.function1() };

// Mock
var mock = sinon.mock(obj);
mock.expects('function1').once().returns('hello');

// This will return hello because our mock prevents the call to
// function1 and instead always returns 'hello'
obj.function2();

// This verifies that function1 was called only once
mock.verify();
```

## Installing venus

Venus is a node.js application, so we need to first get node to run it. You can find instructions to intall node on [node&#8217;s website](http://nodejs.org/ "Node's website"). After getting node you need to get venus from github:

```
git clone git://github.com/linkedin/venus.js.git
cd venus.js
npm install
sudo ln -s /path/to/venus/folder/bin/venus /usr/bin/venus
```

## Running tests

Now that we have venus installed lets create a test file:

```js
describe('String functions', function() {
    describe('indexOf', function() {
        it('should return the position of the first occurence', function() {
            expect('abcdef'.indexOf('d')).to.eql(3);
        });

        it('should return -1 when no match is found', function() {
            expect('abcdef'.indexOf('g')).to.eql(-1);
        });
    });

    describe('charAt', function() {
        it('should return the character at specified position', function() {
            expect('abcdef'.charAt(1)).to.eql('b');
        });
    });
});
```

You can run this test file using venus:

```
venus run -t /path/to/test/file.js
```

You will get something like this in return:

```
info:   Serving test: http://0.0.0.0:2013/venus-core/1
info:   executor started on 0.0.0.0:2013
```

This means that you can visit this url: **http://0.0.0.0:2013/venus-core/1** in the browser to run your tests. The results will not show in the browser but in the terminal:

```
Firefox 21

   String functions >> indexOf
     ✓ should return the position of the first occurence


   String functions >> indexOf
     ✓ should return -1 when no match is found


   String functions >> charAt
     ✓ should return the character at specified position


✓ 3 tests completed (0.21ms)
```

If you don&#8217;t want to open a browser every time to run your tests you can run your tests using phantomjs. You can get it from [phantomjs&#8217; website](http://phantomjs.org/ "Phantomjs website"). Once you have it installed you can use this command to run your tests on phantomjs:

```
venus run -t /path/to/test/file.js --phantom
```

In the previous example we tested native JS code. In most scenarios you will want to test your own code, in which case you will need to specify which file you are testing. For things like this venus provides some annotations:

```js
/**
 * @venus-include /file/to/be/tested.js
 * @venus-fixture /path/to/fixtures.js
 */

// ... The test code goes here
```

This should be enough to get you started.
