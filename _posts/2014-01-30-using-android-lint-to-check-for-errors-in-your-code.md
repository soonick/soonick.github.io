---
id: 1838
title: Using Android lint to check for errors in your code
date: 2014-01-30T04:39:25+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1838
permalink: /2014/01/using-android-lint-to-check-for-errors-in-your-code/
tags:
  - android
  - mobile
  - automation
  - debugging
  - java
  - productivity
  - programming
---
Android&#8217;s lint tool allows you to find common issues in your code by running code static analysis against your project. This tool performs some Android specific checks that some other code static analysis tools can&#8217;t do for you. The lint tools comes with the Android SDK under tools/lint. In its most simple form you can use this command:

```
lint <Android project folder>
```

I like this form because I can easily plug it to my CI system:

```
lint <Android project folder> --exitcode
```

<!--more-->

## Configuring

You can configure the errors or warnings lint shows you by placing a file named lint.xml in the root of your project. Inside this file you can specify if you want to make a specific message an error, a warning or ignore it completely:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<lint>
    <issue id="Registered" severity="ignore" />
</lint>
```

You can find a list of all the available warnings you can use:

```
lint --list
```
