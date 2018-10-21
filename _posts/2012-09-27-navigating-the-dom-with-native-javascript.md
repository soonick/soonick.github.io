---
id: 843
title: Navigating the DOM with native JavaScript
date: 2012-09-27T02:53:30+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=843
permalink: /2012/09/navigating-the-dom-with-native-javascript/
tags:
  - dom
  - javascript
  - programming
  - xml
---
To be able to successsfully work with the DOM, first we need to understand what it is. DOM stands for Document Object Model and it is the way browsers represent the structure of your HTML (XHTML or XML) document so JS can navigate it (actually it is supposed to be language agnostic, but I&#8217;ll explain how to interact with it using JS), or modify it.

The way you can access the DOM in a typical browser is by refering to the window variable. The window variable gives you access to attributes like history, location and document. In this articule I will focus on window.document.

<!--more-->

## window.document

window.document is the head of your HTML document. Some of its attributes include head and body, which are the actual <head> and <body> tags of your HTML document. If you wanted to empty the body of your document you could easily do it with JS:

```js
window.document.body.innerHTML = '';
```

## Navigating

Lets learn about how to navigate the DOM from a real document:

```html
<html>
    <head>
        <title>An HTML document</title>
    </head>
    <body>
        <h1>I'm a title</h1>
        <p id="anId">I'm a paragraph.</p>
        <p>I'm a paragraph too.</p>
        <h2 class="aClass">I'm another title</h2>
        <a href="http://ncona.com/">I am a link</a>
        <ul>
            <li>List element</li>
        </ul>
    </body>
</html>
```

Once we get into the window.document.body or window.document.head level we can&#8217;t keep using the name of the nodes to refer to them. It means that this won&#8217;t work:

```js
window.document.body.h1
```

Luckily to help us traverse the DOM, each DOM element contains pointers to its immediate relatives. These pointers are: parentNode, previousSibling, nextSibling, firstChild and lastChild. Sadly, things aren&#8217;t as easy as they should. We would expect to be able to get the h1 element like this:

```js
window.document.body.firstChild
```

But if we try it on firebug, we get this:

```
>>> window.document.body.firstChild
<TextNode textContent="\n ">
```

This happens because both tags and text elements are treated as nodes. So what we really have immediately after our <body> tag is a text node containing a line break and some spaces. So, to really get the h1 we would have to do this:

```js
window.document.body.firstChild.nextSibling
```

As you can see this can be a lot of fun. Luckily there are some functions that help us keep the sanity.

## DOM Standard functions

getElementById(>element_id<): This function allows us to search the DOM for an element with an specific id. This function can only be ran against window.document, but it is the fastest way to get an element for which you know the id.

getElementsByTagName(>tag_name<): This method allows you to find all elements of an specific tag that are descendant of another element.

Lets see them in action.

To get the first paragraph of our DOM we could do this:

```js
window.document.getElementById('anId');
```

or this:

```js
window.document.getElementsByTagName('p')[0];
```

## DOM attributes

Once you have selected a dom element you can use some DOM functions to work with its attributes: getAttribute(>attribute\_name<), setAttribute(>attribute\_name<, >value<), removeAttribute(>attribute_name<).

To get the href attribute of the link in our DOM we can use this command:

```js
window.document.body.getElementsByTagName('a')[0].getAttribute('href');
```

That command will return the string &#8220;http://ncona.com&#8221;. Now lets give a title to our link:

```js
window.document.body.getElementsByTagName('a')[0].setAttribute('title', 'A link');
```

Finally we can remove the href attribute like this:

```js
window.document.body.getElementsByTagName('a')[0].removeAttribute('href');
```

## Removing a DOM element

Removing a DOM element feels a little unintuitive at the beggining. This is because the only function that allows us to delete an element is removeChild(&lt;element&gt;). So if we wanted to remove the first paragraph we would have to do it like this:

```js
var element = window.document.getElementById('anId');
element.parentNode.removeChild(element);
```
