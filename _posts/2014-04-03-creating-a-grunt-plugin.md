---
id: 1570
title: Creating a grunt plugin
date: 2014-04-03T05:20:10+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1570
permalink: /2014/04/creating-a-grunt-plugin/
categories:
  - Javascript
tags:
  - grunt
  - javascript
  - productivity
---
I have been using grunt for a while but some of my tasks started getting a little ugly because I started abusing grunt-shell. Because of this I decided to create a grunt plugin for something that I need for most of my JS projects, unit tests.

To run unit test I use [VenusJS](http://www.venusjs.org/ "VenusJs") test runner for which there wasn&#8217;t a grunt plugin. So I decided to create one. [Grunt documentation](http://gruntjs.com/creating-plugins "Grunt documentation creating plugins") has some information on creating plugins but I felt there were some things missing.

This is the process I followed to create my plugin:

Install grunt-init by running:

```
npm install -g grunt-init
```

<!--more-->

Install a template if you haven&#8217;t done it before:

```
git clone git://github.com/gruntjs/grunt-init-gruntplugin.git ~/.grunt-init/gruntplugin
```

Create a folder, move there and create an empty plugin:

```
mkdir my-plugin
cd my-plugin
grunt-init gruntplugin
```

You will be asked a series very straight forward questions. After this you will see a bunch of files created for you in the current folder. The first thing I did after my files were generated was to strip all the things that I wasn&#8217;t going to need from package.json and Gruntfile.js.

I then modified my Gruntfile to have a venus task:

```json
my-plugin: {
  all: [
    'examples/arrays.spec.js'
  ]
}
```

And added it to my default task so it would run every time:

```js
grunt.registerTask('default', ['jshint', 'venus', 'nodeunit']);
```

If you try to run grunt now it will probably fail because the file **examples/arrays.spec.js** doesn&#8217;t exist. Before I create it I&#8217;m going to modify my task file (tasks/venus.js). I want to make my plugin a little more modular and testable, so I kept tasks/venus.js small and put most of my logic under tasks/lib/venus.js. This is how my tasks/venus.js looks:

```js
'use strict';

var venusRunner = require('./lib/VenusRunner');

module.exports = function(grunt) {
  grunt.registerMultiTask('venus', 'Run JS unit tests using venus', function() {
    var done = this.async();

    venusRunner.runVenusForFiles(this.files).then(function() {
      done(0);
    })['catch'](function() {
      grunt.log.error('There was an error');
      done(1);
    });
  });
};
```

You can see that this file is very small so it is very easy to read. Most of the work happens on venusRunner.runVenusForFiles(). This function will loop through all the given files (in this case examples/arrays.spec.js) and run venus against them. You can change your plugin to do whatever you want using node.

## Publishing

Once you are done you probably want to make your plugin available to the public. To do that you will need to create an account at [npm](https://www.npmjs.org/ "npm"). After you create your account you can publish very easily by running:

```
npm adduser
npm publish
```
