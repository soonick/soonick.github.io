---
id: 5128
title: Setting the search directory for Ctrlp vim plugin
date: 2018-06-07T01:54:37+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=5128
permalink: /2018/06/setting-the-search-directory-for-ctrlp-vim-plugin/
tags:
  - productivity
  - vim
---
By default ctrlp will look for the root of your repo (by looking for a .git, .hg, .svn or .bzr file) and then start searching for files in that folder. For the project I&#8217;m currently working on that has too many files (Probably millions) I prefer that ctrlp only searches inside the folder were I started vim. This can be done with this setting in .vimrc:

```
let g:ctrlp_working_path_mode = 'a'
```

<!--more-->
