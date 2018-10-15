---
id: 3903
title: Installable web apps
date: 2016-09-21T12:32:10+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3903
permalink: /2016/09/installable-web-apps/
categories:
  - Mobile development
tags:
  - json
  - mobile
  - programming
---
Since I discovered the web I believed it was the future. It gives everyone freedom to create the content they want to create and everybody can consume it no matter what operating system they are running. As technology moved forward, smartphones came to be. Smartphones are awesome, but with it came some regression. The creators of the platforms encouraged developers to create applications that only run on their platforms by offering an interface that was only available if you developed natively.

Browsers caught up pretty fast and came up with APIs for some of the most important features native apps provide (location, sensors, etc&#8230;). But there is still something about native apps that makes them somewhat better&#8230;engagement. It is not the same to have to open a browser and type a URL than to click an icon on your phone&#8217;s home screen.

<!--more-->

Luckily for all the freedom lovers out there, browsers are stepping up again and solving this problem for us. In this post I&#8217;m going to explain how this works.

## The home icon

To give the impression to the user that this is a native application (even though it is actually a web application) we need to be able to appear where all their other applications appear, the home screen. To make this possible we need to create a manifest.json file in our root folder and add some information to it:

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

There are more attributes available but I consider these the most important ones:

**name** &#8211; The name of your application. This will appear below your app icon in the home screen.
  
**start_url** &#8211; The URL that will serve as the entry point to your app.
  
**display** &#8211; Allows you to specify how you want your web app to look. Choosing standalone makes it look like a native app (no browser navigation). There are other options that allow you to make it full screen (for games) or look like a regular browser.
  
**icons** &#8211; Define different launcher icons. The src attribute specifies where the icon can be found and the sizes allows you to specify the size. The device will choose the best icon for its resolution. Make sure you create these icons.

We have now specified a home icon and a name for our app, but there is still something we need to do before it is usable. We need to add a link tag to our page. Here is an example index.html I&#8217;m using for testing:

```html
<html>
  <head>
    <link rel="manifest" href="/manifest.json">
  </head>
  <body>
    I'm an installable web app
  </body>
</html>
```

This app is now installable, but the installation is not as smooth as we would probably like it to be. Mostly, because the user has to dig into the browser menu and select **Add to Home screen**:

[<img src="/images/posts/Add-to-home-screen.png" alt="add-to-home-screen" />](/images/posts/Add-to-home-screen.png)

Then you get a confirmation screen:

[<img src="/images/posts/Confirm-name.png" alt="confirm-name" />](/images/posts/Confirm-name.png)

Finally, you can see it in your home like any other app:

[<img src="/images/posts/Screen-icon.png" alt="screen-icon" />](/images/posts/Screen-icon.png)

There is a way to have the browser automatically show a banner to the user telling them to install your app, but I&#8217;m going to cover it in another post since it requires the creation of a service worker, which is more than I want to cover here.
