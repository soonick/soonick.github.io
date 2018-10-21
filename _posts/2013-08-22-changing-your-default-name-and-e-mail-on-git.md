---
id: 1679
title: Changing your default name and e-mail on git
date: 2013-08-22T03:35:53+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1679
permalink: /2013/08/changing-your-default-name-and-e-mail-on-git/
tags:
  - git
  - linux
---
If you just installed git in your computer you probably got a message telling you that your name and e-mail haven&#8217;t been configured and suggesting you to change them the first time you commit:

```
git config --global user.name "First Last"
git config --global user.email email@domain.com
git commit --amend --reset-author
```

This will set &#8220;First Last&#8221; and email@domain.com as your default name and email for any git repository you work on in that computer. This may be something you don&#8217;t want because probably you want to have different identities in different computers. One thing you can do is amend your commits with an alternate identity you want to use:

```
git commit --amend --author="First Last <email@domain.com>"
```

If you will constantly be working on this repository this will become annoying really fast, so instead you can set your identity for a specific repository by adding this to your .git/config file:

```
[user]
  name = First Last
  email = email@domain.com
```

<!--more-->
