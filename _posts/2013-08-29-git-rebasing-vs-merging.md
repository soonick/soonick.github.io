---
id: 1703
title: Git rebasing vs merging
date: 2013-08-29T03:53:36+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1703
permalink: /2013/08/git-rebasing-vs-merging/
categories:
  - Git
tags:
  - Git
  - productivity
---
When I switched to git for the first time I had a very hard time understanding what rebasing did to a point where I totally avoided it. I had been doing all my work on private and public repositories by going to master and merging to my feature branch or to a team member&#8217;s branch. I was happy with this way of working until I started on my new job a few months ago and they had a rebase based workflow. It goes something like this:

```
cd repo
git pull --rebase
// Do some work and add stage it
git commit -m 'Some message'
git pull --rebase
git push origin master
```

In this little example I am working in my local master branch, but if I wanted I could create a feature branch and rebase it to master as needed. The most obvious benefit about this workflow is a very clean history. Lets look at a simple example of a merge based history:

<!--more-->

```
*   a1b2bbf - (HEAD, master) Merge branch 'feature' (2013-08-28 20:31:08 -0700) <Adrian>
|\
| * 1337ff1 - Commit on branch (2013-08-28 20:30:17 -0700) <Adrian>
* | 76aa59b - Other commit on master (2013-08-28 20:30:55 -0700) <Adrian>
|/
* e4f0a29 - One commit on master (2013-08-28 20:29:48 -0700) <Adrian>
```

You can see in this three that commit **a1b2bbf** is specifically to merge branch master into feature. If we use rebase we can remove this commit from our history. Say that we are on commit **e4f0a29**, we could follow this flow:

```
git checkout -b feature
// Work and add to staging
git commit -m 'Commit on branch'
git checkout master
// Work and add to staging
git commit -m 'Commit on master'
git rebase feature
git branch -d feature
```

And get this result:

```
* 453808e - (HEAD, master) Commit on master (2013-08-28 20:40:09 -0700) <Adrian>
* 1ce21f6 - Commit on branch (2013-08-28 20:38:19 -0700) <Adrian>
* e4f0a29 - One commit on master (2013-08-28 20:29:48 -0700) <Adrian>
```

You can see that we have all our commits in the master branch and we don&#8217;t introduce a useless commit. Although the most obvious benefit is an easier to read history, this approach also makes reverting a change a lot simpler than if you had merged it. At any point in time you will be able to use revert on a commit:

```
git revert 1ce21f6
```

```
* aab8830 - (HEAD, master) Revert "Commit on branch" (2013-08-28 20:45:07 -0700) <Adrian>
* 453808e - Commit on master (2013-08-28 20:40:09 -0700) <Adrian>
* 1ce21f6 - Commit on branch (2013-08-28 20:38:19 -0700) <Adrian>
* e4f0a29 - One commit on master (2013-08-28 20:29:48 -0700) <Adrian>
```
