---
id: 4645
title: Modify the name of the Desktop and Downloads folders on Ubuntu
date: 2017-11-10T05:28:17+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4645
permalink: /2017/11/modify-the-name-of-the-desktop-and-downloads-folders-on-ubuntu/
categories:
  - Linux
tags:
  - linux
---
To modify the names of your Desktop and Downloads folder you just modify _~/.config/user-dirs.dirs_:

```
XDG_DESKTOP_DIR="$HOME/desktop"
XDG_DOWNLOAD_DIR="$HOME/downloads"
```
