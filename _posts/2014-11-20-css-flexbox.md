---
id: 2398
title: CSS Flexbox
date: 2014-11-20T02:16:28+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2398
permalink: /2014/11/css-flexbox/
categories:
  - CSS
tags:
  - css
  - web-design
---
Today I found myself in the need to create a layout that I hadn&#8217;t done before:

[<img src="/images/posts/flexbox.png" />](/images/posts/flexbox.png)

This layout would be easy if I knew the widths of the elements, but I needed it to be flexible. Another possibility that crossed my mind was using percentages but there was a requirement that didn&#8217;t allow me to do it. To understand better there are a few things about the image above that I need to explain:

  * The image has a static width
  * I want the button on the right to expand and use as much space as it needs, but not more than it needs
  * I want the center portion to use all the available space left by the image and the button

<!--more-->

Since I couldn&#8217;t figure out a way to do this with floats or absolute positions I decided to google for a solution. After a while I didn&#8217;t find what I needed so I decided to ask around. A friend quickly identified this as being easily done with flexbox. After looking a little into it, I achieved my layout:

```html
<div class="container">
  <img class="image" />
  <div class="data">
    Lorem ipsum dolor sit amet, consectetur adipiscing elit,
    sed do eiusmod tempor incididunt ut labore et dolore magna
    aliqua.
  </div>
  <button class="button">
      Button
  </button>
</div>
```

```css
.container {
  /* Tells the browser that you want this element */
  /* to be a flexbox */
  display: flex;
  width: 100%;
}

.image {
  width: 40px;
  height: 40px;
  /* This tells the browser that this element should */
  /* never be shrank to a size smaller than it's content */
  flex-shrink: 0;
  align-self: center;
}

.button {
  /* Same as for the image */
  flex-shrink: 0;
  align-self: center;
}

.data {
  /* Use all space that is not used by other elements */
  flex-grow: 1;
  margin: 5px;
}
```

The flex-grow directive tells an element to use all available space. If you don&#8217;t use **flex-shrink: 0;** in other elements they could be resized messing your layout.

Depending on your browser support policy you might not be able to use flexbox on your project. Support has been there for a while for FF and Chrome but it was introduced in IE10.

This is just an example. There are many more things that can be done using a flex layout. Some examples are: making vertical layouts, align or center elements, divide the available space between different elements, etc. I encourage you to read the [flexbox spec](http://www.w3.org/TR/css3-flexbox/ "Flexbox W3C spec") to learn about all the things you can do.
