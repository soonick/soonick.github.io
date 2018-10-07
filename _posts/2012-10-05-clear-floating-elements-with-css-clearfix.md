---
id: 866
title: Clear floating elements with CSS clearfix
date: 2012-10-05T02:51:01+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=866
permalink: /2012/10/clear-floating-elements-with-css-clearfix/
categories:
  - CSS
tags:
  - css
  - dom
  - programming
---
When working with floating elements there is one problem web developers usually face. Since float elements are removed from the normal flow of the page, this causes some other side effects that may be seen as undesireable.

Lets begin with this HTML structure:

```html
<ul>
    <li>One</li>
    <li>Two</li>
</ul>
```

<!--more-->

If we wanted to make a menu out of the UL we could make the LIs floating elements like this:

```css
ul {
    list-style: none;
    padding: 0;
    border: 1px solid #f00;
}

li {
    display: block;
    float: left;
    margin-right: 10px;
}
```

And we would end up with something like this:

<style>
ul.clearfixArticleList {
    list-style: none;
    padding: 0;
    border: 1px solid #f00;
    display: block;
}

.clearfixArticleList li {
    display: block;
    float: left;
    margin-right: 10px;
}

.clearrr {
  clear: both;
}
</style>

<ul class="clearfixArticleList">
  <li>
    One
  </li>
  <li>
    Two
  </li>
</ul>
<div class="clearrr"></div>

We can see that the border of the container UL does not wrap the li elements, which is not what we intent in most cases. To stop get the behavior we expect we could add a clear element to our list:

```html
<ul>
    <li>One</li>
    <li>Two</li>
    <li class='clear'></li>
</ul>
```

And make it clear with this css:

```css
.clear {
    clear: both;
}
```

We would end up with something like this:

<style>
ul.clearfixArticleList2 {
    list-style: none;
    padding: 0;
    border: 1px solid #f00;
    display: block;
}

.clearfixArticleList2 li {
    display: block;
    float: left;
    margin-right: 10px;
}

.clearfixArticleList2 .clear {
  clear: both;
  float: none;
}
</style>

<ul class="clearfixArticleList2">
  <li>
    One
  </li>
  <li>
    Two
  </li>
  <li class='clear'>
  </li>
</ul>

That works ok, but adding and element to the HTML for styling purposes doesn&#8217;t seem right, so a few people have come up with what is commonly referred to as clearfix. One of the most modern versions is attributed to Nicolas Gallagher (<http://nicolasgallagher.com/micro-clearfix-hack/>) and it goes like this:

First we remove the extra markup we added:

```html
<ul>
    <li>One</li>
    <li>Two</li>
</ul>
```

Then we use this css:

```css
ul {
    list-style: none;
    padding: 0;
    border: 1px solid #f00;
}

ul:before,
ul:after{
    content: "";
    display: table;
}

ul:after{
    clear: both;
}

ul {
    zoom: 1;
}

li {
    display: block;
    float: left;
    margin-right: 10px;
}
```

And we would end up with this:

<style>
ul.clearfixArticleList3 {
    list-style: none;
    padding: 0;
    border: 1px solid #f00;
    display: block;
    zoom: 1;
}

ul.clearfixArticleList3:before,
ul.clearfixArticleList3:after{
    content: "";
    display: table;
}

ul.clearfixArticleList3:after{
    clear: both;
}

.clearfixArticleList3 li {
    display: block;
    float: left;
    margin-right: 10px;
}

.clearfixArticleList3 .clear {
  clear: both;
  float: none;
}
</style>

<ul class="clearfixArticleList3">
  <li>
    One
  </li>
  <li>
    Two
  </li>
</ul>

Nicholas explains in his article what each of the rules do, but I will go very fast over them for completeness sake.

**zoom: 1;** This is only necessary for IE 7 and 6. This activates the internal hasLayout property of IE. This basically tells IE that this element should take care of it&#8217;s size and it&#8217;s descendants sizes.

**:before, :after** These CSS pseudo selectors actually insert content in our page. What we are doing is adding one (empty content: &#8220;&#8221;;) element at the beginning and one element at the end of our UL.

**display: table;** This attribute prevents a border collapsing bug.

Finally using it all together we get the expected result.
