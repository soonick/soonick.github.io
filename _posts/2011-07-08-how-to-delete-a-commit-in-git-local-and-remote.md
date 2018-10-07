---
id: 286
title: How to delete a commit in git, local and remote
date: 2011-07-08T23:42:45+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=286
permalink: /2011/07/how-to-delete-a-commit-in-git-local-and-remote/
categories:
  - Git
tags:
  - Git
  - github
---
It has happened to me more than once that I make a commit without verifying the changes I am committing. Time after that I review the commit and I notice that there is something in the commit that doesn&#8217;t belong there.

In those times what I want to do is make a patch with the changes of the commit, delete the commit, apply the patch and then redo the commit only with the changes I intended. In this post I will only explain how to delete a commit in your local repository and in a remote repository in case you have already pushed the commit.

<!--more-->

## Delete a local commit

> Anthony Dentinger showed me in the comments that you can delete a local commit by doing:
> 
> git reset &#8211;hard HEAD~
> 
> Below is my original post, but you probably just want to use the line above

Lets say there is a repository with 4 commits.

```
$git log --pretty=oneline --abbrev-commit
46cd867 Changed with mistake
d9f1cf5 Changed again
105fd3d Changed content
df33c8a First commit
```

Commit 46cd867 is the most recent commit and the one we want to delete, for doing that, we will use rebase.

```
$git rebase -i HEAD~2
```

That command will open your default text editor with your two (Change the number 2 with the number of commits you want to get) latest commits:

```
pick d9f1cf5 Changed again
pick 46cd867 Changed with mistake

# Rebase 105fd3d..46cd867 onto 105fd3d
#
# Commands:
#  p, pick = use commit
#  r, reword = use commit, but edit the commit message
#  e, edit = use commit, but stop for amending
#  s, squash = use commit, but meld into previous commit
#  f, fixup = like "squash", but discard this commit's log message
#  x, exec = run command (the rest of the line) using shell
#
# If you remove a line here THAT COMMIT WILL BE LOST.
# However, if you remove everything, the rebase will be aborted.
#
```

One thing to notice here is that the most recent commit is the one at the bottom. The comments at the bottom of the file give a description of the things that can be done with the rebase command, but this time none of this options is going to be used, we just need to delete the line that corresponds to the commit we want to delete and save the file.

We can see that the change was applied correctly:

```
$git log --pretty=oneline --abbrev-commit
d9f1cf5 Changed again
105fd3d Changed content
df33c8a First commit
```

## Delete a remote commit

To remove a commit you already pushed to your origin or to another remote repository you have to first delete it locally like in the previous step and then push your changes to the remote.

```
$git push origin +master
```

Notice the + sign before the name of the branch you are pushing, this tells git to force the push. It is worth to mention that you should be very careful when deleting commits because once you do it they are gone forever. Also, if you are deleting something from a remote repository make sure you coordinate with your team to prevent issues.