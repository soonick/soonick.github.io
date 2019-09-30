---
title: Hide snap folder in Ubuntu
author: adrian.ancona
layout: post
date: 2019-10-16
permalink: /2019/10/hide-snap-folder-in-ubuntu/
tags:
  - linux
  - bash
---

Ubuntu recently introduced `snaps`. Snaps are a new way of packaging applications in a way that there will be no dependency conflicts (because all dependencies are included). The only problem is that Ubuntu will create a `snap` folder in your home folder that you will most likely never need to access.

If you, like me, find this folder annoying, you can hide it from Nautilus:

```sh
cd ~
echo snap >> ~/.hidden
```

This makes the folder invisible in Nautilus, but it will still be visible in other places (The terminal, for example).
