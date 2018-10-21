---
id: 663
title: Gradient background, the CSS 3 standard way
date: 2012-07-05T02:17:23+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=663
permalink: /2012/07/gradient-background-the-css-3-standard-way/
tags:
  - css
  - web_design
---
In this article I am going to explain the CSS 3 standard way of achieving a linear-gradient background. Using only this technique is probably not going to give the cross browser behavior that you are expecting.

## Linear gradient

The definition of a linear gradient from W3C documentation:

> A linear gradient is created by specifying a gradient line and then several colors placed along that line. The image is constructed by creating an infinite canvas and painting it with lines perpendicular to the gradient line, with the color of the painted line being the color of the gradient line where the two intersect. This produces a smooth fade from each color to the next, progressing in the specified direction.

So, to set a linear gradient for a div or another DOM element we would need to imagine a straight line that goes through the object at an specific angle touching the center of the element. Then define the colors we which at specific points in the line.

<!--more-->

## linear-gradient()

The linear-gradient function has this prototype:

```
linear-gradient(
    [[<angle> | to <side-or-corner>],]?
    <color-stop>[, <color-stop>]+
)
```

The first argument ([[<angle> | to <side-or-corner>],]) specifies the direction of the gradient line. If omitted it defaults to **bottom**.

As you can see from the prototype, the direction can be specified in two ways:

**&lt;angle&gt;** - For the purpose of this argument, 0deg points upward, and positive angles represent clockwise rotation, so 90deg point toward the right.

**to &lt;side-or-corner&gt;** - If the argument is to top, to right, to bottom, or to left, the angle of the gradient line is 0deg, 90deg, 180deg, or 270deg, respectively.

**&lt;color-stop&gt;** - Expects a color and a position. Something similar to #fff 0%. If the position is omitted the browser will make a best guess.

## Examples

Here are some examples of how the linear-gradient looks in some rectangular divs. If you don&#8217;t see the gradients it is possible that your browser doesn&#8217;t currently support the W3C standard.

```css
.some-class {
    background: linear-gradient(#000, #fff);
}
```

<div style="margin: 10px 0; border: 1px solid #000; width: 200px; height: 100px; background: linear-gradient(#000, #fff);"></div>

```css
.some-class {
    background: linear-gradient(to left, #0f0, #00f);
}
```

<div style="margin: 10px 0; border: 1px solid #000; width: 200px; height: 100px; background: linear-gradient(to left, #0f0, #00f);"></div>

```css
.some-class {
    background: linear-gradient(37deg, #000 0%, #f00 10%, #0f0 40%, #00f 60%, #000 100%);
}
```

<div style="margin: 10px 0; border: 1px solid #000; width: 200px; height: 100px; background: linear-gradient(37deg, #000 0%, #f00 10%, #0f0 40%, #00f 60%, #000 100%);"></div>
