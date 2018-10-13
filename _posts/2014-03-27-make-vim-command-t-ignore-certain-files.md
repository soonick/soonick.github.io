---
id: 1996
title: Make vim Command-T ignore certain files
date: 2014-03-27T01:52:31+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1996
permalink: /2014/03/make-vim-command-t-ignore-certain-files/
categories:
  - Vim
tags:
  - android
  - java
  - productivity
---
Since I have been working with Java I found annoying every time I used Command-T to look for a file it showed me not only the source code file, but also the .class file. Looking at the documentation I found that there is a way to have Command-T ignore certain files. Just add this to your .vimrc

```
set wildignore+=*.class
```

<!--more-->
