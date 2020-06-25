---
title: Git tips
author: adrian.ancona
layout: post
# date: 2020-07-01
# permalink: /2020/07/git-tips/
tags:
  - productivity
  - git
---

I have been using git for a while, and I feel pretty comfortable using it. I often find myself sharing tips on how to better use git at work, so I decided to write an article where I can share this tips with the world.

## Introduction

In the beginning of times, there were centralized version control systems (`SVN` and `Perforce` are examples). This means that there is a server somewhere that contains all our code and the history of all the changes. If someone needs to work on that codebase they do a `checkout` (typically of the main branch) and they will get the newest version of all the files.

If the server looks something like this (Every letter represents a different commit):

[<img src="/images/posts/source-control-server.png" alt="Source control server" />](/images/posts/source-control-server.png)

When a developer checks out `main`, they will get only the files at `D`, the history about the past commits exists only in the server. This has a two main disadvantages:

- It is not possible to create local branches. If a developer needs a branch they have to push it to the server
- If the server explodes, all the history is lost

<!--more-->

Git is a distributed version control system, what this means is that a developer `clones` a repo before it starts working on it. The developer's machine will contain not only the files necessary for working, but also the history of all commits. By doing this, we avoid the two problems mentioned above.

## Creating a repo

If we want to create a new repo:

```sh
mkdir new-repo
cd new-repo
git init
```

## Creating a commit

Once we are on a repo, the next thing we want to do is create a commit. A commit is an entry in the history of our repo. Let's start by creating a file:

```sh
touch README.md
```

We can use `git status` to see the state of our repo, compared to the previous committed state:

```sh
$ git status
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	README.md

nothing added to commit but untracked files present (use "git add" to track)
```

The command tells us that we are standing in `master` and that we have a file that is not yet being tracked.

In git, the commit process has two stages:

1. Select what we want to include in the commit
2. Commit the changes

When we select what we want to commit we say we are moving it to the `staging` area. Let's do that:

```sh
git add README.md
```

We can see that the status changed:

```
$ git status
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

	new file:   README.md
```

We can now commit the change:

```sh
git commit -m 'Added readme file'
```

## Looking at the history

If we want to see the list of commits from where we are standing:

```sh
git log
```

The output looks something like this:

```sh
$ git log
commit 0eba2722139ff6e91baaeb6540d4ce76c5e33d48 (HEAD -> master)
Author: User Usernikov <user@userni.kov>
Date:   Thu Jun 25 21:53:16 2020 +1000

    Added readme file
```

I personally prefer a more compact view that can be achived with this command:

```sh
git log --graph --all --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an (%ae)>'
```

The output looks like this:

```
* 0eba272 - (HEAD -> master) Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

Because that's a very long command, I prefer to create an alias for it. To create an alias:

```sh
git config --global alias.lg "log --graph --all --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an (%ae)>'"
```

The command creates a git alias named `lg`. Now, we can use this command:

```sh
git lg
```

## Branches

In the section above, you probably noticed `0eba272 - (HEAD -> master)` as part of the log ouput. There are a few important pieces of information.

- `0eba272` - The commit hash. A unique identifier for each commit
- `HEAD` - Represents the commit where we are currently standing
- `master` - Branch name

From this information we can say that `master` is currently located at `0eba272` and our `HEAD` is pointing to master. Let's create a new branch:

```sh
$ git branch first-branch
$ git lg
* 0eba272 - (HEAD -> master, first-branch) Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

We created a new branch, but as we can see, `HEAD` is still pointing to `master`. Let's see what happens if we create a commit:

```sh
$ echo "Git demo" >> README.md
$ git add README.md
$ git commit -m 'Add title to readme'
$ git lg
* 0af5c64 - (HEAD -> master) Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
* 0eba272 - (first-branch) Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

We can see that a new commit was created and both `HEAD` and `master` are now in that commit. Our `first-branch` was left behind. If we want to create a branch and move to it immediately, we can use:

```sh
$ git checkout -b second-branch
$ git lg
* 0af5c64 - (HEAD -> second-branch, master) Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
* 0eba272 - (first-branch) Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

This time `HEAD` moved. It's now pointing to `second-branch`. To switch branches:

```sh
$ git checkout first-branch
$ git lg
* 0af5c64 - (second-branch, master) Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
* 0eba272 - (HEAD -> first-branch) Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

Let's se what happens when we create a commit from here:

```sh
$ touch other.file
$ git add other.file
$ git commit -m 'Added other file'
$ git lg
* 07c7128 - (HEAD -> first-branch) Added other file (2020-06-25 22:08:23 +1000) <User Usernikov (user@userni.kov)>
| * 0af5c64 - (second-branch, master) Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
|/
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

The alias we created to see the history, has the advantage of showing us places where the history branches out of the main trunk. To see a list of all our branches:

```sh
git branch -v
```

## Merging






This is all that's needed to create an empty repo. If we look at the contents of the folder, we'll see a `.git` directory was created, that's where all the magic happens.

Instead of creating a new repo, we might want to collaborate to repo that already exists, to do that, we can `clone` it:

```sh
git clone git@github.com:user/repo.git
```

A new folder will be created with the same name as the repo. If for some reason, we want to clone into a different folder, we can specify the path as an argument:

```sh
git clone git@github.com:user/repo.git ~/my-repo
```

For us to be able to clone a repo from a place like github, it means that github has a copy of our repo. This "central" copy is special in that nobody works directly on it, it's just a helps develpers have a place where all changes are integrated.

When developer work on a github repo, they have a folder with the files they are working on and there is a `.git` folder that keeps the history. Github's copy is never working on the files, so it just keeps a folder withe metadata. This is called a `bare` repo.

We could create a bare repo ourselves if we wanted to:

```sh
git clone git@github.com:user/repo.git --bare
```

This would create a folder named `repo.git` that contains only metadata. This copy could be used to create non-bare clones that can be used by developers.

## Remotes

When we clone a repo, we automatically get a `remote` added to our local repo. We can list our remotes:

```sh
git remote -v
```

It's very common for people to work with only one remote, but it's possible to have multiple remotes if desired. A `remote` is just an identifier (In this case `origin`) and an associated URL that points to a repo somewhere else.














[laptop ~/repos/soonick.github.io] $ git config --list
user.name=User Usingston
user.email=annovelo@amazon.com
alias.lg=log --graph --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an>'
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
remote.origin.url=git@github.com:soonick/soonick.github.io.git
remote.origin.fetch=+refs/heads/*:refs/remotes/origin/*
branch.master.remote=origin
branch.master.merge=refs/heads/master
user.name=User Usingston
user.email=user@email.com
