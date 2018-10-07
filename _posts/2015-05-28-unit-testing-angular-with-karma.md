---
id: 2817
title: Unit testing angular with karma
date: 2015-05-28T08:04:17+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2817
permalink: /2015/05/unit-testing-angular-with-karma/
categories:
  - Javascript
tags:
  - angularjs
  - javascript
  - productivity
  - testing
---
[Karma](http://karma-runner.github.io/0.12/index.html) is a JS unit test runner originally designed for Angular. Karma can use most popular testing frameworks(mocha, jasmine, etc&#8230;), assertion libraries(expect, chai, &#8230;) and mocking frameworks(sinon).

The reason this post is titled &#8220;Unit testing angular with karma&#8221; and not &#8220;Unit testing JS apps with karma&#8221; is because in my opinion Karma does a lot of things that only make sense for Angular apps. The thing that most caught my attention is that when you use Karma for unit testing you have to load all files in to the browser at once. If you have a JS file that depends on other JS files(loads them using AMD) there is no way to mock the dependencies. This would make unit testing impossible if it wasn&#8217;t because of Angular&#8217;s dependency injection system. At the end, this means that you can mock all dependencies, but you end up loading stuff you don&#8217;t need. In practical terms this is irrelevant because unit tests run very fast anyway.

<!--more-->

## Basic example

Lets start with a tiny project with these folders:

```
mkdir karma-basic
cd karma-basic
mkdir js
mkdir tests/unit/ -p
```

Now, lets create a tiny angular app:

```
bower install angular
touch index.html
touch js/app.js
```

This is the content of our index.html file:

```html
<html>
<body>
  <script src="bower_components/angular/angular.min.js"></script>
  <script src="js/app.js"></script>
  <div ng-app="TestApp" ng-controller="TestController">
    {{hi}}
  </div>
</body>
</html>
```

And this is js/app.js:

```js
angular.module('TestApp', [])
.controller('TestController', function($scope) {
  $scope.hi = 'hello';
});
```

I know there are a lot of things wrong with both of those files, but that is not what we are here for today.

Now, lets create our first test. To do this we have to first install karma. Go to karma-basic folder and run:

```
npm install karma
cd tests/unit
../../node_modules/karma/bin/karma init
```

You will be prompted for some options. At the end this file was generated for me:

```js
// Karma configuration
// Generated on Mon May 18 2015 18:58:27 GMT+0200 (CEST)

module.exports = function(config) {
  config.set({
    basePath: '../..',
    frameworks: ['jasmine'],
    files: [
      'bower_components/angular/angular.js',
      'bower_components/angular-mocks/angular-mocks.js',
      'bower_components/sinon/index.js',
      'js/**/*.js',
      'tests/unit/js/**/*.spec.js'
    ],
    reporters: ['progress'],
    port: 9877,
    colors: true,
    logLevel: config.LOG_INFO,
    browsers: ['Chrome'],
    singleRun: true
  });
};
```

And you can run the tests with this command:

```
./node_modules/karma/bin/karma start tests/unit/karma.conf.js
```

After running that command you will probably get something like this:

```
Chrome 40.0.2214 (Linux): Executed 0 of 0 ERROR (0.001 secs / 0 secs)
```

Lets fix that by creating a dummy test (tests/unit/js/test.spec.js):

```js
describe('something', function() {
  it('does something', function() {
  });
});
```

To make things a little more useful we also need an assertion library. I like to use [proclaim](https://www.npmjs.com/package/karma-proclaim) with Karma because it&#8217;s really easy to set up:

```
npm install karma-proclaim
```

Modify karma.conf.js to use proclaim:

```js
// Karma configuration
// Generated on Mon May 18 2015 18:58:27 GMT+0200 (CEST)

module.exports = function(config) {
  config.set({
    basePath: '../..',
    frameworks: ['jasmine', 'proclaim'],
    files: [
      'bower_components/angular/angular.js',
      'js/**/*.js',
      'tests/unit/js/**/*spec.js'
    ],
    reporters: ['progress'],
    port: 9877,
    colors: true,
    logLevel: config.LOG_INFO,
    browsers: ['Chrome'],
    singleRun: true
  });
};
```

And start using it:

```js
describe('something', function() {
  it('does something', function() {
    proclaim.ok(false);
  });
});
```

We have now a very simple testing suite ready, but we need to write some tests. There are different strategies for testing different pieces of the angular ecosystem (controllers, filters, directives, &#8230;). [Testing strategies for Angular](https://docs.angularjs.org/guide/unit-testing) are already pretty well documented so I will just show an example with our controller.

Lets say we want to create a method that when passed a string it redirects to that URL, and when passed a number it alerts it. I&#8217;m using this example because it will allow me to show how dependency injection works with tests. Lets start by writing the tests:

```js
describe('TestController', function() {
  beforeEach(module('TestApp'));

  var $controller;
  var controller;
  var $window;
  var $location;

  beforeEach(inject(function(_$controller_) {
    $controller = _$controller_;

    $window = {
      alert: sinon.spy()
    };

    $location = {
      path: sinon.spy()
    };

    controller = $controller('TestController', {
      '$window': $window,
      '$location': $location
    });
  }));

  describe('doesStuff', function() {
    it('alerts number', function() {
      controller.doesStuff(4);

      proclaim.isTrue($window.alert.calledOnce);
      proclaim.isFalse($location.path.called);
    });

    it('redirects to string', function() {
      controller.doesStuff('hello');

      proclaim.isFalse($window.alert.calledOnce);
      proclaim.isTrue($location.path.called);
    });
  });
});
```

If you try to run it, this will of course fail. We need to write the code to make it pass:

```js
angular.module('TestApp', [])
.controller('TestController', function($window, $location) {
  this.doesStuff = function(param) {
    if (typeof param === 'string') {
      $location.path(param);
    } else {
      $window.alert(param);
    }
  };
});
```

And now karma passes:

```
[anovelo@localhost karma-basic]$ ./node_modules/karma/bin/karma start tests/unit/karma.conf.js
INFO [karma]: Karma v0.12.31 server started at http://localhost:9877/
INFO [launcher]: Starting browser Chrome
INFO [Chrome 40.0.2214 (Linux)]: Connected on socket g9kuCxG5jKaTJbWqWxvj with id 4481575
Chrome 40.0.2214 (Linux): Executed 2 of 2 SUCCESS (0.025 secs / 0.021 secs)
```

## RequireJS

Usually when I unit test a JS app that uses RequireJS I like to mock the dependencies passed to the **define** function used to declare a module. This is not possible with karma, but since AngularJS uses dependency injection, this is not a huge problem.

Making Angular work with RequireJS requires some configuration. Lets start by having our app use RequireJS:

```js
define([], function() {
  angular.module('TestApp', [])
  .controller('TestController', function($window, $location) {
    this.doesStuff = function(param) {
      if (typeof param === 'string') {
        $location.path(param);
      } else {
        $window.alert(param);
      }
    };
  });
});
```

That was easy. Now we need to modify karma.conf:

```js
module.exports = function(config) {
  config.set({
    basePath: '../..',
    frameworks: ['jasmine', 'proclaim'],
    files: [
      'bower_components/angular/angular.js',
      'bower_components/angular-mocks/angular-mocks.js',
      'bower_components/sinon/index.js',
      'bower_components/requirejs/require.js',
      'tests/unit/test-main.js',
      {pattern: 'js/**/*.js', included: false},
      {pattern: 'tests/unit/js/**/*spec.js', included: false}
    ],
    reporters: ['progress'],
    port: 9877,
    colors: true,
    logLevel: config.LOG_INFO,
    browsers: ['Chrome'],
    singleRun: true
  });
};
```

The only thing that changed here are lines 9 to 12. Line 9 loads RequireJS in the browser. Lines 11 and 12 tell karma that it shouldn&#8217;t load the files until they are requested by the browser(which will be done by RequireJS). Line 10 is a special configuration file that tells karma which files are the tests we want to run and also configures RequireJS. The contents of that file are:

```js
window.__karma__.loaded = function() {};

var tests = Object.keys(window.__karma__.files).filter(function(file) {
  return /spec\.js/.test(file);
});

requirejs.config({
  baseUrl: 'base/js/',
  deps: tests,
  callback: window.__karma__.start
});
```

Lastly we need to wrap our test in a define:

```js
define(['app'], function() {
  describe('TestController', function() {
    beforeEach(module('TestApp'));

    var $controller;
    var controller;
    var $window;
    var $location;

    beforeEach(inject(function(_$controller_) {
      $controller = _$controller_;

      $window = {
        alert: sinon.spy()
      };

      $location = {
        path: sinon.spy()
      };

      controller = $controller('TestController', {
        '$window': $window,
        '$location': $location
      });
    }));

    describe('doesStuff', function() {
      it('alerts number', function() {
        controller.doesStuff(4);

        proclaim.isTrue($window.alert.calledOnce);
        proclaim.isFalse($location.path.called);
      });

      it('redirects to string', function() {
        controller.doesStuff('hello');

        proclaim.isFalse($window.alert.calledOnce);
        proclaim.isTrue($location.path.called);
      });
    });
  });
});
```

And that is it. We are ready to write karma tests using RequireJS.
