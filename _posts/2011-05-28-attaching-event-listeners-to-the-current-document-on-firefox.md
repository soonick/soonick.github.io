---
id: 169
title: Attaching event listeners to the current document on Firefox
date: 2011-05-28T19:46:44+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=169
permalink: /2011/05/attaching-event-listeners-to-the-current-document-on-firefox/
tags:
  - firefox_extension
  - javascript
  - projects
---
This post is a continuation of [Detecting when a tab or window is opened on Firefox](http://ncona.com/2011/05/detecting-when-a-new-tab-or-window-is-open-on-firefox/ "Detecting when a new tab or window is opened on Firefox") post. We are going to be using what we did on that post as a base for this one.

## Introduction

Continuing with the development of my Firefox extension, this time I am going to attach event listeners to the current tab so I can override its behavior.

I will first check if the tab matches the domain of the application, and if it does I will add an event listener to a button that I know exists on the page to do what I want it to do.

## Approach

We are going to listen for location changes on our windows. For that we are going to use a progress listener that will notify us every time the location bar of our window changes. This happens every time a new tab is opened or every time you change the current tab.

<!--more-->

## Listening for location changes

We are going to add a progress listener to our window browser that will notify us every time the location bar changes. This will allow us to call a function that will attach the event listeners we need to the current document:

```js
var listener =
{
    onLocationChange: function(progress, request, uri)
    {
	if (-1 != uri.host.indexOf(tntfixer.pattern))
	{
            if (content.document.body)
	    {
		tntfixer.fixCurrentTab();severinaseverina
	    }
	    else
	    {
		content.document.addEventListener(
                    'load',
                    tntfixer.fixCurrentTab,
                    true
                );
	    }
	}
    }
}
gBrowser.addProgressListener(listener,
		Components.interfaces.nsIWebProgress.NOTIFY_LOCATION);
```

First we create a listener object with an onLocationChange method. That method will be executed every time the location bar changes. Then we attach a progress listener to our window browser passing the listener as the first argument and a constant telling it that it will only listen to location changes.

Every time the location changes we verify if the new URL matches our pattern argument. We check if the body element of the current document exists to be sure that the document has completed loading before attaching the listeners. After the body has been loaded we call fixCurrentTab to attach the event listeners:

```js
'fixCurrentTab': function()
{
	var currentDocument = content.document;

	//	If the campaign is approved then alert that hitting save
	//	deactivates the offer
	var isActive = false;
	var divs = currentDocument.getElementsByClassName('approved_campaign');
	if (divs[0] && 'approved' == divs[0].innerHTML.toLowerCase())
	{
		isActive = true;
	}
	if (isActive)
	{
		var saveButton = currentDocument.getElementById('campaign-save');
		saveButton.parentNode.addEventListener(
			'click',
			tntfixer.confirmDisapproveCampaign,
			true
		);
	}
},
```

In this function I attach an event listener to the save button of a campaign edit window, but only when the campaign is active.
