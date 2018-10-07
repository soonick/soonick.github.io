---
id: 383
title: Creating and applying patches with git
date: 2012-04-13T03:05:42+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=383
permalink: /2012/04/creating-and-applying-patches-with-git/
categories:
  - Git
tags:
  - Git
  - github
---
Creating and applying patches using git is a task relatively easy to do. I will show how it all works using an example scenario.

Let&#8217;s say we have a main repository with just one commit on it:

```
adrian@laptop:~/repository$ git lg
* ff4c135 - (HEAD, master) first commit (2012-04-12 19:14:39 -0700) <Juanito>
```

That repository has been copied by other people that are working on the same project. Now lets say that I am the one that cloned the main repository and did some work on it:

```
adrian@laptop:~/copy$ git lg
* be3ec44 - (HEAD, origin/master, origin/HEAD, master) Third commit (2012-04-12 19:16:28 -0700) <Adrian>
* 1551977 - second commit (2012-04-12 19:16:00 -0700) <Adrian>
* ff4c135 - first commit (2012-04-12 19:14:39 -0700) <Juanito>
```

<!--more-->

I have two commits that I want to include on my patch, so there are a couple of ways of doing it. We can create one patch for each commit with this command:

```
adrian@laptop:~/copy$ git format-patch -2
0001-second-commit.patch
0002-Third-commit.patch
```

As you can see, this command generates one patch file for each commit. You can add more or less commit files by modifying the **-2** argument with the number that fits your needs. The thing I don&#8217;t like about this is that there is one file for each patch, so If you wanted to send your patches to someone you would have to send two files for this case. We can put all the patches in just one file using this command:

```
adrian@laptop:~/copy$ git format-patch -2 --stdout > commits.patch
```

Now it doesn&#8217;t matter how many commits we are sending we just have one file to worry about.

To apply this patch in our master repository we would have to run something like this:

```
adrian@alaptop:~/repository$ git am -s commits.patch
Applying: second commit
Applying: Third commit
```

And our history would look something like this:

```
adrian@laptop:~/repository$ git lg
* e82e0cf - (HEAD, master) Third commit (2012-04-12 19:51:51 -0700) <Adrian>
* 8856ba7 - second commit (2012-04-12 19:51:51 -0700) <Adrian>
* ff4c135 - first commit (2012-04-12 19:14:39 -0700) <Juanito>
```
