---
id: 690
title: Box shadows, the CSS 3 standard way
date: 2012-07-19T01:48:36+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=690
permalink: /2012/07/box-shadows-the-css-3-standard-way/
tags:
  - css
  - web_design
---
In this article I am going to explain the CSS 3 standard way of applying a shadow to an object. Using only this technique is probably not going to give the cross browser behavior that you are expecting.

## The shadow object

The first thing we need to understand in order to apply shadows to an object is how the shadows are constructed. A shadow object has this prototype:

```
<shadow> = inset? && [ <length>{2,4} && <color>? ]
```

<!--more-->

**inset**.- If the inset keyword is present the shadow will change from an outer shadow to an inner shadow.

**length**.- Can take two, three or four values. Here is an explanation of what each length value means, starting from the first value and continuing to the last:

  * Horizontal offset of the shadow. A positive value draws a shadow that is offset to the right of the box, a negative length to the left.
  * Vertical offset of the shadow. A positive value offsets the shadow down, a negative one up.
  * Blur radius. Negative values are not allowed. If the blur value is zero, the shadow&#8217;s edge is sharp. Otherwise, the larger the value, the more the shadow&#8217;s edge is blurred.
  * Spread distance. Positive values cause the shadow shape to expand in all directions by the specified radius. Negative values cause the shadow shape to contract.

**color**.- The color of the shadow.

## The box-shadow property

The box-shadow property has this prototype:

```
none | <shadow> [ , <shadow> ]*
```

As we can see from the prototype we can either use the **none** keywork or we can pass as many shadow objects as we want to apply.

## Examples

Here are some examples of how the bow-shadow property looks in some rectangular divs. If you don&#8217;t see the shadows it is possible that your browser doesn&#8217;t currently support the W3C standard.

```css
.some-class {
    box-shadow: 10px 10px #333;
}
```

<div style="margin: 20px 0; border: 1px solid #000; width: 200px; height: 100px; box-shadow: 10px 10px #333;"></div>

```css
.some-class {
    box-shadow: inset 10px 5px #050;
}
```

<div style="margin: 20px 0; border: 1px solid #000; width: 200px; height: 100px; box-shadow: inset 10px 5px #050"></div>

```css
.some-class {
    box-shadow: 5px 5px 2px #004;
}
```

<div style="margin: 20px 0; border: 1px solid #000; width: 200px; height: 100px; box-shadow: 5px 5px 2px #004;"></div>

```css
.some-class {
    box-shadow: 10px -2px 3px 3px #400;
}
```

<div style="margin: 20px 0; border: 1px solid #000; width: 200px; height: 100px; box-shadow: 10px -2px 3px 3px #400;"></div>
