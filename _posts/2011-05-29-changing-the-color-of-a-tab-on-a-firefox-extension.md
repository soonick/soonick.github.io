---
id: 185
title: Changing the color of a tab on a firefox extension
date: 2011-05-29T00:57:16+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=185
permalink: /2011/05/changing-the-color-of-a-tab-on-a-firefox-extension/
tags:
  - firefox_extension
  - javascript
---
Changing the color of a tab on a Firefox extension is a very straight forward task. You can use this code to change the color of all the tabs on a window:

```js
var tabbrowser = window.getBrowser();
for (var i = 0; i &lt; tabbrowser.browsers.length; i++)
{
    tabbrowser.tabContainer.childNodes[i].style.setProperty(
        "background-color",
        "#0f0",
        "important"
    );
}
```

If you don&#8217;t provide the third argument &#8220;important&#8221; you won&#8217;t be able to override the browser default and therefore you wont see your change.

<!--more-->

Another thing to keep in mind is that probably the code above will change the color of all the tabs except the current one. This is because the current tab contains also a background image that you have not overridden. This line should do the trick:

```js
tabbrowser.tabContainer.childNodes[i].style.setProperty(
        "background-image",
        "none",
        "important"
    );
```

If at any momment you want to remove your styles you can use the removeProperty function:

```js
var tabbrowser = window.getBrowser();
for (var i = 0; i &lt; tabbrowser.browsers.length; i++)
{
    tabbrowser.tabContainer.childNodes[i].style.removeProperty("background-color");
    tabbrowser.tabContainer.childNodes[i].style.removeProperty("background-image");
}
```
