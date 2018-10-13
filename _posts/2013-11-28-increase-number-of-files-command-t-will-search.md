---
id: 1861
title: Increase number of files Command-T will search
date: 2013-11-28T01:50:45+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1861
permalink: /2013/11/increase-number-of-files-command-t-will-search/
categories:
  - Vim
---
I was having a problem with Vim&#8217;s Command-T plugin, where it didn&#8217;t find some files. Searching through the documentation I found the problem was that Command-T will search a maximum of 10,000 files by default. This can be changed by adding this to your .vimrc:

```vim
" Increase the number for files Command-T will search "
let g:CommandTMaxFiles=50000
```

<!--more-->
