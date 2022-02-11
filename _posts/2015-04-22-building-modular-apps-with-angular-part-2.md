---
id: 2821
title: 'Building modular apps with Angular - Part 2'
date: 2015-04-22T19:00:26+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2821
permalink: /2015/04/building-modular-apps-with-angular-part-2/
tags:
  - design_patterns
  - javascript
  - programming
---
In a previous post I explained how to [start modularizing Angular apps](http://ncona.com/2015/04/building-modular-apps-with-angular/ "Building modular apps with Angular"). 

I&#8217;m going to improve the app I built in my example so it now lazy loads the modules it needs when you change routes. The end result will be the main page only downloading main.js and whenever you change to /yours or /mine, the respective file will be loaded with its corresponding dependencies. This should be an easy task, but angular makes it really complicated.

Lets try the obvious approach. First of all we need to change main to not load mine and yours:

```js
define([], function() {
  var app = angular.module('myApp', ['ngRoute']);
  app.config(['$routeProvider', function($routeProvider) {
    $routeProvider.otherwise({
      templateUrl: 'templates/main.html',
      controller: 'MainController'
    });
  }])
  .controller('MainController', function() {});

  angular.bootstrap(document.getElementsByTagName('html')[0], ['myApp']);
});
```

<!--more-->

We changed it so require doesn&#8217;t download any dependencies and so that the module doesn&#8217;t have any dependencies either. This is the content of templates/main.html:

```html
<h1>Greetings</h1>
<a href="#/mine">Mine</a>
<a href="#/yours">Yours</a>
```

If you load the app and click on any of the links, nothing will happen because no routes have been registered for them. To be able to lazy load modules based on the route change, we have to be able to detect a route change and load the necessary modules. Lets put this functionality in the main module for now:

```js
define([], function() {
  var app = angular.module('myApp', ['ngRoute']);
  app.config(['$routeProvider', function($routeProvider) {
    $routeProvider.otherwise({
      templateUrl: 'templates/main.html',
      controller: 'MainController'
    });
  }])
  .controller('MainController', ['$rootScope', '$location',
  function($rootScope, $location) {
    function loadRouteModule() {
      var module = $location.path().substring(1);
      require([module], function() {
        // Do something
      });
    }
    $rootScope.$on('$routeChangeStart', loadRouteModule);
  }]);

  angular.bootstrap(document.getElementsByTagName('html')[0], ['myApp']);
});
```

This will take care of loading the correct files for the route, but since config only gets executed on application bootstrap, it will never actually register the route. This is how yours.js looks now:

```js
define(['list'], function() {
  angular.module('myApp.yours', ['adrian.awesomeList', 'ngRoute'])
  .config(['$routeProvider', function($routeProvider) {
    $routeProvider.when('/yours', {
      templateUrl: 'templates/yours.html',
      controller: 'YoursController'
    });
  }])
  .controller('YoursController', function() {
  });
});
```

My next idea was to use the app injector to get an instance of $routeProvider and then register the route when the module is loaded. It turns out it is impossible to get a reference to $routeProvider after the bootstrap. The only alternative around this is very ugly. Save a reference to the routeProvider somewhere that is globally accessible and then use it:

```js
define([], function() {
  var app = angular.module('myApp', ['ngRoute']);
  app.config(['$routeProvider', function($routeProvider) {
    app.$routeProvider = $routeProvider;
    app.loadedModules = {};
    $routeProvider.otherwise({
      templateUrl: 'templates/main.html',
      controller: 'MainController'
    });
  }])
  .controller('MainController', ['$rootScope', '$location',
  function($rootScope, $location) {
    function loadRouteModule(e) {
      var module = $location.path().substring(1);
      if (!app.loadedModules[module]) {
        app.loadedModules[module] = true;
        e.preventDefault();
        require([module], function() {
          window.location = '/#/' + module;
        });
      }
    }
    $rootScope.$on('$routeChangeStart', loadRouteModule);
  }]);

  angular.bootstrap(document.getElementsByTagName('html')[0], ['myApp']);
});
```

On line 4 I added a reference to $routeProvider that I can access from anywhere. I also added some logic on the loadRouteModule function so it doesn&#8217;t try to change the route until the module has been loaded. I would imagine now I only need to use the $routerProvider reference and I&#8217;m ready to go:

```js
define(['list'], function() {
  var app = angular.module('myApp');
  app.$routeProvider.when('/yours', {
    templateUrl: 'templates/yours.html',
    controller: 'YoursController'
  });
  app.controller('YoursController', function() {});
});
```

When I tried to run this I got an error on my console telling me that YoursController wasn&#8217;t defined. A little reading taught me that once the app has been bootstrapped, you can&#8217;t use module.controller to register controllers. You have to use controllerProvider instead. That kind of works, but the list directive is not working. This is because this directive wasn&#8217;t specified as a dependency of the app. Since this dependency is being lazy loaded we can&#8217;t do this at bootstrap.

I couldn&#8217;t really find a way to walk around this issue so I had to load my directive from the main app. At the end this is how it looked like:

index.html

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

main.js

```js
define(['list'], function() {
  var app = angular.module('myApp', ['ngRoute', 'adrian.awesomeList']);
  app.config(['$routeProvider', '$controllerProvider',
  function($routeProvider, $controllerProvider) {
    app.$routeProvider = $routeProvider;
    app.$controllerProvider = $controllerProvider;
    app.loadedModules = {};
    $routeProvider.otherwise({
      templateUrl: 'templates/main.html',
      controller: 'MainController'
    });
  }])
  .controller('MainController', ['$rootScope', '$location',
  function($rootScope, $location) {
    function loadRouteModule(e) {
      var module = $location.path().substring(1);
      if (!app.loadedModules[module]) {
        app.loadedModules[module] = true;
        e.preventDefault();
        require([module], function() {
          window.location = '/#/' + module;
        });
      }
    }
    $rootScope.$on('$routeChangeStart', loadRouteModule);
  }]);

  angular.bootstrap(document.getElementsByTagName('html')[0], ['myApp']);
});
```

yours.js

```js
define(['list'], function() {
  var app = angular.module('myApp');
  app.$routeProvider.when('/yours', {
    templateUrl: 'templates/yours.html',
    controller: 'YoursController'
  });
  app.$controllerProvider.register('YoursController', function() {});
});
```

list.js:

```js
define([], function() {
  function directive() {
    function templateFunction(element, attrs) {
      var vals = attrs.vals.split(' ');
      var items = '';

      for (var h in vals) {
        items += '<li>' + vals[h] + '</li>';
      }

      return '<ul>' + items + '</ul>';
    }

    return {
      template: templateFunction,
      restrict: 'E'
    };
  }

  angular.module('adrian.awesomeList', [])
  .directive('awesomeList', directive);
});
```

I&#8217;m not really happy with the solution, but at least now I can load files specific to a route on demand.
