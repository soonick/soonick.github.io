---
id: 3171
title: Introduction to Reworkcss
date: 2015-09-16T17:27:35+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3171
permalink: /2015/09/introduction-to-reworkcss/
tags:
  - css
  - productivity
  - programming
---
Reworkcss is an easy to extend CSS processor that has some cool features I want to explore. Lets start by installing it:

```
mkdir ~/rework
cd ~/rework
npm install rework
```

Rework has a very simple API. It receives a string of CSS code and it outputs a rework object. You can then run plugins on this instance and finally output the result:

```js
var rework = require('rework');
var plugin = require('plugin');

rework({source: 'style.css'})
  .use(plugin)
  .toString();
```

The interesting part happens on the plugins so lets look at some of the most interesting ones.

<!--more-->

## at2x

```
npm install rework-plugin-at2x
```

Create a file called styles.css:

```css
.logo {
  background-image: url('component.png') at-2x;
}
```

And create a rework.js file:

```js
var rework = require('rework');
var at2x = require('rework-plugin-at2x');
var fs = require('fs');

var file = fs.readFileSync('./style.css', 'utf8');

var out = rework(file).use(at2x()).toString();

console.log(out);
```

Then run:

```
node rework.js
```

And you&#8217;ll get this result:

```css
.logo {
  background-image: url('component.png');
}

@media (min--moz-device-pixel-ratio: 1.5), (-o-min-device-pixel-ratio: 3/2), (-webkit-min-device-pixel-ratio: 1.5), (min-device-pixel-ratio: 1.5), (min-resolution: 144dpi), (min-resolution: 1.5dppx) {
  .logo {
    background-image: url("component@2x.png");
    background-size: contain;
  }
}
```

## colors

```
npm install rework-plugin-colors
```

Helper for writing colors in the form: rgba(#000, .3)

style.css:

```css
.logo {
  background-color: rgba(#000, .5);
}
```

rework.js:

```js
var rework = require('rework');
var colors = require('rework-plugin-colors');
var fs = require('fs');

var file = fs.readFileSync('./style.css', 'utf8');

var out = rework(file).use(colors()).toString();

console.log(out);
```

output:

```css
.logo {
  background-color: rgba(0, 0, 0, .5);
}
```

## clearfix

```
npm install rework-clearfix
```

Easily add clearfix to a container.

style.css:

```css
.container {
  clear: fix;
}
```

rework.js:

```js
var rework = require('rework');
var cf = require('rework-clearfix');
var fs = require('fs');

var file = fs.readFileSync('./style.css', 'utf8');

// Note that this is cf and not cf()
// Plugins don't seem to be standardized
var out = rework(file).use(cf).toString();

console.log(out);
```

output:

```css
.container {
  *zoom: 1;
}

.container:before,
.container:after {
  content: " ";
  display: table;
}

.container:after {
  clear: both;
}
```

## inherit

```
npm install rework-inherit
```

Allows for extend functionality similar to that of sass and less.

style.css:

```css
.some {
  color: #f00;
}

.other {
  inherit: .some;
}
```

rework.js:

```js
var rework = require('rework');
var inherit = require('rework-inherit');
var fs = require('fs');

var file = fs.readFileSync('./style.css', 'utf8');

var out = rework(file).use(inherit()).toString();

console.log(out);
```

output:

```css
.some,
.other {
  color: #f00;
}
```

For more complex examples look at the [rework-inherit documentation](https://github.com/reworkcss/rework-inherit/).

## function

```
npm install rework-plugin-function
```

Allows you to create custom functions that can be used in your css.

style.css:

```css
.thing {
  background-image: myImage(tacos);
}
```

rework.js:

```js
var rework = require('rework');
var func = require('rework-plugin-function');
var fs = require('fs');

var file = fs.readFileSync('./style.css', 'utf8');

var out = rework(file).use(func({myImage: myImage}))
    .toString();

function myImage(img) {
  return 'url(/img/path/' + img + '.png)';
}

console.log(out);
```

output:

```css
.thing {
  background-image: url(/img/path/tacos.png);
}
```

## More

You can find more plugins in npm by searching for the rework keyword.
