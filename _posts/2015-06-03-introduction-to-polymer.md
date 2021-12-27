---
id: 2770
title: Introduction to Polymer
date: 2015-06-03T08:26:41+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2770
permalink: /2015/06/introduction-to-polymer/
tags:
  - design_patterns
  - javascript
  - polymer
  - programming
---
## What is polymer

Polymer is a framework for creating [web components](http://www.w3.org/TR/components-intro/). Polymer is different than other web frameworks in that it only exists while browsers catch up on implementing the web components specification(which hasn&#8217;t been finalized).

Polymer doesn&#8217;t do much in helping you create single page apps. It doesn&#8217;t have a router, tools for internationalization or a nice abstraction for XMLHttpRequest. The way you build apps using polymer is by creating components that help you do those things.

<!--more-->

## Lets play

The best way to get to know polymer is to start using it. Start by creating a folder for the app and add a bower.json file. My file looks like this:

```json
{
  "name": "polymer",
  "version": "0.0.0",
  "authors": [
    "Adrian <mymail@something.exe>"
  ],
  "license": "MIT",
  "dependencies": {
    "polymer": "~1.0.2"
  }
}
```

Now, our index.html:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <!-- This file contains polyfills that allow web components to work
   in browsers that are not capable of handling web components by their own.
   When browsers implement the web components specification this file shouldn't
   be needed anymore -->
    <script src="bower_components/webcomponentsjs/webcomponents-lite.min.js"></script>
    <!-- Load my component -->
    <link rel="import" href="ncona-component.html">
  </head>
  <body>
    <!-- Use my component -->
    <ncona-component></ncona-component>
    <!-- Some other html in the page -->
    <a href="http://ncona.com/">Visit my blog</a>
  </body>
</html>
```

This is how ncona-component.html looks like:

```html
<!-- We need this in order to use polymer's syntactic sugar -->
<link rel="import" href="bower_components/polymer/polymer.html">

<!-- Component definition -->
<dom-module id="ncona-component">
  <!-- These styles only affect this component. You can use a selector that
  is as general as you want and it won't affect other element in the DOM -->
  <style>
    a {
      color: #f00;
    }
  </style>
  <template>
    <a href="http://ncona.com/">Visit my blog</a>
  </template>
</dom-module>

<script>
  // Declare component. Here we specify that we are going to use the custom tag
  // ncona-component for this component. From now on, whenever there is a
  // <ncona-component> in the DOM, it will become an instance of this component
  Polymer({
    is: "ncona-component"
  });
</script>
```

The final result is this:

[<img src="/images/posts/ncona-component.png" alt="ncona-component" />](/images/posts/ncona-component.png)

I added a link to show how the link inside the component is red, but the link outside the component is not affected even when the CSS rule targets all a tags.

That is a pretty simple example, but not very useful. When you design a web component you give the users of your component an API to configure and interact with the component. Lets design a little component and then build it with polymer.

## Advanced example

The name of the component will be ncona-accordion. It will work like this:

```html
<ncona-accordion ncona-allow-all-closed>
  <ncona-element>
    <ncona-title>Something</ncona-title>
    <ncona-content>Some content</ncona-content>
  </ncona-element>
  <ncona-element ncona-selected>
    <ncona-title>Something</ncona-title>
    <ncona-content>Some content</ncona-content>
  </ncona-element>
</ncona-accordion>
```

The **ncona-allow-all-closed** property makes it possible for the user to close all elements of the accordion. You can also specify one of the elements as **ncona-selected**. This will initialize the accordion with that element selected.

This is a heavily commented version of the polymer component:

```html
<link rel="import" href="bower_components/polymer/polymer.html">

<dom-module id="ncona-accordion">
  <style>
    /* When using content interpolation with polymer you need to use ::content
       to style the interpolated content. To avoid your styles to leak to the
       outside DOM you need to wrap the interpolated content and use it in the
       css selector. */
    w ::content ncona-title,
    w ::content ncona-content {
      display: block;
      border: 1px solid #000;
    }

    w ::content ncona-title {
      cursor: pointer;
      background: #ddd;
      /* This allows the users of this component to customize certain aspect
         of this component. For this particular component we only allow the
         user to change the background of the title */
      background: var(--ncona-accordion-title-color);
    }

    w ::content ncona-content {
      display: none;
    }

    w ::content ncona-element[ncona-selected] ncona-content  {
      display: block;
    }
  </style>
  <!-- We are using <content> to copy all the content from the light DOM (The
  outside DOM) into the local DOM (shadow/shady DOM). We use a wrapper so we
  can style the interpolated content without affecting the outside -->
  <template><w><content></content></w></template>
</dom-module>

<script>
  Polymer({
    is: 'ncona-accordion',
    // Allows mapping between element attributes and properties of component
    properties: {
      // If this is true, then all elements in the element can be closed
      nconaAllowAllClosed: Boolean
    },
    listeners: {
      // When the element is clicked, execute handleClick
      click: 'handleClick'
    },
    handleClick: function(e) {
      // We only care if a title was clicked
      if (e.target.tagName !== 'NCONA-TITLE') {
        return;
      }

      // Get the current status of the clicked element and save it for later
      var elementStatus = e.target.parentNode.getAttribute('ncona-selected');

      // Mark all elements as unselected
      var elements = this.querySelectorAll('ncona-element');
      for (var i = 0; i < elements.length; i++) {
        elements[i].removeAttribute('ncona-selected');
      }

      // Only show it if it was not being shown before when allowAllClosed set
      if (!this.nconaAllowAllClosed || elementStatus === null) {
        e.target.parentNode.setAttribute('ncona-selected', 'ncona-selected');
      }
    }
  });
</script>
```

We can see the accordion on the page and working as expected:

[<img src="/images/posts/accordion.png" alt="accordion" />](/images/posts/accordion.png)

A cool thing about the accordion is that we made it possible for the user to change the color of the titles. The user can add this style declaration:

```html
<!-- you have to include the is="custom_style" for polymer to recognize this
style declaration -->
<style is="custom-style">
ncona-accordion {
  --ncona-accordion-title-color: red;
}
</style>
```

And the title color will change:

[<img src="/images/posts/accordion-styled.png" alt="accordion-styled" />](/images/posts/accordion-styled.png)

A lot of the features that I used in my examples require polymer 1.0. If you are using an old version of polymer, they might not work.
