---
id: 1117
title: Working with Git submodules
date: 2013-03-28T05:09:56+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1117
permalink: /2013/03/working-with-git-submodules/
tags:
  - git
---
Git submodules is a way to organize your code so you can include libraries or other projects into your project. You want to treat these libraries as a separate repository so they are by themselves versioned by git in another repository.

Lets start with a very simple, but not very practical example:

```
# Create a git repository
mkdir somedir
cd somedir
touch file
git add file
git commit -m 'Added file'

# Create another repository inside the current repository
mkdir submodule
cd submodule
touch submodule_file
git add submodule_file
git commit -m 'Added file'

# Add the child repository to the parent repository as a submodule
cd ..
git submodule add ./submodule/
git commit -m 'Added submodule'
```

<!--more-->

One interesting thing here is what you get when you run git status:

```
git status
# On branch master
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#   new file:   .gitmodules
#   new file:   submodule
#
```

You get a new file with the name **.gitmodules**. This file tells git where to find the submodule repository. For this example we created a folder and a new repository in that folder, a more common use case would have been to clone a remote repository inside a folder inside our current repository and then adding it as a submodule. Here is the content of .gitsubmodules:

```
[submodule "submodule"]
    path = submodule
    url = ./submodule/
```

At this point you can use the two repositories independently. If you make changes into the parent repository you can just commit them and they won&#8217;t affect the child repository in any way. When you make changes into the child repository you will probably want to update the parent accordingly. Lets see some examples:

```
# We are on the parent repository
touch other_file
git add other_file
git commit -m 'Added other file'
git lg
* 7962ef9 - (HEAD, master) Added other file (2013-03-19 20:34:24 -0700) <Adrian>
* 6eb9219 - Added submodule (2013-03-19 20:27:10 -0700) <Adrian>
* 78b7dc6 - Added file (2013-03-19 20:24:18 -0700) <Adrian>
```

Everything good so far. Now lets see what happens when we change the submodule:

```
cd submodule
touch abc
git add abc
git commit -m 'Other submodule file'
git lg
* 1c88b82 - (HEAD, master) Other submodule file (2013-03-19 20:38:25 -0700) <Adrian>
* a2ff9d0 - Added file (2013-03-19 20:24:05 -0700) <Adrian>
```

Good so far, but lets see what happens when we move back to the parent:

```
cd ..
git status
# On branch master
# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
#   modified:   submodule (new commits)
#
no changes added to commit (use "git add" and/or "git commit -a")
```

This message is telling us that the current commit in our parent repository is pointing to a commit in the submodule that is not the current one. We can move back to the commit which our parent repository knows about like this:

```
git submodule update
Submodule path 'submodule': checked out 'a2ff9d0a876ca7516e82fef5ee6476074e5284ba'
git status
# On branch master
nothing to commit, working directory clean
```

If we move back to our submodule we will see that we just move the HEAD pointer to a previous commit:

```
cd submodule
git lg
* a2ff9d0 - (HEAD) Added file (2013-03-19 20:24:05 -0700) <Adrian>
```

There will be a point where we want to update our parent repository to point to a newer commit, we can update our parent pointer like this:

```
git checkout master
cd ..
git add submodule/
git commit -m 'Updated submodule pointer'
git lg
* 5951ca2 - (HEAD, master) Updated submodule pointer (2013-03-19 20:45:30 -0700) <Adrian>
* 7962ef9 - Added other file (2013-03-19 20:34:24 -0700) <Adrian>
* 6eb9219 - Added submodule (2013-03-19 20:27:10 -0700) <Adrian>
* 78b7dc6 - Added file (2013-03-19 20:24:18 -0700) <Adrian>
```

If we move back in our repository history we may get a message telling us that our repository has new commits. In that case we need to use **git submodule update** to move all our repositories to the state there where on that commit.W

## Cloning a repository with submodules

When you clone a repository that contains submodule you will only get the information from the parent repository, to retrieve all the submodules data you have to run **git submodule update &#8211;init**:

```
# From parent repository
cd ..
git clone somedir otherdir
cd otherdir
git submodule update --init
```
