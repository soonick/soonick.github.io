---
title: Using Google Analytics on Progressive Web Apps
author: adrian.ancona
layout: post
date: 2020-12-30
permalink: /2020/12/using-google-analytics-on-progressive-web-apps
tags:
  - javascript
  - programming
---

In this post we are going to learn how we can use Google Analytics to find out how a web application is being used.

This method applies to any single page application even if they are not PWAs (Progressive Web Apps).

## Tracking traditional web sites

Adding google analytics to a traditional website is very easy. Google provides a `script` we can add to each page. Every time a page is load, the script will be run and the visit will be recorded. The `script` looks something like this:

```html
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'G-XXXXXXXXX');
</script>
```

<!--more-->

The reason this by itself doesn't work for PWAs is because the tag only sends a page view event when the page is loaded. Since PWAs transition between pages without reloading the page, we need a way to send events programmatically.

## Tracking Progressive Web Apps

In PWAs we also need to add the `script` above to get the Google Analytics library. On top of this, we need a way to send events to Google programmatically.

We can use the `gtag` function to track arbitrary events whenever we want. For example:

```js
gtag('event', 'message_liked', { 'message_id': 'ABCD' });
```

Google Analytics will [automatically send some events](https://support.google.com/analytics/answer/9234069), but we might also want to manually track our page views:

```js
gtag('event', 'page_view', {
  'page_location': 'feed',
  'page_referrer': 'article-123'
});
```

When to send this event depends on how our application works. Most frameworks have a `router` that takes care of moving between pages. This is a usually a good candidate.

If our application has a centralized place where it keeps its state, we can send events when a change is noticed in the `state`. For example:

```js
stateChanged(state) {
  const previousPage = this._page;
  this._page = state.app.page;

  // Track the page change
  if (previousPage !== newPage) {
    gtag('event', 'page_view', {
      page_location: newPage,
      page_referrer: previousPage
    });
  }
}
```

## Conclusion

Given the way PWAs are usually built, it becomes very easy to record user events simply by adding a function call every time we detect a page change. Furthermore, this method gives us the flexibility to track anything we are interested in.
