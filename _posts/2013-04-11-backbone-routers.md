---
id: 1231
title: Backbone routers
date: 2013-04-11T01:48:53+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1231
permalink: /2013/04/backbone-routers/
tags:
  - backbone
  - design_patterns
  - javascript
  - open_source
  - programming
---
Routers are a common way for web frameworks to translate a URL to an action. On backbone they are used when creating single page applications to refresh the content of the page without actually refreshing the page.

Lets see an example of how they work:

```js
var MyAppRouter = Backbone.Router.extend({
  // Define the routes we want to listen to
  routes: {
    '': 'indexAction',
    'main': 'mainAction',
    'listing/:page': 'listingAction',
    'profile/:id(/:username)': 'profileAction',
    'anything/*all': 'anythingAction'
  },

  // Acts as a constructor
  initialize: function() {
    console.log('Router started');
  },

  indexAction: function() {
    console.log('Index action');
  },

  // Now we list our router actions
  mainAction: function() {
    console.log('Main page');
  },

  listingAction: function(page) {
    console.log('Show page ' + page);
  },

  profileAction: function(id, username) {
    console.log('You passed id: ' + id + ' and username: ' + username);
  },

  anythingAction: function(all) {
    console.log(all);
  }
});

// We need to instantiate it
var router = new MyAppRouter();

// This tells backbone to start listening for URL changes
Backbone.history.start();
```

<!--more-->

Here we defined some routes that our application will listen to. The routes will work this way:

  * **indexAction**.- http://example.com
  * **mainAction**.- http://example.com#main
  * **listingAction**.- http://example.com#listing/2
  * **profileAction**.- http://example.com#profile/someuser or http://example.com#profile/2342/someuser
  * **anythingAction**.- http://example.com#anything/something/else/here

You can see on the routes that we used this format **:page**. This means that whatever is found in that position will be passed to the action function as that parameter. For example, the URL **http://example.com#listing/56** will basically call listingAction(&#8217;56&#8217;).

When a parameter is enclosed by parentheses it means it is optional. For example, the URL **http://example.com#profile/33** will call profileAction(&#8217;33&#8217;), while **http://example.com#profile/33/user** will call profileAction(&#8217;33&#8217;, &#8216;user&#8217;).

Using an asterisk you can specify a splat. This will match everything found in that position, including slashes. For example, **http://example.com/anything/whatever/goes/here** will call anythingAction(&#8216;whatever/goes/here&#8217;).
