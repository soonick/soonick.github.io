---
id: 1512
title: Creating a chrome extension
date: 2013-07-04T03:04:18+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1512
permalink: /2013/07/creating-a-chrome-extension/
categories:
  - Javascript
tags:
  - chrome extension
  - javascript
  - open source
  - programming
  - projects
---
A few days ago I found that I wanted to create a browser extension for fixing some things that annoyed me about Jira, so I started my Journey of learning how to do this for Chrome. I had in the past written an extension for Firefox and I am not sure if it is because I did it so long ago or because chrome system is more friendly, but I felt this time was a lot easier.

## Setting up the environment

The step of setting up the environment is extremely easy. Chrome gives you a lot of flexibility to do things the way you like, so basically the first thing you need is a folder and a manifest.json file inside of it. Here is an example of one:

<!--more-->

```json
{
  "manifest_version": 2,

  "name": "SampleExtension",
  "description": "This extension does nothing",
  "version": "1.0",

  "background": {},

  "permissions": []
}
```

Then you just need to open chrome and go to **chrome://extensions/** and select the checkbox in the right top corner (Developer mode). Now you will see the button **Load unpacked extension&#8230;** where you can select the folder where your extension lives, and that is pretty much it:

[<img src="/images/posts/chrome-extension.png" alt="chrome-extension" />](/images/posts/chrome-extension.png)

## Writing some code

The extension I created is very simple, it checks if you are in the domain where the Jira bug tracker lives and if you do, it will listen for clicks to the **Create Issue** button. When the button is clicked it will hide a bunch of fields I don&#8217;t care about.

The first thing we need to do is to modify our manifest to execute a JS file in the background (which will check if any tab requests the jira bug tracker) and request some permissions to our users:

```json
{
  "manifest_version": 2,

  "name": "JiraFFE",
  "description": "This extension makes Jira a little less anoying",
  "version": "1.0",

  "background": {
    "scripts": ["js/tabsListener.js"]
  },

  "permissions": [
    "storage",
    "webRequest",
    "tabs",
    "<all_urls>"
  ]
}
```

The background property allows us to specify scripts to be executed in the background while our extension is running. The permissions sections grants us permission to use local storage, to listen to all requests and to work with tabs. This is how my tabsListener.js looks like:

```js
var callback = function(details) {
  chrome.tabs.executeScript(
    details.tabId,
    {
      file: '/js/createIssue.js'
    }
  );
};

chrome.storage.local.get('urls', function(value) {
  if (value.urls) {
    var filters = {
      urls: [value.urls],
      types: ['main_frame']
    };

    chrome.webRequest.onCompleted.addListener(callback, filters);
  }
});
```

There are a few things here that probably need some explanation. My callback function calls **chrome.tabs.executeScript**, this function allows us to execute JavaScript in the context of a tab. So what I am doing there is telling chrome to execute the JS file **createIssue.js** in the tab **details.tabId**. Later I use **chrome.storage.local.get** to read from local storage. Note that this works with a callback function so you have to nest the code you want to execute once you get the value from local storage. After I get my Jira url I call **chrome.webRequest.onCompleted.addListener**. This function will listen for all web requests made for a main_frame (a full page) to the Jira Url. When one request that matches is found the callback will be executed and my script will be executed in the tab.

You can see the [full extension code at github](https://github.com/soonick/JiraFFE "JiraFFE").
