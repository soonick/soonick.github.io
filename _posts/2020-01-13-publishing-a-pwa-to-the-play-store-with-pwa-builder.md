---
title: Publishing a PWA to the Play Store with PWA builder
author: adrian.ancona
layout: post
date: 2021-01-13
permalink: /2021/01/publishing-a-pwa-to-the-play-store-with-pwa-builder
tags:
  - javascript
  - mobile
  - projects
  - web_design
---

## What is PWA Builder?

[PWA Builder](https://www.pwabuilder.com/) is a set of tools and web components that can be used to publish a web app to different app stores (Android, Samsung and Microsoft).

## Is the PWA ready?

The first thing we need to do is check if our app is ready. For this we can go to [https://www.pwabuilder.com/](https://www.pwabuilder.com/) and enter the URL to our app. After submitting our URL, we will get a score:

<!--more-->

[<img src="/images/posts/pwa-builder-score.png" alt="PWA Builder score" />](/images/posts/pwa-builder-score.png)

The score also provides links to documentation on how to fix each of the problems. I'm not going to go into detail into each of the problems, but I have written a few articles that explain some of the requirements for creating a PWA:

- [Installable web apps](https://ncona.com/2016/09/installable-web-apps/)
- [PWA install banner](https://ncona.com/2017/11/progressive-web-apps-install-banner/)
- [Using service workers for caching](https://ncona.com/2019/12/using-service-workers-for-caching/)
- [Push notifications on web applications](https://ncona.com/2020/07/push-notifications-on-web-applications/)

## Building the app

Once we are satisfied with our score, we can click on `Build My PWA`. This takes us to a page with options to publish to different app stores.

[<img src="/images/posts/pwa-builder-downloads.png" alt="PWA Builder downloads" />](/images/posts/pwa-builder-downloads.png)

The `Progressive Web App` banner will give us a zip file a few things to help our app be PWA ready. If our app is already a PWA, we can skip this step.

When our PWA is ready we can click the `Android` banner and get a zip file. This file contains a few files necessary to publish our app to the Play Store. The `Readme.html` contains a link to [instructions](https://github.com/pwa-builder/CloudAPK/blob/master/Next-steps.md) for how to use these files.

If we follow the instructions, our file will be reviewed and in a few days it will start appearing in the Play Store.

## Conclusion

PWA Builder makes it very easy to package a PWA so it can be published to the Play Store. On top of that, it gives us the possibility to publish to the Samsung and Microsoft stores to increase visibility.
