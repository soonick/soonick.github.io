---
id: 639
title: Pushing and deleting remote branches with git
date: 2012-06-07T00:28:20+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=639
permalink: /2012/06/pushing-and-deleting-remote-branches-with-git/
tags:
  - git
  - github
---
Creating new branches and deleting them locally is an easy task with git, but when it comes to doing it for a remote repository, happily, it is very easy too.

## Pushing a branch

If you have a new branch named **mybranch** on your local repository and you want to push it to a remote so other people can see it you can do:

```
git push remotename mybranch
```

Most of the time you will probably want to push to the origin remote, so the command will be something like this:

```
git push origin mybranch
```

<!--more-->


## Deleting a branch

Deleting a remote branch has a syntax that feels a little weird, but it remains an easy task. If you wanted to delete a branch named **mybranch** from a remote you would do this:

```
git push remotename :mybranch
```

The way to see this command is like pushing empty to a remote. So you are telling git to go to remotename then find mybranch and push empty on it. This sounds weird, but what it really does is deleting the branch.
