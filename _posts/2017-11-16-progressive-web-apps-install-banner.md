---
id: 4387
title: Progressive Web Apps install banner
date: 2017-11-16T04:54:53+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4387
permalink: /2017/11/progressive-web-apps-install-banner/
tags:
  - debugging
  - javascript
  - mobile
---
In a previous post I talked a little about [creating installable web apps](https://ncona.com/2016/09/installable-web-apps/). One important thing that I didn&#8217;t cover is how to automatically prompt a user on your web app to add it to their home screen.

## Serve over https

One of the requirements for chrome to show an app install banner is that the app is served over HTTPS. This can be done in a few ways depending on your server. I wrote a post on how to get [free SSL certificates using Let&#8217;s encrypt](https://ncona.com/2017/01/free-https-with-lets-encrypt/) that should help you get started.

<!--more-->

## manifest.json

In my installable web apps article I showed a sample manifest.json file:

```json
{
  "name": "Awesome App",
  "start_url": ".",
  "display": "standalone"
  "icons": [
    {
      "src": "icons/launcher-2x.png",
      "sizes": "96x96"
    },
    {
      "src": "icons/launcher-3x.png",
      "sizes": "144x144"
    },
    {
      "src": "icons/launcher-4x.png",
      "sizes": "192x192"
    }
  ]
}
```

For the install banner to be shown, there are 5 things your manifest.json file must contain:

  * name
  * short_name
  * start_url
  * display (It must be standalone or fullscreen)
  * At least a 144&#215;144 icon

In the example above I&#8217;m missing short_name, so let&#8217;s add it:

```json
{
  "name": "Awesome App",
  "short_name": "Awesome App",
  "start_url": ".",
  "display": "standalone"
  "icons": [
    {
      "src": "icons/launcher-2x.png",
      "sizes": "96x96"
    },
    {
      "src": "icons/launcher-3x.png",
      "sizes": "144x144"
    },
    {
      "src": "icons/launcher-4x.png",
      "sizes": "192x192"
    }
  ]
}
```

## Service worker

A service worker is piece of JavaScript that the browser will load and run in the background of your application. Having a service worker is a requirement for showing an app install banner. To register a minimal service worker you can add this script on your main page:

```js
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function() {
    navigator.serviceWorker.register('/sw.js');
  });
}
```

This code registers a service worker located in /sw.js. We need to create that file and add a _fetch_ event listener:

```js
self.addEventListener('fetch', function() { });
```

You can add more stuff if necessary, but this is the minimum requirement.

## Testing

Once you have completed these requirements your app will be ready for showing the install banner to your users. The banner will be shown automatically to users that after using your web app, return and use it again 5 minutes (or more) later.

If you tried this and it didn&#8217;t work you can also trigger this manually from Chrome developer tools for desktop. Open the Application menu on the developer tools. On the left panel select _Manifest_ under _Application_. Click the _Add to homescreen_ button on the right panel. For verifying on your mobile device you can follow the same steps using remote debugging.

If everything went well you will see a banner on the top of the screen suggesting you to add this App to your desktop. If you get an error, review the steps above.
