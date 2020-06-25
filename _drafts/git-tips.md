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

Git is a distributed version control system, what this means is that a developer `clones` a repo before it starts working on it. The developer's machine will contain not only the files necessary for working, but also the history of all commits. By doing this, we avoid the two problems mentioned above.

## Repos

If we want to create a new repo:

```
mkdir new-repo
cd new-repo
git init
```

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

## Branches

Another thing we get when we clone (or create) a repo is a branch. Git's default branch is called `master`. A branch is an identifier that points to a place in the commit history. To list branches:

```sh
git branch -v   # Only local branches
git branch -va  # Include branches in remotes
```







[laptop ~/repos/soonick.github.io] $ git config --list
user.name=Adrian Ancona Novelo
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
user.name=Adrian Ancona Novelo
user.email=soonick5@yahoo.com.mx






git config --global alias.lg "log --graph --all --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%ci) %C(bold blue)<%an (%ae)>'"



