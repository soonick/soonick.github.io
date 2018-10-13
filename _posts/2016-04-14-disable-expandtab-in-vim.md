---
id: 3656
title: Disable expandtab in Vim
date: 2016-04-14T17:25:56+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3656
permalink: /2016/04/disable-expandtab-in-vim/
categories:
  - Vim
tags:
  - productivity
  - vim
---
I like to use spaces instead of tabs so I have this line in my .vimrc file:

```
set expandtab
```

This line will write spaces instead of tabs every time I hit the tab key.

Lately I&#8217;ve been working a little with Go. The standard in Go is to use tabs instead of spaces so I needed to change this preference for Go projects. The only thing that I needed to do is to add this line to my project .vimrc file:

```
set expandtab!
```

<!--more-->
