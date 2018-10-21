---
id: 2004
title: Building back stack correctly when coming from a notification on Android
date: 2014-05-01T05:25:13+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2004
permalink: /2014/05/building-back-stack-correctly-when-coming-from-a-notification-on-android/
tags:
  - mobile
  - android
  - design_patterns
  - java
  - programming
---
After I added some notifications to my app I noticed that they weren&#8217;t behaving the way I wanted them to behave. When I clicked on a notification I landed on one of my internal screens. When I clicked back I was expecting to go to the main screen but instead it went back to the phone home.

After reading a little I discovered that there is a difference between navigating back and navigating up (Read the related links to learn more), and that I needed to properly set the up navigation before I could fix this.

To set the up navigation correctly you need to specify a parent for each of your activities in your manifest:

```xml
<activity android:name="Internal" android:label="@string/app_name"
       android:screenOrientation="portrait"
       android:parentActivityName=".MainActivity">
    <meta-data
           android:name="android.support.PARENT_ACTIVITY"
           android:value=".MainActivity" />
</activity>
```

<!--more-->

The meta-data tag is necessary to support Android API 4 and older. If you want to do this you will also need to include the Android Support Library with your app.

With this information in your manifest you will be able to have a notification land your users in an internal screen but also have the up stack built automatically for you. To do this you only need to use **addNextIntentWithParentStack** while building the pending intent:

```java
final Intent resultIntent = new Intent(thisContext, destination);
final PendingIntent pi = TaskStackBuilder.create(thisContext)
    .addNextIntentWithParentStack(resultIntent)
    .getPendingIntent(0, PendingIntent.FLAG_UPDATE_CURRENT);
```
