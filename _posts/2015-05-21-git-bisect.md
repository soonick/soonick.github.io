---
id: 2911
title: Git bisect
date: 2015-05-21T12:10:27+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2911
permalink: /2015/05/git-bisect/
tags:
  - git
  - productivity
---
Git bisect helps you find out the commit that introduced a bug. It has happened a few times that somebody discovers a bug that I knew used to work fine before. When this happens I go back to an arbitrary point in the git history and try to reproduce the bug. If the bug is still present I go back a little more, until I find a point where the bug is not there. Then I try to find the commit that introduced the bug by searching through the commits between the commit I know works and the one I know doesn&#8217;t.

Git bisect helps you do this more efficiently by using a binary search. Lets say you are now in the HEAD of your master branch and you know there is a bug in there. You can start a bisect session by running:

```
git bisect start<br /> git bisect bad
```

<!--more-->

Now you can you back in history and see if the bug is present:

```
git checkout d75b0bd
```

If the bug is still present, you mark this commit as bad and keep going back in history until you find a good one:

```
git commit bad
```

When you find a commit without the bug you can use:

```
git bisect good
```

When you run this command, git will automatically checkout the commit in the middle of your bad and good markers. Now you can check if the bug is present and use **git bisect good** or **git bisect bad** accordingly. Every time you issue one of these commands, git will move you to the middle until it finds the offending commit. Once you find the offending commit, you can look at the changes and figure out what introduced the bug. Once you are done bisecting, you can clean after yourself with this command:

```
git bisect reset
```
