---
id: 3193
title: Using Webpack with React
date: 2015-10-07T06:43:41+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3193
permalink: /2015/10/using-webpack-with-react/
categories:
  - Javascript
tags:
  - javascript
  - productivity
  - programming
  - react
  - webpack
---
Webpack is a module bundler similar to Browserify but with a different philosophy. Browserify was born with the goal of making it possible for developers to write CommonJS(node code) in the browser. Webpack allows you to write CommonJS but it also allows you to use other formats that might not be supported by node. One thing that makes it interesting is that since it doesn&#8217;t try to comply with CommonJS, it allows developers to declare dependencies on files that are not necessarily JS, which can be helpful to create self contained components.

## Getting started with Webpack

Lets create a simple React app using Webpack. We can start by creating our HTML entry point:

```
mkdir ~/webpack
cd ~/webpack
touch index.html
```

<!--more-->

And add this to index.html:

```html
<html>
<body>
  <div id="content"></div>
  <script src="out.js"></script>
</body>
</html>
```

Now we need a few tools for Webpack and react:

```
npm install react webpack jsx-loader
```

We are ready to write some JavaScript(Actually JSX). Create a file named main.jsx and add this content:

```js
var React = require('react');

var Hello = React.createClass({
  render: function() {
    return (
      <div>Hello</div>
    );
  }
});
React.render(
  <Hello />,
  document.getElementById('content')
);
```

Use Webpack to transpile this file to JavaScript:

```
./node_modules/webpack/bin/webpack.js --module-bind jsx main.jsx out.js
```

Now you can open the index.html file in your browser and you will see the component rendered.

## webpack.config.js

You most likely don&#8217;t want to remember that command with all the arguments. You can create a Webpack configuration file that will remember those things for you. Create a file named webpack.config.js and add this content:

```js
module.exports = {
  entry: './main.jsx',
  output: {
    filename: 'out.js'
  },
  module: {
    loaders: [
      {
        test: /\.jsx$/,
        loader: 'jsx-loader'
      }
    ]
  }
}
```

With this file in place it is enough to use the webpack command to generate out.js:

```
./node_modules/webpack/bin/webpack.js
```

## Browsersync

While developing it is really helpful to have browsersync update the browser every time a file is changed. Doing this with Webpack is very easy:

```
npm install browser-sync-webpack-plugin
```

And then modify webpack.config.js:

```js
var BrowserSyncPlugin = require('browser-sync-webpack-plugin');

module.exports = {
  entry: './main.jsx',
  output: {
    filename: 'out.js'
  },
  module: {
    loaders: [
      {
        test: /\.jsx$/,
        loader: 'jsx-loader'
      }
    ]
  },
  plugins: [
    new BrowserSyncPlugin({
      host: 'localhost',
      port: 3000,
      server: { baseDir: ['.'] }
    })
  ]
}
```

Then start browserify with:

```
./node_modules/webpack/bin/webpack.js --watch
```

Now every time a file is modified, it will be compiled and the browser will be refreshed.
