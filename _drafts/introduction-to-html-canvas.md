---
title: Introduction to HTML Canvas
author: adrian.ancona
layout: post
date: 2021-05-26
permalink: /2021/05/introduction-to-html-canvas
tags:
  - javascript
  - programming
  - web_design
---

Canvas is an HTML element that can be used to draw graphics in the browser. The HTML element renders a rectangular area where we can draw using JavaScript. Adding a canvas to a page is as easy as:

```html
<canvas></canvas>
```

[https://jsfiddle.net/ex8u0rgc/](https://jsfiddle.net/ex8u0rgc/)

## Drawing context

To draw on a canvas, we need to get a reference to the canvas' drawing context. Here is an example of drawing a rectangle:

```js
const canvas = document.getElementById('canvas');
const context = canvas.getContext('2d');
context.fillRect(0, 0, 50, 50);
```

<!--more-->

https://jsfiddle.net/zt6evrkL/

At the time of this writing there are [4 contexts available](https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/getContext#parameters): `2d`, `webgl`, `webgl2` and `bitmaprenderer`. I'm only going to cover the `2d` context in this article.

## The canvas

We can think of the canvas as blank piece of paper where we will draw. The canvas has a width and a height. To reference a point in the canvas we use a [coordinate system](https://en.wikipedia.org/wiki/Cartesian_coordinate_system). The diference between the canvas and the [cartesian coordinate system](https://en.wikipedia.org/wiki/Cartesian_coordinate_system) is that the coordinate `(0, 0)` is located in the top left corner. Increases in the `x` axis will move coordinates to the right (same as cartesian coordinates), but increases on the `y` axis will move down (opposite to cartesian coordinates).

Let's look at how coordinates work by drawing some circles in a canvas:

```js
const canvas = document.getElementById('canvas');
const context = canvas.getContext('2d');

// Black circle at 0, 0
context.beginPath();
context.arc(0, 0, 5, 0, 2 * Math.PI);
context.fillStyle = "black";
context.fill();

// Red circle at 50, 0
context.beginPath();
context.arc(50, 0, 5, 0, 2 * Math.PI);
context.fillStyle = "red";
context.fill();

// Blue circle at 0, 10
context.beginPath();
context.arc(0, 100, 5, 0, 2 * Math.PI);
context.fillStyle = "blue";
context.fill();

// Green circle at 80, 80
context.beginPath();
context.arc(80, 80, 5, 0, 2 * Math.PI);
context.fillStyle = "green";
context.fill();
```

The result: https://jsfiddle.net/on7sfux6/

The example above shows how the coordinate system works, but it also shows something that we need to keep in mind when working with canvas.

The size of the canvas is not necessarily the same as the size and ratio of the dom element that contains the canvas. In both the previous examples we are setting the width and height of the dom element with CSS (200px and 300px respectively), but we are using the default canvas size (and ratio). This causes the circles to be distorted (look like ovals).

We can get the actual width and height of the canvas with JS:

```js
const canvas = document.getElementById('canvas');
console.log(canvas.height);
console.log(canvas.width);
```

We can also set it with JS:

```js
const canvas = document.getElementById('canvas');
canvas.height = 200;
canvas.width = 300;
```

Notice that the values don't contain any units (e.g. px). We can see how setting the size of the canvas to the same as our dom element fixes the issue: https://jsfiddle.net/a4hf5bet/

Alternatively, we could also set the size of the canvas in HTML:

```html
<canvas id="canvas" with="300" height="200"></canvas>
```

https://jsfiddle.net/hn7rqxL9/

## Shapes

We have already drawn rectangles and circles. Let's look a little more closely at what we did, and other basic shapes we can draw.

Rectangles are one of the simples shapes we can draw. In the first examle we used:

```js
context.fillRect(0, 0, 50, 50);
```

- The first two arguments represent the start corner of the rectangle `(0, 0)`
- The last two argument are the ending `(50, 50)`

Circles are a little trickier, in the example we drew a few circles using a command like this:

```js
context.arc(80, 80, 5, 0, 2 * Math.PI);
```

- The first two arguments represent the center of the circle. `(80, 80)` in this case
- The third argument represents the radius of the circle
- The fourth argument is where the arc will start (in radians)
- The fifth argument is the end of the arc

The are two main ways to measure angles: `degrees` and `radians`. A full circle has 360 degrees or 2π radians. Since we wanted a full circle, we started at 0 and ended at `2 * Math.PI` (Which is the same as saying 2π radians).

We can draw lines using `moveTo`, `lineTo` and `stroke`:

```js
const canvas = document.getElementById('canvas');
const context = canvas.getContext('2d');

context.moveTo(50, 50);
context.lineTo(50, 250);
context.lineTo(250, 250);
context.moveTo(250, 50);
context.lineTo(50, 250);
context.stroke();
```

The result: https://jsfiddle.net/cyufdnrh/

## Text

We can also write text to the Canvas:

```js
const canvas = document.getElementById('canvas');
const context = canvas.getContext('2d');

context.font = '50px Arial';
context.fillText('Ncona.com', 10, 50);
```

The result: https://jsfiddle.net/s3xuL7rf/

In the example, we use `fillText` to draw the text. We can also use `strokeText` if we want to only draw the outline of the text.

We can use the `font` option to set the style, font name, size, etc... the same way as we [would set a font in CSS](https://developer.mozilla.org/en-US/docs/Web/CSS/font).

## Conclusion

In this article we learned how to draw simple shapes and text in a canvas. I only scratched the surface; Canvas can be used to create very complex images and animations. In my next article I'm going to show how to do some simple transformations to images.
