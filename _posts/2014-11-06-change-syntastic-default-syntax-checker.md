---
id: 2389
title: Change syntastic default syntax checker
date: 2014-11-06T02:16:58+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2389
permalink: /2014/11/change-syntastic-default-syntax-checker/
tags:
  - productivity
  - vim
---
I have recently moved away from JSHint in favor of ESLint and it became annoying that syntastic uses JSHint to check my syntax. Luckily, this is easily configurable. To have syntastic use ESLint instead of JSHint I just added this to my .vimrc file:

```
let g:syntastic_javascript_checkers = ['eslint']
```

You can do this for any language that syntastic supports. The general format is:

```
let g:syntastic_<filetype>_checkers = ['<checker-name>']
```

You could even have more than one syntax checker per language if you wanted:

```
let g:syntastic_javascript_checkers = ['eslint', 'jshint']
```

<!--more-->
