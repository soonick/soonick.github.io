---
id: 118
title: Detecting when a new tab or window is opened on Firefox
date: 2011-05-21T23:27:26+00:00
author: adrian.ancona
layout: post
guid: http://ncona.dev/?p=118
permalink: /2011/05/detecting-when-a-new-tab-or-window-is-open-on-firefox/
tags:
  - firefox_extension
  - javascript
  - projects
---
This post is a continuation of [using Firefox preferences to store data](http://ncona.com/2011/05/using-firefox-preferences-system-when-developing-extensions/ "Using Firefox preferences to store data") post. We are going to be using what we did on that post as a base for this one.

## Introduction

For the ones who don&#8217;t know, these series of posts about Firefox extensions development is inspired by a need to fix some issues on a tool I use at my current job.

One of the problems with this tool is that it doesn&#8217;t allow to work on multiple tabs or windows in the same browser at the same time. Doing this could cause that when you save something on one tab the other tab is affected and your data could be corrupted. What I will do to avoid data corruption is check if there are two instances of the application open, and if so, I won&#8217;t allow to save until there is only one left.

<!--more-->

## Approach

To be able to know if there is only one instance of the application running I need to check all tabs on all windows for the domain of the application and then apply certain rules if there is more than one tab with the application open.

These are the events I will have to listen to know when to restrict saving:

  * On startup verify the domain of all windows and all tabs.
  * Every time a new tab or window is opened verify its domain.
  * Every time a tab or window is reloaded verify its domain.

These are the events I will have to listen to know when to remove the restriction:

  * Every time a window or tab is closed verify if now there is only one instance of the application open.

After being able to detect if the browser is in a &#8220;dangerous&#8221; state we have to actually restrict the saving on the application. But in this post we are only going to cover the detection of the window and tab events.

## Checking URL of all tabs at startup

When you have multiple windows open on Firefox each window is independent of the other, and each window will have a different instance of our extension running. Another thing that is true is that inside one window you can only access tabs that belong to it. Fortunately Firefox has a Window Mediator interface that allows us to get references to all the currently open windows.

Now what we have to do is check all tabs on all windows and verify if verify how many match the domain we are looking for.

Doing this at startup is a little tricky because we don&#8217;t know how many windows does the user have saved in his session. Another problem is that because each window initializes its own instance of our, we have to figure a way to synchronize all our instances.

This is what I came with:

```js
var tntfixer =
{
    ...

    /**
     *    Pattern to search on url
     */
    'pattern': 'omniture.com',
    /**
     *    Number of open tabs that match the pattern
     */
    'matchedTabs': 0,
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
        window.removeEventListener('load', tntfixer.init, false);
        window.addEventListener("focus", tntfixer.getNumberOfTntTabs, false);
        var currentTab = gBrowser.getBrowserForTab(gBrowser.selectedTab);
        currentTab.addEventListener('load', tntfixer.getNumberOfTntTabs, true);

       ...
    },
    /**
     *    getNumberOfTntTabs
     *    Searches all the current tabs to find out how many Tnt tabs are open.
     *    populates matchedTabs with the number of matches found and also returns
     *    the value
     *
     *    @return    int        $found.- Number of curretly open Tnt tabs
     */
    'getNumberOfTntTabs': function()
    {
        var wm = Components.classes['@mozilla.org/appshell/window-mediator;1']
                .getService(Components.interfaces.nsIWindowMediator);

        // Get the number of Tnt tabs in all windows
        var windowIter = wm.getEnumerator('navigator:browser');
        var currentWindow;   
        var tabCount = 0;
        while (windowIter.hasMoreElements())
        {
            currentWindow = windowIter.getNext();
            tabbrowser = currentWindow.getBrowser();

            for(var i=0; i&lt;tabbrowser.browsers.length; i++)
            {
                var browser = tabbrowser.getBrowserAtIndex(i);
                if (-1 != browser.currentURI.spec.indexOf(tntfixer.pattern))
                {
                    tabCount++;
                }
            }
        }

        // Populate matchedTabs in all windows
        var windowIter = wm.getEnumerator('navigator:browser');
        var currentWindow;   
        while (windowIter.hasMoreElements())
        {
            currentWindow = windowIter.getNext();
            currentWindow.tntfixer.matchedTabs = tabCount;
        }

        tntfixer.matchedTabs = tabCount;
    },
    ...
};
```

The code above are just the additions to tntfixer.js. We added two attribute: pattern, a pattern to search on the domain to verify if the tab is currently inside the application; matchedTabs, the current number of tabs with the application open in all the windows.

We also added a new function that will search all the windows for tabs that match the pattern; getNumberOfTntTabs. That function is run as soon as the current tab on any browser is loaded. We did this because we want to be sure that the tabs have been loaded and not only the window when we start to verify the URLs. This function first searches all windows and counts the number of tabs, and then modifies all the windows, this way the last window that loads will do this and update all the other windows. When the startup is complete matchedTabs will hold the number of tabs that match the pattern.

## Closing and opening tabs

To maintain the number of matchedTabs accurate at any moment we need to update it everytime the number of tabs changes. To do that we are going to listen to the TabClose and TabOpen events and we are going to create a function to manage each one.

I am going to add these lines to my init method to add the listeners:

```js
var container = gBrowser.tabContainer;
container.addEventListener("TabClose", tntfixer.verifyClosedTab, true);
container.addEventListener("TabOpen", tntfixer.verifyOpenedTab, true);
```

And these are the new functions:

```js
'verifyOpenedTab': function(e)
{
	var browser = gBrowser.getBrowserForTab(e.target);
	browser.addEventListener('load', tntfixer.getNumberOfTntTabs, true);
},
'verifyClosedTab': function(e)
{
	var browser = gBrowser.getBrowserForTab(e.target);
	if (-1 == browser.currentURI.spec.indexOf(tntfixer.pattern))
	{
		return;
	}

	var wm = Components.classes['@mozilla.org/appshell/window-mediator;1']
			.getService(Components.interfaces.nsIWindowMediator);

	var windowIter = wm.getEnumerator('navigator:browser');
	var currentWindow;
	while (windowIter.hasMoreElements())
	{
		currentWindow = windowIter.getNext();
		currentWindow.tntfixer.matchedTabs--;
	}
},
```

verifiyOpenedTab just waits until the tab is ready and runs getNumberOfTntTabs. verifyClosedTab verifies if the tab that is being closed is opened in the application domain, if it is it updates all the windows.

## Closing and opening windows

For detecting windows opening there is nothing we need to do. Since every time a new window opens a new instance of tntfixer is initialized, it will also run getNumberOfTntTabs and update all windows if necessary.

For windows closing we will need to ad an event listener to the unload event of the windows. We can do this in the init method:

```js
window.addEventListener("unload", tntfixer.unload, false);
```

And this is our unload method:

```js
'unload': function()
{
	var tabbrowser = window.getBrowser();
	var tabCount = 0;

	for (var i = 0; i &lt; tabbrowser.browsers.length; i++)
	{
		var browser = tabbrowser.getBrowserAtIndex(i);
		if (-1 != browser.currentURI.spec.indexOf(tntfixer.pattern))
		{
    		tabCount++;
		}
	}

	var wm = Components.classes['@mozilla.org/appshell/window-mediator;1']
			.getService(Components.interfaces.nsIWindowMediator);

	var windowIter = wm.getEnumerator('navigator:browser');
	var currentWindow;
	while (windowIter.hasMoreElements())
	{
		currentWindow = windowIter.getNext();
		currentWindow.tntfixer.matchedTabs =
				currentWindow.tntfixer.matchedTabs - tabCount;
	}
}
```

This method verifies how many application windows were open on the closing window and then subtract that number to matchedTabs in all windows.

## Finishing touch

At this time the number of tabs that are opened on the application domain is know by our extension at any time. But there is something that is not synchronized correctly. If we click our icon on the status bar on any opened window it will only change on that window, but since our extension works on all windows simultaneously, the status of the extension has to be synchronized between windows.

What we are going to do is, using the window mediator interface we are going to change the icon in all the windows every time the icon is clicked on any window. Here is how the new toogleStatusBarIcon method will look like:

```js
'toogleStatusBarIcon': function()
{
	if ('active' == tntfixer.statusBarIcon.getAttribute('value'))
	{
		var newStatus = 'inactive';
	}
	else
	{
		var newStatus = 'active';
	}

	var wm = Components.classes['@mozilla.org/appshell/window-mediator;1']
			.getService(Components.interfaces.nsIWindowMediator);
	var windowIter = wm.getEnumerator('navigator:browser');
	var currentWindow;
	while (windowIter.hasMoreElements())
	{
		currentWindow = windowIter.getNext();
		currentWindow.tntfixer.statusBarIcon.setAttribute('value', newStatus);
		currentWindow.tntfixer.preferences.setCharPref('status', newStatus);
	}
}
```

Now our status bar icon is happily synchronized between windows.

## All together

Here is the status of our tntfixer.js files with the new additions highlighted:

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
     *    Pattern to search on url
     */
    'pattern': 'omniture.com',
    /**
     *    Number of open tabs that match the pattern on all windows
     */
    'matchedTabs': 0,
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
        // Listeners to count tabs at startup
        var currentTab = gBrowser.getBrowserForTab(gBrowser.selectedTab);
        currentTab.addEventListener('load', tntfixer.getNumberOfTntTabs, true);
        window.removeEventListener('load', tntfixer.init, false);
        window.addEventListener("focus", tntfixer.getNumberOfTntTabs, false);

        // Listeners to count tabs when opening or closing windows or tabs
        var container = gBrowser.tabContainer;
        container.addEventListener("TabClose", tntfixer.verifyClosedTab, true);
        container.addEventListener("TabOpen", tntfixer.verifyOpenedTab, true);
        window.addEventListener("unload", tntfixer.unload, false);

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
            var newStatus = 'inactive';
        }
        else
        {
            var newStatus = 'active';
        }

        var wm = Components.classes['@mozilla.org/appshell/window-mediator;1']
                .getService(Components.interfaces.nsIWindowMediator);
        var windowIter = wm.getEnumerator('navigator:browser');
        var currentWindow;
        while (windowIter.hasMoreElements())
        {
            currentWindow = windowIter.getNext();
            currentWindow.tntfixer.statusBarIcon.setAttribute('value', newStatus);
            currentWindow.tntfixer.preferences.setCharPref('status', newStatus);
        }
    },
    /**
     *    verifyOpenedTab
     *    Checks if a newly opened tab has Tnt domain and updates matchedTabs
     *
     *    @return    void
     */
    'verifyOpenedTab': function(e)
    {
        var browser = gBrowser.getBrowserForTab(e.target);
        browser.addEventListener('load', tntfixer.getNumberOfTntTabs, true);
    },
    /**
     *    verifyClosedTab
     *    Checks if the closing tab has Tnt domain and updates matchedTabs
     *
     *    @return    void
     */
    'verifyClosedTab': function(e)
    {
        var browser = gBrowser.getBrowserForTab(e.target);
        if (-1 == browser.currentURI.spec.indexOf(tntfixer.pattern))
        {
            return;
        }

        var wm = Components.classes['@mozilla.org/appshell/window-mediator;1']
                .getService(Components.interfaces.nsIWindowMediator);

        var windowIter = wm.getEnumerator('navigator:browser');
        var currentWindow;    
        while (windowIter.hasMoreElements())
        {
            currentWindow = windowIter.getNext();
            currentWindow.tntfixer.matchedTabs--;
        }
    },
    /**
     *    getNumberOfTntTabs
     *    Browses all the current tabs to find out how many Tnt tabs are open.
     *    populates matchedTabs with the number of matches found and also returns
     *    the value
     *
     *    @return    int        $found.- Number of curretly open Tnt tabs
     */
    'getNumberOfTntTabs': function()
    {
        var wm = Components.classes['@mozilla.org/appshell/window-mediator;1']
           .getService(Components.interfaces.nsIWindowMediator);

        var windowIter = wm.getEnumerator('navigator:browser');
        var currentWindow;    
        var tabCount = 0;
        while (windowIter.hasMoreElements())
        {
            currentWindow = windowIter.getNext();
            tabbrowser = currentWindow.getBrowser();

            for(var i=0; i&lt;tabbrowser.browsers.length; i++)
            {
                var browser = tabbrowser.getBrowserAtIndex(i);
                if (-1 != browser.currentURI.spec.indexOf(tntfixer.pattern))
                {
                    tabCount++;
                }
            }
        }

        var windowIter = wm.getEnumerator('navigator:browser');
        var currentWindow;    
        while (windowIter.hasMoreElements())
        {
            currentWindow = windowIter.getNext();
            currentWindow.tntfixer.matchedTabs = tabCount;
        }

        tntfixer.matchedTabs = tabCount;
    },
    /**
     *    unload
     *    When a window is closed it subtracts its matched tabs from the matchedTabs
     *    attribute in all other windows
     *
     *    @return void
     */
    'unload': function()
    {
        var tabbrowser = window.getBrowser();
        var tabCount = 0;

        for (var i = 0; i &lt; tabbrowser.browsers.length; i++)
        {
            var browser = tabbrowser.getBrowserAtIndex(i);
            if (-1 != browser.currentURI.spec.indexOf(tntfixer.pattern))
            {
                tabCount++;
            }
        }

        if (0 == tabCount)
        {
            return;
        }

        var wm = Components.classes['@mozilla.org/appshell/window-mediator;1']
                .getService(Components.interfaces.nsIWindowMediator);

        var windowIter = wm.getEnumerator('navigator:browser');
        var currentWindow;
        while (windowIter.hasMoreElements())
        {
            currentWindow = windowIter.getNext();
            currentWindow.tntfixer.matchedTabs =
            currentWindow.tntfixer.matchedTabs - tabCount;
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
