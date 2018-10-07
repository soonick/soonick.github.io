---
id: 863
title: JS Dependency Management
date: 2013-05-09T05:04:43+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=863
permalink: /2013/05/js-dependency-management/
categories:
  - Javascript
tags:
  - dependecy management
  - javascript
  - programming
  - require.js
---
It is common for JavaScript applications to depend on libraries, or JavasScript files to depend on other files. The way we usually deal with this problem is by manually including the files we depend on on our document:

```html
<script src="jquery.js"></script>
<script>
$(function() {
  // Do something
});
</script>
```

To deal with this problem some people came out with the Asynchronous Module Definition (AMD) API, which allows us to specify modules or files that our code depends on and have them automatically loaded for us. The API defines one global function **require** that allows you to define the dependencies of the module and it&#8217;s functionality. Something like this:

```html
<script>
require(['jquery'], function($) {
  $(function() {
    // Do something
  });
});
</script>
```

<!--more-->

This doesn&#8217;t look like much for this simple example, but some things are clear. In the first argument we are defining which modules our current module depends on, in this case, jquery. The second argument defines the functionality for this module. It is also important to notice, that the anonymous function receives an argument: **$**. This argument is the only way in which the required module is made available to the current module. This helps avoid polluting the global namespace. In this example the require function will first check if the jquery module is loaded, if it is not it will asynchronously load it and then it will execute the function when it is finished loading.

## Working example

I am just starting to explore JS dependency management so I am not sure which library to use. There are two I am particulary interested in: [RequireJS](http://requirejs.org/ "RequireJS") and [InjectJS](http://www.injectjs.com/ "InjectJS"), so to help me decide I will write my example using both libraries.

To start we need to get the libraries, which you can get from [InjectJS download page](http://www.injectjs.com/download/ "InjectJS") and [RequireJS download page](http://requirejs.org/docs/download.html "RequireJS"). RequireJS will give you a single JS file (which I&#8217;ll refer to as require.js) while InjectJS will give you a zip file. You will need to unzip it and grab inject.min.js (which I&#8217;ll just refer to as inject.js). I&#8217;ll also use jQuery in my examples so you may want to download it.

I will use this folder structure for my examples:

```
example/
 |---js/
 |    |---lib/
 |    |    |---configure_require.js
 |    |    |---require.js
 |    |    |---configure_inject.js
 |    |    |---inject.js
 |    |    +---jquery.js
 |    |
 |    |---ex1.js
 |    +---ex2.js
 |
 |---require.html
 +---inject.html
```

## Require.js

Lets start by creating our html page:

```html
<html>
  <head>
    <title>Require.js example</title>
  </head>
  <body>
    <script data-main='js/lib/configure_require.js' src='js/lib/require.js'></script>
    <script src='js/ex1.js'></script>
  </body>
</html>
```

We need to include require.js to get the dependency management we want. The idea is that we will be loading ex1.js which depends on jquery.js without having to add another script tag to our html page.

The **data-main** attribute on the require.js attribute tells require.js to load the specified file immediately after require.js is loaded. This is the content of js/lib/configure_require.js:

```js
require.config({
  paths: {
    'jquery': 'js/lib/jquery.js'
  }
});
```

What we are doing here is telling require.js to define a module named **jquery** that will be the content of **js/lib/jquery.js**. So basically we made a module named jquery that is jquery.

Now we can use that module anywhere. Here is ex1.js:

```js
require(['jquery'], function($) {
    $(function() {
        $('body').css('background', '#000');
    });
});
```

At the end, that style will be added to the body, and we will have a black page.

## Inject.js

Making the same example work using inject.js gave me a few issues:

  * I couldn&#8217;t run my example by just opening an html file in the browser, so I had to setup a local web server to make it work
  * For some reason it was breaking when I tried to use the minified version of jQuery, so I had to download the development version

inject.html:

```html
<html>
  <head>
    <title>Inject.js example</title>
  </head>
  <body>
    <script src='js/lib/inject.js'></script>
    <script src='js/lib/configure_inject.js'></script>
    <script src='js/ex2.js'></script>
  </body>
</html>
```

You can see here that inject doesn&#8217;t have a way (that I know of) to automatically execute a file after loading itself. For that reason I inlcuded a script tag to add configure_inject.js.

configure_inject.js:

```js
Inject.setModuleRoot('js');

Inject.addRule(/^jquery$/, {
  path: 'lib/jquery.js',
  useSuffix: false,
  pointcuts: {
    afterFetch: function (next, text) {
      next(null, [
        text,
        'module.exports = jQuery.noConflict();'
      ].join('\n'));
    }
  }
});
```

This file is a little more complicated than the configuration file for require.js. The first line defines the base directory for our modules. This allows us to reference a module without having to specify the folder.

Inject.addRule is a mechanism to modify files after they are fetch. This mechanism can be used to load libraries that are not AMD or CommonJS compliant. We use this to load jquery and then assign it to a module so we can have access to it.

ex2.js:

```js
require(['jquery'], function($) {
  $(function() {
    $('body').css('background', '#000');
  });
});
```

## Conclusion

While doing this exercise, it took me a lot more time to make the inject.js example work. I guess this is because Require.js is a lot more well known so there is more documentation about it. Taking a very quick look at Inject.js documentation I also noticed that they give you a lot more flexibility and options to do many different things in many different ways, which in some scenarios may be what you need. In the meantime I am probably sticking to Require.js because of it&#8217;s ease of implementation.
