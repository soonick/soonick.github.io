---
id: 2393
title: Watching JS variables for changes
date: 2014-12-04T06:40:45+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2393
permalink: /2014/12/watching-js-variables-for-changes/
tags:
  - design_patterns
  - javascript
  - programming
---
After playing with angular for a while I got curios about how it can watch for variable changes and execute a function when these occur.

I did a little research and found out that all watches that you define in Angular are evaluated by an event loop that is entered when some event is triggered or apply is called.

That didn&#8217;t sound very interesting to me, but I did find some interesting alternatives.

<!--more-->

## defineProperty

This method allows you to define a property in an object that(among other things) will call a setter or a getter when you try to get or set a variable. Here is how it works:

```js
var a = {};
Object.defineProperty(a, 'watched', {
  get: function() {
    return this.value;
  },
  set: function(val) {
    console.log('magic');
    this.value = val;
  }
});
```

My example is very ugly but it does show you how the get method and the set method work. This is interesting because every time you do something like:

```js
a.watched = 5;
```

The set function gets called(&#8220;magic&#8221; is logged in the console) so you can here put any bindings you might need. Eli grey used this technique to create a [polyfill for the watch method](https://gist.github.com/eligrey/384583 "Watch polyfill") currently only supported by Gecko.

## The future

Since this has been considered a very useful feature, a similar technique is being proposed for ECMAScript 7. The formal definition hasn&#8217;t been finalized but you can find a very good introduction to it by Addy Osmani in his article: [Data-binding Revolutions with Object.observe()](http://www.html5rocks.com/en/tutorials/es7/observe/ "Object.observe")
