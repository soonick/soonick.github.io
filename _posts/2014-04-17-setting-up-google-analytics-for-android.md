---
id: 2044
title: Setting up Google Analytics for Android
date: 2014-04-17T05:14:36+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2044
permalink: /2014/04/setting-up-google-analytics-for-android/
tags:
  - android
  - debugging
  - java
  - mobile
  - programming
---
Setting up Google Analytics for a website is as simple as adding a snippet of JS on each of your pages. I was expecting the same for Android apps, but it seems like you need to follow a few steps to get this to work.

## Setting up Google Play services SDK

The Google Analytics library for Android needs to communicate with Google Play API, for this reason, we need to install the SDK. Run this command:

```
android
```

And install the Google Play services package:

[<img src="/images/posts/google_play_services.png" alt="google_play_services" />](/images/posts/google_play_services.png)

<!--more-->

Since you will probably be testing your app on an emulator you will also need to install the Google APIs package for your emulator version:

[<img src="/images/posts/google_apis.png" alt="Google APIs" />](/images/posts/google_apis.png)

And make sure your emulator is targeting Google APIs:

[<img src="/images/posts/Targeting-Google-APIs.png" alt="Targeting Google APIs" />](/images/posts/Targeting-Google-APIs.png)

Then you will need to reference the Google APIs library from your project. You can do that by running these commands from within your project folder:

```
mkdir linkedlibs

cp -r <android-sdk>/extras/google/google_play_services/libproject/google-play-services_lib/ \
linkedlibs/google-play-services_lib/

cd linkedlibs/google-play-services_lib/
android update project --path . --target 1
cd ../..

android update project --target 1 --path . \
--library ./linkedlibs/google-play-services_lib/ \
--subprojects
```

And add this to your projects AndroidManifest.xml under the application section:

```xml
<meta-data android:name="com.google.android.gms.version"
       android:value="@integer/google_play_services_version" />
```

Finally test that everything works fine by running a build:

```
ant debug
```

If get a message complaining about some identifier not working, look at the target version on your project.properties file and make sure it corresponds to your target version. It seems like one of the steps above modifies this number.

## Set up a Google Analytics account

You can use these two resources to create a property and a view:
  
[Set up a property](https://support.google.com/analytics/answer/1042508 "Set up a property")
  
[Add a new view](https://support.google.com/analytics/answer/1009714 "Add a new view")

## Setting up your app

Your app will now need to make network requests to Google Analytics so you need to add these permissions to your manifest:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Google suggests that the tracker is created on the Application class to avoid over counting so if you don&#8217;t have an Application class you will need to create it. First, specify the name of the class in your manifest:

```xml
<application android:label="@string/app_name"
        android:icon="@drawable/ic_launcher"
        android:name=".MyApplication">
```

And create the class on your src directory (src/com/myapp/MyApplication.java):

```java
package my.app;

import android.app.Application;
import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.Tracker;

public class MyApplication extends Application {
    /**
     * Singleton instance of the app tracker
     */
    private Tracker tracker;

    /**
     * Returns your app tracker. Creates a new one if one doesn't yet exist
     */
    synchronized Tracker getSynchronizedTracker() {
        if (null == tracker) {
            GoogleAnalytics analytics = GoogleAnalytics.getInstance(this);
            tracker = analytics.newTracker(R.xml.global_tracker);
        }

        return tracker;
    }

    /**
     * Public method to access app tracker
     */
    public Tracker getTracker() {
        return getSynchronizedTracker();
    }
}
```

You will also need to create an xml file for your global\_tracker (res/xml/global\_tracker.xml):

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
       tools:ignore="UnusedResources">
    <integer name="ga_sessionTimeout">300</integer>
    <bool name="ga_autoActivityTracking">true</bool>
    <string name="ga_trackingId">UA-00000000-1</string>
</resources>
```

And now you can send a page tracking event every time you want:

```java
Tracker t = ((PctApplication)getApplication()).getTracker();
t.setScreenName(pageName);
t.send(new HitBuilders.AppViewBuilder().build());
```

## Debugging

I needed to check that my implementation was working correctly. My first attempt was to setup a proxy and watch for the network requests, but since Google Analytics batches requests it was a little difficult to figure out what was happening. Reading a little I found that there are two important features that help you debug your app.

You probably don&#8217;t want to send tracking calls when you are debugging. To avoid sending calls you can run in dry mode:

```java
final GoogleAnalytics analytics = GoogleAnalytics.getInstance(this);
analytics.setDryRun(true);
```

Then, you can tell Google Analytics to log requests:

```java
final GoogleAnalytics analytics = GoogleAnalytics.getInstance(this);
analytics.getLogger().setLogLevel(LogLevel.VERBOSE);
```

Then you can use logcat to see the requests being made:

```
adb logcat | grep "Sending hit to store"
```
