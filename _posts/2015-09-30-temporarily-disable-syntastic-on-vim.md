---
id: 3186
title: Temporarily disable Syntastic on Vim
date: 2015-09-30T16:22:31+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3186
permalink: /2015/09/temporarily-disable-syntastic-on-vim/
categories:
  - Vim
tags:
  - productivity
  - vim
---
Every now and then I have to dig into other people&#8217;s code that doesn&#8217;t comply to my coding standards. When I make a change on these files, Syntastic lights up like a Christmas tree. Since this is not my code and I can&#8217;t really fix it, I prefer to temporarily disable Syntastic:

```
:set SyntasticToggleMode
```

<!--more-->
