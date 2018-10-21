---
id: 52
title: Adding an icon to the status bar in a Firefox extension
date: 2011-05-21T15:49:02+00:00
author: adrian.ancona
layout: post
guid: http://ncona.dev/?p=52
permalink: /2011/05/adding-an-icon-to-the-status-bar-in-a-firefox-extension/
tags:
  - firefox_extension
  - javascript
  - projects
  - tntfixer
  - xul
---
This post is a continuation of [Firefox extensions development post](http://ncona.com/2011/05/firefox-extensions-development/ "Firefox extensions development"). We are going to be using what we did on that post as a base for this one.

## Adding the icon

We are going to modify our tntfixer.xul file. This is the initial state of our file:

```xml
<overlay id="tntfixer"
        xmlns="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">
    <statusbar id="status-bar">
        <statusbarpanel id="tntFixerPanel">
            <label>tntfixer</label>
        </statusbarpanel>
    </statusbar>
</overlay>
```

<!--more-->

And we are going to modify it to look like this:

```xml
<?xml version="1.0"?>
<?xml-stylesheet href="chrome://tntfixer/skin/overlay.css" type="text/css"?>
<overlay id="tntfixer"
        xmlns="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">
    <statusbar id="status-bar">
        <statusbarpanel id="tntFixerPanel">
            <image id="tntFixerStatusBarIcon" />
        </statusbarpanel>
    </statusbar>
</overlay>
```

We added a link to a style sheet we are going to create. We also replaced the tntfixer label with an image. Images work a little different in xul than in html, the way we are going to put the image in place is creating an image (yes, in xul the element name is image, not img) tag without a src attribute, instead we are going to use its id to assign it an image from our style sheet.

As you can see in the style sheet inclusion line, the path to our overlay.css file is:

```
chrome://tntfixer/skin/overlay.css
```

We need to add an entry for the skin folder on our chrome.manifest file:

```
content	tntfixer chrome/content/
skin    tntfixer classic chrome/skin/
overlay chrome://browser/content/browser.xul chrome://tntfixer/content/tntfixer.xul
```

The second line tells XULRunner that the skin folder for tntfixer on a chrome URI will be translated to the chrome/skin/ folder of our extension. The third argument &#8220;classic&#8221; is the name of our theme, this can be changed if you want to have multiple themes.

Although you can place your css files in any folder you want it is common practice to use the location I am using in this example. Here is the content of my file:

```css
#tntFixerStatusBarIcon
{
    list-style-image: url('chrome://tntfixer/skin/images/status-bar-icon-inactive.png');
}
```

This is a simple css rule that sets the background for our image element. Note that we are using a chrome URI to indicate that the image will be on chrome/content/skin/images/status-bar-icon-inactive.png on our extension folder.

## Adding functionality to our status bar icon

Finally we are going to start using JavaScript to make our status bar icon do something, not much for now, but at least something.

We are going to make our image change its background image when it is clicked. It will start showing a gray image representing that our extension is inactive and when it is clicked it will change for a green image that will mean that our extension is active. That is all the functionality we are going to apply for now, we will make it do more stuff in the next posts.

The name of the image we are using for our icon right now is status-bar-icon-inactive.png, that is the gray image that represents the inactive state. We will need another image that will represent the active state, we are going to call it status-bar-icon-active.png.

To add functionality to our extension we will need a JavaScript file, to add that file to our project we will modify tntfixer.xul:

```xml
<?xml version="1.0"?>
<?xml-stylesheet href="chrome://tntfixer/skin/overlay.css" type="text/css"?>
<overlay id="tntfixer"
        xmlns="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">
    <script src="chrome://tntfixer/content/tntfixer.js" />
    <statusbar id="status-bar">
        <statusbarpanel id="tntFixerPanel">
            <image id="tntFixerStatusBarIcon" />
        </statusbarpanel>
    </statusbar>
</overlay>
```

Our JavaScript file is going to be located in our content folder and its name is tntfixer.js:

```js
var tntfixer =
{
    /**
     *    Reference to status bar icon
     */
    'statusBarIcon': null,
    /**
     *    init
     *    Initializes the extension. Gets a reference to the status bar icon,
     *    gets preferences status of the extension and verifies how many Tnt tabs
     *    are already open
     *
     *    @return    void
     */
    'init': function()
    {
        tntfixer.statusBarIcon = document.getElementById('tntFixerStatusBarIcon');
        tntfixer.statusBarIcon.setAttribute('value', 'inactive');
        tntfixer.statusBarIcon.addEventListener('click',
                tntfixer.toogleStatusBarIcon, false);
    },
    /**
     *    toogleStatusBarIcon
     *    Changes the color of the icon in the status bar when it is clicked
     *
     *    @return    void
     */
    'toogleStatusBarIcon': function()
    {
        if ('active' == tntfixer.statusBarIcon.getAttribute('value'))
        {
            tntfixer.statusBarIcon.setAttribute('value', 'inactive');
        }
        else
        {
            tntfixer.statusBarIcon.setAttribute('value', 'active');
        }
    }
};

//    Initialize at startup
window.addEventListener(
    'load',
    function()
    {
        tntfixer.init();
    },
    true
);
```

I am not going to explain all the code because it is common JavaScript, what I will do instead is explain why I chose to make the code this way.

First I created an object named tntfixer that will handle all my extension actions. I did it this way to namespace my extension, that way we can be (almost) sure that it won&#8217;t interfere with other extensions or websites.

In the second line of tntfixer.init() I assign a value of &#8216;inactive&#8217; to the value property of my status bar icon. This is not necessary but this is the approach I chose to distinguish the current status of the icon. This means that we are going to have to make some changes to our style sheet, more on that ahead.

The other interesting thing is that we run tntfixer.init() after the load event of window is triggered, that way we are sure that our status bar image exists when we add the value and the event listener.

Now we need to modify our style sheet to show one image when the value of our icon is active and another when it is inactive. Happily since this is a Firefox extension we can use advanced css selectors to do this:

```css
#tntFixerStatusBarIcon[value='active']
{
    list-style-image: url(
        'chrome://tntfixer/skin/images/status-bar-icon-active.png');
}

#tntFixerStatusBarIcon[value='inactive']
{
    list-style-image: url(
        'chrome://tntfixer/skin/images/status-bar-icon-inactive.png');
}
```

Now our icon changes when we click on it.

On my next post I will explain how to use Firefox preferences system to make the choice of the user persist even when Firefox is closed.
