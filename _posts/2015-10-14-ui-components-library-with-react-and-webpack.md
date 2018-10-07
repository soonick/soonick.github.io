---
id: 3158
title: UI components library with React and Webpack
date: 2015-10-14T14:32:50+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3158
permalink: /2015/10/ui-components-library-with-react-and-webpack/
categories:
  - Javascript
tags:
  - javascript
  - programming
  - react
  - webpack
---
I&#8217;m looking for the best way to create a UI components library. A few weeks ago I explored [React with Radium](http://ncona.com/2015/09/ui-components-library-with-react-and-radium/) and I have also considered [Polymer](http://ncona.com/2015/06/introduction-to-polymer/). This time I want to explore React with Webpack. I already wrote a guide to [using Webpack with React](http://ncona.com/2015/10/using-webpack-with-react/). In this article I&#8217;m going to focus on creating a component that bundles not only it&#8217;s JS and markup, but also it&#8217;s styles.

## CSS loader

To be able to declare CSS dependencies for our components, we need to use css-loader and style-loader. Installing them is easy:

```
npm install css-loader style-loader
```

<!--more-->

Now we can go ahead and create a simple component.

```
mkdir greeter
cd greeter
touch greeter.jsx greeter.css
```

greeter/greeter.css

```css
.greeter {
  color: #f00;
  font-weight: strong;
}
```

greeter/greeter.jsx

```js
var React = require('react');
var css = require('css!./greeter.css');

var Greeter = React.createClass({
  render: function() {
    return (
      <div className="greeter">Hello</div>
    );
  }
});

module.exports = Greeter;
```

And lets have our main file use this module.

main.jsx

```js
var React = require('react');
var Greeter = require('./greeter/greeter.jsx');

React.render(
  <Greeter />,
  document.getElementById('content')
);
```

Finally we need to modify webpack.config.js:

```js
var BrowserSyncPlugin = require('browser-sync-webpack-plugin');

module.exports = {
  entry: './main.jsx',
  output: {
    filename: 'out.js'
  },
  module: {
    loaders: [
      {test: /\.jsx$/, loader: 'jsx-loader'},
      {test: /\.css$/, loader: 'style-loader!css-loader'}
    ]
  },
  plugins: [
    new BrowserSyncPlugin({
      host: 'localhost',
      port: 3000,
      server: { baseDir: ['.'] }
    })
  ]
};
```

Now we can compile the files:

```
./node_modules/webpack/bin/webpack.js
```

If you look at the requests being made you will see that there is one request for the index.html file and another for out.js. The CSS is included inside of out.js. This is good because you make a single request, but there are some reasons why you might prefer to have your CSS in a different file:

  * out.js might get too big if it includes JS and CSS
  * CSS and JS can&#8217;t be cached sepparately, so if a change is made in any of the two, the whole file needs to be downloaded again

If for these or any other reason, you would prefer to have your CSS in a different file, you can configure Webpack to do it. Start by installing the extract-text plugin:

```
npm install extract-text-webpack-plugin
```

And modify webpack.config.js:

```js
var BrowserSyncPlugin = require('browser-sync-webpack-plugin');
var ExtractTextPlugin = require("extract-text-webpack-plugin");

module.exports = {
  entry: './main.jsx',
  output: {
    filename: 'out.js'
  },
  module: {
    loaders: [
      {test: /\.jsx$/, loader: 'jsx-loader'},
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract("style-loader", "css-loader")
      }
    ]
  },
  plugins: [
    new BrowserSyncPlugin({
      host: 'localhost',
      port: 3000,
      server: { baseDir: ['.'] }
    }),
    new ExtractTextPlugin("out.css")
  ]
};
```

Now, running Webpack will generate two files out.js and out.css. This means you need to modify index.html to load out.css:

```html
<html>
<body>
  <link rel="stylesheet" href="out.css">
  <div id="content"></div>
  <script src="out.js"></script>
</body>
</html>
```

When using any of these approaches, keep in mind that this is regular CSS with no encapsulation. Your best bet is to namespace your selectors per component to avoid collisions and minimize the leaking of styles.
