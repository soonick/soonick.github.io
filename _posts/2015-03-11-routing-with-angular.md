---
id: 2699
title: Routing with angular
date: 2015-03-11T20:28:27+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2699
permalink: /2015/03/routing-with-angular/
tags:
  - javascript
  - programming
---
Angular&#8217;s ngRoute is useful when building single page apps with multiple views. It allows you to easily load a template into the screen and initialize the controller associated with it.

This is not only helpful to keep your code organized by having different controllers for different screens, but also gives your users a way to create bookmarks that associate a URL in the address bar with the current content of your app. This is a piece of functionality that has always been part of the web(links), so it is a good a idea to keep it there so users don&#8217;t run into unexpected behavior.

<!--more-->

## How it works

Angular internally watches for **popstate** or **hashchange** events on the window. If any of these events are triggered, Angular broadcasts a **locationChangeStart** event that ngRoute then listens for.

If the URL matches any of the defined routes then it will proceed to load the correct template and execute the correct controller.

## How to use

You start by defining your routes using $routeProvider&#8217;s **when** method. You can also define a default route using **otherwise**. Here is an example of different ways to define routes:

```js
angular.module('routingApp', ['ngRoute'])
.config(['$routeProvider', function($routeProvider) {
    $routeProvider.when('/about/:someVar*', {
        controller: 'aboutController',
        template: '<h1>About page</h1>'
    }).when('/bye/:something', {
        controller: 'byeController',
        controllerAs: 'bye',
        templateUrl: 'bye.html'
    }).when('/home', {
        controller: 'homeController',
        template: function() {
            return 'You are home';
        }
    }).otherwise({
        redirectTo: '/home'
    });
}]).controller('aboutController', function(){})
.controller('homeController', function(){})
.controller('byeController', function(){});
```

The first route will match any route that starts with /about/, for example: /about/hello, /about/bye/world. the second route matches any route that has two segments and the first one is /bye/. For example /bye/jose and /bye/maria. The third one matches /home. If the URL doesn&#8217;t match any of the defined routes, the user will be redirected to /home.

I also demonstrate a few ways to load a template. You can use the template or the templateUrl option for this. Telling the app where you want your template to be is very easily done using ngView:

```html
<html ng-app="routingApp">
<body>
<div ng-view></div>
</body>
</html>
```

When you use placeholders in the URL it is most likely that you want to know what the exact value in the placeholder is. You can access those values using $routeParams:

```js
angular.module('routingApp', ['ngRoute'])
.config(['$routeProvider', function($routeProvider) {
    $routeProvider.when('/bye/:something', {
        controller: 'byeController',
        controllerAs: 'bye',
        template: 'Hello {{yourName}}!'
    });
}]).controller('byeController', ['$routeParams', '$scope',
function($routeParams, $scope) {
    $scope.yourName = $routeParams.something;
}]);
```

If you visit /bye/Adrian you will see a page with the text **Hello Adrian**.
