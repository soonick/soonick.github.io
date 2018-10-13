---
id: 1731
title: Different settings for different language in vim
date: 2013-09-05T03:29:01+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1731
permalink: /2013/09/different-settings-for-different-language-in-vim/
categories:
  - Vim
tags:
  - linux
  - productivity
  - vim
---
Recently I have been mostly working in JavaScript and per my project standards, all my tabs are replaced by 2 spaces. The problem with this is that for other projects in other programming languages the standard tab width is 4 spaces, so it becomes annoying to have to hit tab twice to indent a line correctly. To fix this you can declare settings specific for a language if you place them on **~/.vim/ftplugin/LANGUAGE.vim**.

Since currently I am working on an Android app and I want a tab width of 4, I created the file **~/.vim/ftplugin/java.vim** and added this content:

```vim
" Make tabs 4 spaces wide "
set tabstop=4
set shiftwidth=4
```

<!--more-->
