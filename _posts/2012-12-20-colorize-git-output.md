---
id: 1081
title: Colorize git output
date: 2012-12-20T06:29:30+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1081
permalink: /2012/12/colorize-git-output/
tags:
  - git
  - linux
  - programming
---
In linux git doesn&#8217;t show colors by default. To make git diff, log, status, etc&#8230;, show pretty colors you need to issue this command from a terminal:

```
git config --global color.ui true
```

<!--more-->
