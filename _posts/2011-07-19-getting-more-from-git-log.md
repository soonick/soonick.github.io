---
id: 302
title: Getting more from git log
date: 2011-07-19T02:03:10+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=302
permalink: /2011/07/getting-more-from-git-log/
tags:
  - git
  - github
---
This post is basically a copy of [pimping out git log](http://www.jukie.net/bart/blog/pimping-out-git-log "Pimping out git log"). I just made some modifications to Bart&#8217;s alias to fit my personal preferences.

This code creates an alias named lg for the git:

```
git config --global alias.lg "log --graph --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>'"
```

Here is an explanation of what that command does:

```
git config --global alias.lg "..."
```

<!--more-->

This instruction creates a custom git command that when called is going to execute whatever string you passed to it.

```
log --graph --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>'
```

This is the log command with some useful modifiers.

**&#8211;graph** Shows a graph of the branches and merges

**&#8211;pretty=format:&#8217;%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>&#8217;** Specifies a format to show the commit message. **%C** specifies a color. **%h** means abbreviated commit hash. **%d** shows the current position of other branches. **%Creset** resets color to default. %s is the commit message. **%ci** Is the commit date in ISO 8601 format. **%an** means author name.

With this information you should be able to modify it to fit your needs.

To use the alias just type in a terminal:

```
git lg
```

&nbsp;
