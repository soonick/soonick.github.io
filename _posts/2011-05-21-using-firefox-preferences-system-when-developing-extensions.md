---
id: 87
title: Using Firefox preferences to store data
date: 2011-05-21T22:20:09+00:00
author: adrian.ancona
layout: post
guid: http://ncona.dev/?p=87
permalink: /2011/05/using-firefox-preferences-system-when-developing-extensions/
categories:
  - Javascript
tags:
  - firefox extension
  - javascript
  - projects
  - tntfixer
  - xul
---
This post is a continuation of  [Adding an icon to our Firefox extension](http://ncona.com/2011/05/adding-an-icon-to-our-firefox-extension/ "Adding an icon to our Firefox extension") post. We are going to be using what we did on that post as a base for this one.

## Introduction

The Firefox preferences system provides and easy way of storing small amounts of data for Firefox extensions. There are more advanced systems to store data for extensions but since what we are going to store is actually a user preference we are going to save it there. There are three data types that can be used for preferences: boolean, int and char.

<!--more-->

By convention extension preferences should be saved on a branch named after our extension, and that branch should be put inside the extensions branch. That means that our preferences will follow this format:

```
extensions.tntfixer.pref1
extensions.tntfixer.pref2
```

## The code

For our extension we are going to use one preference to save the status of our extension (active or inactive), for this we are going to use a char preference that we are going to save every time our status bar icon is clicked, and retrieve when our extension is started.

```js
var tntfixer =
{
    /**
     *    Reference to status bar icon
     */
    'statusBarIcon': null,
    /**
     *    Saved preferences
     */
    'preferences': null,
    /**
     *    init
     *    Initializes the extension. Gets a reference to the status bar icon,
     *    gets preferences status of the extension and verifies how many Tnt tabs
     *    are already open
     *
     *    @return    void
     */
    'init': function()
    {
        //    Preferences manager
        tntfixer.preferences = Components
                .classes["@mozilla.org/preferences-service;1"].getService(
                Components.interfaces.nsIPrefService);
        tntfixer.preferences = tntfixer.preferences.getBranch('extensions.tntfixer.');
        try
        {
            var status = tntfixer.preferences.getCharPref('status');
        }
        catch (err)
        {
            var status = 'inactive';
            tntfixer.preferences.setCharPref('status', status);
        }

        //  Status bar icon
        tntfixer.statusBarIcon = document.getElementById('tntFixerStatusBarIcon');
        tntfixer.statusBarIcon.setAttribute('value', status);
        tntfixer.statusBarIcon.addEventListener('click',
                tntfixer.toogleStatusBarIcon, false);
    },
    /**
     *    toogleStatusBarIcon
     *    Changes the color of the icon in the status bar when it is clicked
     *
     *    @return    void
     */
    'toogleStatusBarIcon': function()
    {
        if ('active' == tntfixer.statusBarIcon.getAttribute('value'))
        {
            tntfixer.statusBarIcon.setAttribute('value', 'inactive');
            tntfixer.preferences.setCharPref('status', 'inactive');
        }
        else
        {
            tntfixer.statusBarIcon.setAttribute('value', 'active');
            tntfixer.preferences.setCharPref('status', 'active');
        }
    }
};

//    Initialize at startup
window.addEventListener(
    'load',
    function()
    {
        tntfixer.init();
    },
    true
);
```

I added a new attribute to my tntfixer object to store a reference to my extension preferences. Its value is assigned on the init function.

```js
tntfixer.preferences = Components
                .classes["@mozilla.org/preferences-service;1"].getService(
                Components.interfaces.nsIPrefService);
```

This line of code gives us access to all Firefox preferences, but since we are only interested on our branch we point our attribute to the correct place:

```js
tntfixer.preferences = tntfixer.preferences.getBranch('extensions.tntfixer.');
```

Next we try to get the value of our status preference. We do this inside a try catch because it will throw an exception when the preference doesn&#8217;t exist (the first time we run it). In that case we assign the &#8220;inactive&#8221; status manually.

```js
try
{
    var status = tntfixer.preferences.getCharPref('status');
}
catch (err)
{
    var status = 'inactive';
    tntfixer.preferences.setCharPref('status', status);
}
```

As you can imagine getCharPref and setCharPref are used to set and get a char preference. Next, we assign the stored value of our preference in our image:

```js
tntfixer.statusBarIcon.setAttribute('value', status);
```

We also modified the toogleStatusBarIcon method to save its status on the status preference when it is clicked:

```js
'toogleStatusBarIcon': function()
{
    if ('active' == tntfixer.statusBarIcon.getAttribute('value'))
    {
        tntfixer.statusBarIcon.setAttribute('value', 'inactive');
        tntfixer.preferences.setCharPref('status', 'inactive');
    }
    else
    {
        tntfixer.statusBarIcon.setAttribute('value', 'active');
        tntfixer.preferences.setCharPref('status', 'active');
    }
}
```

Now whenever we start Firefox our extension icon will remember its last status and will start that way.
