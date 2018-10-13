---
id: 3342
title: Adjusting the width of Nerdtree navigator
date: 2015-12-02T17:13:47+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3342
permalink: /2015/12/adjusting-the-width-of-nerdtree-navigator/
categories:
  - Vim
tags:
  - productivity
  - vim
---
Nerdtree is one of my VIM essentials, but I was always annoyed that it took so much space in the screen. Since I use a vertical monitor, I barely get 80 characters to work on. I recently found that this is easily fixed by adding a configuration to .vimrc:

```
let g:NERDTreeWinSize = 20
```

Sometimes, when I was browsing through the folders I actually wanted to be able to make it larger so I could see the complete file names. This is also easy to achieve. Move your cursor to Nerdtree and toggle it using:

```
shift + a
```

<!--more-->
