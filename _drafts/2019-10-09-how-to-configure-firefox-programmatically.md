---
title: How to configure Firefox programmatically
author: adrian.ancona
layout: post
date: 2019-10-09
permalink: /2019/10/how-to-configure-firefox-programmatically/
tags:
  - linux
  - automation
  - bash
---

I reinstalled Ubuntu on my personal computer recently and I noticed that there are some things I don't like about the default distribution. One of things I noticed is that Firefox keeps asking me if I want it to remember my passwords, which I don't.

I know that I can go to settings and disable this feature, but I wanted to learn how to do it programmatically, so in the future I can just run a script and have Firefox work the way I want.

## Preferences

There is documentation explaining [how preferences work for mozilla projects](https://developer.mozilla.org/en-US/docs/Mozilla/Preferences/A_brief_guide_to_Mozilla_preferences), but it's a little hard to understand how to exactly do what I wanted to do.

<!--more-->

When Firefox is loaded, there are a few preferences files that are loaded. The combination of these files determine the configuration that Firefox will use for that run.

When a user makes a change to a Firefox preference via the UI, the change is written to `prefs.js`. This file should never be edited manually because changes might get overwritten. To get a UI where you can modify any preference you can enter `about:config` in Firefox URL bar.

For custom configurations we can write our desired changes to one of two files:

- `all-<something>.js` - Sets configurations for all users in that host
- `user.js` - Sets configurations for a specific user

The `all-<something>.js` method is usually preferred, because a user might want to set their own preferences. If `user.js` method is used, anything they set will be overwritten by the values set by the administrator on every Firefox run.

## Setting preferences

The tricky thing for me was finding where the `all-<something>.js` file should live. The documentation says `install_directory`, but it wasn't clear to me where this was for Ubuntu. It turns out, the install directory is: `/usr/lib/firefox/`.

To set a preference we can use the `pref()` method. I created a bash script to do this for me:

```bash
# Configure firefox
ff_preferences="/usr/lib/firefox/browser/defaults/preferences/all-company.js"
touch $ff_preferences
echo "pref('signon.rememberSignons', false);" >> $ff_preferences
```

## Finding preferences

Finding which preference to change can also be tricky. The best I could find was a [list of preferences](http://kb.mozillazine.org/About:config_entries) with short descriptions, but it can be hard to find what you are looking for.
