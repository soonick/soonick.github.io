---
id: 1840
title: AngularJS vocabulary
date: 2014-10-30T04:24:12+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1840
permalink: /2014/10/angularjs-vocabulary/
tags:
  - angularjs
  - design_patterns
  - javascript
  - programming
---
I have been playing with AngularJS for some time now and I&#8217;m still a little confused with the vocabulary they use. For that reason I decided to list the most common &#8220;things&#8221; that are part of an AngularJS app and explain what they are.

## Module

A module is a container for all the other &#8220;things&#8221;(controllers, directives, filters, etc) that are part of an AngularJS app. There is usually and application level module for the whole app and smaller modules for different components. You can create a module using:

```js
var someModule = angular.module('someModule', []);
```

<!--more-->

The second argument is an array of dependencies for this module. It is important to include an empty array when there are no dependencies because omitting it means that you want to retrieve an already created module. This would have the same effect as the previous example:

```js
angular.module('someModule', []);
var someModule = angular.module('someModule');
```

You can use the ng-app attribute to tell AngularJS what part of the markup it will be responsible for. If you don&#8217;t have any reason not to, it is usual to add this attribute to the HTML element. If for some reason you want AngularJS to run just in a piece of your page you can simple add it to any element.

```html
<html data-ng-app="someModule">
</html>
```

I use data-ng-app instead of ng-app just because I like to keep my HTML valid. Both work exactly the same way.

<a href="https://docs.angularjs.org/guide/module" title="Learn more about AngularJS modules" target="_blank">Learn more about AngularJS modules</a>

## Controller

If you are familiar with MVC you know what a controller is. The controller is the middle man between your models and your views. The reason I&#8217;m talking about them here is because in AngularJS they are attached to the DOM in a way that limits their scope. That means that if you attach a controller to a DOM element the controller will(should) only control what is inside that DOM element. Controllers are attached to modules as follows:

```js
angular.module('someModule', [])
.controller('someController', function() {
  // Controller code goes here
});
```

Then you can attach it to the DOM like this:

```html
<div data-ng-controller="someController">
</div>
```

Setting the controller in an specific DOM element limits the model scope to that of the controller. I&#8217;ll talk more about scopes ahead. Another important thing to mention is that controllers need to be inside an app. More specifically a dom element using ng-controller needs to be inside a dom element using ng-app for it to work.

<a href="https://docs.angularjs.org/guide/controller" title="Learn more about AngularJS controllers" target="_blank">Learn more about AngularJS controllers</a>

## Scope

A scope is the context in which a part of your application will be executed. All your model variables are added to a scope and can be retrieved from it. Controllers have a scope associated with them that you can access like this:

```js
angular.module('someModule', [])
.controller('someController', function($scope) {
  $scope.variable = 5; // I just added a variable to the scope
});
```

This scope is used on your data bindings like this:

```html
<div data-ng-controller="someController">{{ "{{variable" }}}}</div>
```

The example above will show the number 5.

<a href="https://docs.angularjs.org/guide/scope" title="Learn more about AngularJS scopes" target="_blank">Learn more about AngularJS scopes</a>

## Behavior

Behaviors are methods you add to a scope and are then made accessible to your view. Here is a simple example of how to create one:

```js
angular.module('someModule', [])
.controller('someController', function($scope) {
  $scope.greet = function() {
    return 'hello';
  }
});
```

And this is how you access it from your view:

```html
<div data-ng-controller="someController">{{ "{{greet()" }}}}</div>
```

<a href="https://docs.angularjs.org/guide/controller" title="Learn more about AngularJS behaviors" target="_blank">Learn more about AngularJS behaviors</a>

## Directive

Directives are markers on HTML templates that tell AngularJS to attach some functionality to that element or to transform it in some way. Directives can be applied as HTML elements, attributes or class names. AngularJS comes with some directives built in, we have seen already ng-app and ng-controller in action.

You can create custom directives as follows:

```js
angular.module('someModule', [])
.directive('someDirective', function() {
  return {
    restrict: 'ACE',
    template: 'hello'
  }
});
```

And can be used in any of these ways:

```html
<some-directive></some-directive>
<span some-directive=""></span>
<span class="some-directive: ;"></span>
```

<a href="https://docs.angularjs.org/guide/directive" title="Learn more about AngularJS directives" target="_blank">Learn more about AngularJS directives</a>

## Filter

Filters are used to format values that are going to be displayed to the user. There are built-in filters that can be applied to a value in a template using a pipe:

```js
{{ "{{12.5 | currency" }}}}
```

You can use the filter method to create custom filters:

```js
angular.module('someModule', [])
.filter('some', function() {
  return function(input) {
    return input.substring(1);
  };
});
```

And you can apply it like this:

```
{{ "{{'hello' | some" }}}}
```

The example above will print &#8220;ello&#8221;.

<a href="https://docs.angularjs.org/guide/filter" title="Learn more about AngularJS filters" target="_blank">Learn more about AngularJS filters</a>

## Service

Services are singleton objects that are used to organize and share code within an app. There are many built-in services that come packed with AngularJS. You can easily access services from controllers, filters, directives or other services. Here is an example:

```js
angular.module('someModule', [])
.controller('someController', function($location) {
  console.log($location.path());
});
```

The example above uses the $location service to log the current URL in the console.

You can also create your own services using the factory method:

```js
angular.module('someModule', [])
.factory('someService', function() {
  return {
    sayHi: function() {
      console.log('hi');
    }
  }
})
.controller('someController', function(someService) {
  someService.sayHi();
});
```

In the example above we created a new service that is being used by our controller. The final result is the message &#8220;hi&#8221; being logged in the console

<a href="https://docs.angularjs.org/guide/services" title="Learn more about AngularJS services" target="_blank">Learn more about AngularJS services</a>

This is a very shallow explanation of what the parts that make an AngularJS are. I created it mostly so I can have conversations with other AngularJS developers and understand what they mean when they talk about a service or a directive. I recommend to follow the links to learn more about what each of these can do.
