---
id: 3246
title: 'gms.StatusHelper Status from wire: INVALID_AUDIENCE status: null'
date: 2015-10-28T08:14:27+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3246
permalink: /2015/10/gms-statushelper-status-from-wire-invalid_audience-status-null/
tags:
  - mobile
  - android
  - debugging
  - projects
---
This weekend I decided to resume work on an Android project I had left behind. Once I had my environment set up I kept getting this error:

```
W GLSActivity: gms.StatusHelper Status from wire: INVALID_AUDIENCE status: null
```

After some googling I found the problem was that I was trying to call a google service from an app using a signature not registered in my project. I fixed it by going to the developer console for my project:

<!--more-->

[<img src="/images/posts/google-dev-console.png" alt="google-dev-console" />](/images/posts/google-dev-console.png)

And modifying the signing certificate fingerprint:

[<img src="/images/posts/sing-certificate.png" alt="sing-certificate" />](/images/posts/sing-certificate.png)

If you are doing a debug build, you most probably are using the debug keystore, so you can get the fingerprint by running:

```
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -list
Enter keystore password:

*****************  WARNING WARNING WARNING  *****************
* The integrity of the information stored in your keystore  *
* has NOT been verified!  In order to verify its integrity, *
* you must provide your keystore password.                  *
*****************  WARNING WARNING WARNING  *****************

androiddebugkey, Sep 20, 2015, PrivateKeyEntry,
Certificate fingerprint (SHA1): AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:AA:19:83:90:F5:CF:CC:CC:CC
```

When prompted for the password, just hit enter.
