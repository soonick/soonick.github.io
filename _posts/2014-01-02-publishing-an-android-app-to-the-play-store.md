---
id: 1909
title: Publishing an Android app to the play store
date: 2014-01-02T02:37:35+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1909
permalink: /2014/01/publishing-an-android-app-to-the-play-store/
categories:
  - Mobile development
---
There is extensive documentation of what you need to do to release your app in the Android documentation. It is so much documentation that I wanted to gather a more straight forward list of steps.

## Create a self-signed key

To generate your key, use this command:

```
keytool -genkey -v -keystore my-release-key.keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000
```

You will be prompted for a password (You might want to use a strong one) for your keystore. Then you will be asked for some information and finally another password for your key (You can use the same as the one you used for the keystore). That will generate a file called my-release-key.keystore. Keep this file in a safe place because you will need it every time you update your app.

<!--more-->

## Create release version of your app

First you need to give some information to ant so it can sign your app. Add this to your ant.properties file:

```
key.store=path/to/my.keystore<br /> key.alias=alias_name
```

Then run:

```
ant release
```

You will be prompted (Be careful because your password will be visible in the screen) for your keystore and key passwords. When the build is completed you can find your app in bin/<app-name>-release.apk

## Add an icon

Create an icon 512x512 pixels in size. That will be your base icon, then you will have to resize it and place a copy of it in these locations:

```
res/drawable-ldpi/ic_launcher.png (36x36)
res/drawable-mdpi/ic_launcher.png (48x48)
res/drawable-hdpi/ic_launcher.png (72x72)
res/drawable-xhdpi/ic_launcher.png (96x96)
res/drawable-xxhdpi/ic_launcher.png (144x144)
```

## Publish to play store

To publish your app in the play store you will need to [sign up for an account](https://play.google.com/apps/publish/signup/ "Sign up for a google play account"). Your Google play account needs to be associated with a gmail account. You will also need to pay a $25 usd registration fee.

After you register you can use the &#8220;Add new application button&#8221; to add an app. You will need fill information about your app and provide images and screenshots.
