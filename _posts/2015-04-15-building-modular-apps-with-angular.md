---
id: 2758
title: Building modular apps with Angular
date: 2015-04-15T13:47:37+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2758
permalink: /2015/04/building-modular-apps-with-angular/
tags:
  - angularjs
  - bootstrapping
  - design_patterns
  - javascript
  - productivity
  - programming
---
Building modular apps with Angular is not an easy task. Since I arrived into an Angular project a couple of months ago I&#8217;ve been struggling with our architecture, trying to make it modular in a way that makes sense, and it hasn&#8217;t been a walk in the park.

Lets try to build an example app to see what I&#8217;m talking about. For my example we are going to have a single page app with three screens:

  * Greetings screen &#8211; Contains links to mine and yours pages
  * Mine &#8211; Shows a list of my stuff and has a link to greetings page
  * Yours &#8211; Shows a list of your stuff and has a link to greetings page

These are the parts that will make our app:

  * App module
  * Greetings controller
  * Mine controller
  * Yours controller
  * Reusable list module

<!--more-->

If we put everything together it would look something like this:

```html
<html ng-app="myApp">
<body>
    <div ng-view></div>
    <script src="bower_components/angular/angular.js"></script>
    <script src="bower_components/angular-route/angular-route.js"></script>
    <script src="js/list.js"></script>
    <script>
        angular.module('myApp', ['adrian.awesomeList', 'ngRoute'])
        .config(['$routeProvider', function($routeProvider) {
          $routeProvider.otherwise({
            templateUrl: 'templates/main.html',
            controller: 'MainController'
          });
        }])
        .controller('MainController', function() {});

        angular.module('myApp')
        .config(['$routeProvider', function($routeProvider) {
          $routeProvider.when('/mine', {
            templateUrl: 'templates/mine.html',
            controller: 'MineController'
          });
        }])
        .controller('MineController', function() {});

        angular.module('myApp')
        .config(['$routeProvider', function($routeProvider) {
          $routeProvider.when('/yours', {
            templateUrl: 'templates/yours.html',
            controller: 'YoursController'
          });
        }])
        .controller('YoursController', function() {});
    </script>
</body>
</html>
```

I use a somewhat verbose syntax because I&#8217;m going to divide this in multiple files. For now, you can see that we are loading **js/lists.js** which is a reusable directive that is used in yours.html and mine.html. If we divided this into multiple files, our index.html would end up looking something like this:

```html
<html ng-app="myApp">
<body>
    <div ng-view></div>
    <script src="bower_components/angular/angular.js"></script>
    <script src="bower_components/angular-route/angular-route.js"></script>
    <script src="js/list.js"></script>
    <script src="js/main.js"></script>
    <script src="js/mine.js"></script>
    <script src="js/yours.js"></script>
</body>
</html>
```

As you should know if you have been using angular for a while, the order in which you include the scripts matters. Because mine.js and yours.js use myApp module, main.js has to be included before.

Our app looks a little better now, but having to include all the scripts in the index page and keep them in the right order is not the right way to build web apps. Now a days dependencies are better manager by something like Require.js. Lets look at how we can use it for this scenario. The process is not super hard, but there are some things we have to keep in mind. First of all, we only need to declare one script tag for our app:

```html
<html>
<body>
    <div ng-view></div>
    <script src="bower_components/angular/angular.js"></script>
    <script src="bower_components/angular-route/angular-route.js"></script>
    <script src="bower_components/requirejs/require.js" data-main="js/main"></script>
</body>
</html>
```

Now it starts becoming a little tricky. Main.js will be our entry point because it declares the main route for our app. Previously we had mine.js and yours.js depend on the myApp module and declare controllers on it. Now, because they are going to be loaded before myApp module exists we will need to make them their own module:

```js
define(['list'], function() {
  angular.module('myApp.yours', ['adrian.awesomeList', 'ngRoute'])
  .config(['$routeProvider', function($routeProvider) {
    $routeProvider.when('/yours', {
      templateUrl: 'templates/yours.html',
      controller: 'YoursController'
    });
  }])
  .controller('YoursController', function() {});
});
```

Instead of declaring a route and controller in myApp module, we create a new module. Main.js will then depend on our new modules:

```js
define(['mine', 'yours'], function() {
  var app = angular.module('myApp', ['ngRoute', 'myApp.mine', 'myApp.yours']);
  app.config(['$routeProvider', function($routeProvider) {
    app.$routeProvider = $routeProvider;
    $routeProvider.otherwise({
      templateUrl: 'templates/main.html',
      controller: 'MainController'
    });
  }])
  .controller('MainController', function() {});

  angular.bootstrap(document.getElementsByTagName('html')[0], ['myApp']);
});
```

Things look a lot better now. The myApp module depends on myApp.mine and myApp.yours. Since we don&#8217;t use adrian.awesomeList in myApp, we have moved that dependency to myApp.mine and myApp.yours.

There is one other aspect of modular web apps that Angular makes particularly difficult and that is lazy loading. I will cover lazy loading in [another post](http://ncona.com/2015/04/building-modular-apps-with-angular-part-2/).
