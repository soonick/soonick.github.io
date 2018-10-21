---
id: 655
title: Rounded corners, the CSS 3 standard way
date: 2012-06-14T14:43:33+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=655
permalink: /2012/06/rounded-corners-the-css-3-standard-way/
tags:
  - css
  - web_design
---
In this article I am going to explain the CSS 3 standard way of achieving rounded corners. Using only this technique is probably not going to give the cross browser behavior that you are expecting.

## Border radius properties

It doesn&#8217;t matter which way you specify the radius you want for your corners, the browser is going to compute it in four different properties:

```
border-top-left-radius
border-top-right-radius
border-bottom-right-radius
border-bottom-left-radius
```

<!--more-->

Each of these properties hold two values separated by a space:

```css
border-top-left-radius: 5px 7px;
```

The first value is the horizontal radius and the second is the vertical radius. If the second value is omitted, the first value is going to be used for the horizontal and vertical radius.

## Shorthand notations

You can set the border-radius for all four corners at the same time using the **border-radius** shorthand:

```css
border-radius: 5px;
```

If you want horizontal and vertial radius to be different you would separate them by a slash:

```css
border-radius: 15px / 5px; /* horizontal 15px, vertical 5px */
```

You can also specify values for each corner specifically following these rules:

```css
/* 1px top-left, 2px top-right, 3px bottom-right, 4px bottom-left */
border-radius: 1px 2px 3px 4px;
/* 1px top-left, 2px top-right and bottom-left, 3px bottom-right */
border-radius: 1px 2px 3px;
/* 1px top-left and bottom-right, 2px top-right and bottom-left */
border-radius: 1px 2px;
```

You can set horizontal and vertical radius separately by combinining this with a slash:

```css
border-radius: 1px 2px 3px 4px / 3px 6px;
```

would be the same as:

```css
border-top-left-radius: 1px 3px;
border-top-right-radius: 2px 6px;
border-bottom-right-radius: 3px 3px;
border-bottom-left-radius: 4px 6px;
```
