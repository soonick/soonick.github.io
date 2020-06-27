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

In the section above, we can see `0eba272 - (HEAD -> master)` as part of the log ouput. There are a few important pieces of information.

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

## Remotes

When we create a repo using `git init`, the repo exists only in the folder where we created it. Usually we want to host our repos in a centralized location so it act as the source of truth for a team.

One interesting thing about centralized source code locations is that nobody actually works in there, it's just a place for integration. For this reason the location where everybody pushes to doesn't have a working directory, it just keeps track of the history of all files. This is called a bare repo. We can create a bare repo if we want:

```sh
# Assuming we are in `new-repo` folder
cd ..
git clone new-repo main-repo --bare
```

This creates a new folder called `main-repo`, that contains something very similar to `new-repo/.git`.

Let's say we want to use this new folder as the souce of truth for our repo. We would need to make `new-repo` aware of it.

```sh
git remote add origin ../main-repo/
```

The main `remote` for a repo, is usually called `origin`, which is what we called this remote. We can have multiple remotes, but it's common to have a single one. To see our remotes and where they are hosted:

```sh
$ git remote -v
origin	../main-repo/ (fetch)
origin	../main-repo/ (push)
```

If we `fetch` from `origin`, we can will get all remote branches:

```sh
$ git fetch origin
From ../main-repo
 * [new branch]      first-branch  -> origin/first-branch
 * [new branch]      master        -> origin/master
 * [new branch]      second-branch -> origin/second-branch
```

And we can see them when we list all the branches (`-a` includes remote branches):

```sh
$ git branch -av
* first-branch                 07c7128 Added other file
  master                       0af5c64 Add title to readme
  second-branch                0af5c64 Add title to readme
  remotes/origin/first-branch  07c7128 Added other file
  remotes/origin/master        0af5c64 Add title to readme
  remotes/origin/second-branch 0af5c64 Add title to readme
```

It's very common to have the `master` branch track `origin/master`. What this means is that the local `master` will by default be pushed to `origin/master` and changes from `origin/master` will be integrated into local `master` when they are pulled. Let's make our master track `origin/master`:

```sh
$ git checkout master
Switched to branch 'master'

$ git branch -u origin/master
Branch 'master' set up to track remote branch 'master' from 'origin'.
```

We can now commit a change to master and push it to our remote:

```sh
$ touch file-in-master
$ git add file-in-master
$ git commit -m 'Add file-in-master'
[master 4e87837] Add file-in-master
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 file-in-master

$ git push
Counting objects: 3, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 285 bytes | 285.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To ../main-repo/
   0af5c64..4e87837  master -> master
```

If we look at the history, we'll see that both `master` and `origin/master` are positioned in the same place:

```
$ git lg
* 4e87837 - (HEAD -> master, origin/master) Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
* 0af5c64 - (origin/second-branch, second-branch) Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
| * 07c7128 - (origin/first-branch, first-branch) Added other file (2020-06-25 22:08:23 +1000) <User Usernikov (user@userni.kov)>
|/
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

## Merging

We can see in our history that `first-branch` is not part of the master branch. To add it to master, we need to merge it.

```
# Assuming we are in master
$ git merge first-branch
Merge made by the 'recursive' strategy.
 other.file | 0
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 other.file

$ git lg
*   118729e - (HEAD -> master) Merge branch 'first-branch' (2020-06-26 21:48:11 +1000) <User Usernikov (user@userni.kov)>
|\
| * 07c7128 - (origin/first-branch, first-branch) Added other file (2020-06-25 22:08:23 +1000) <User Usernikov (user@userni.kov)>
* | 4e87837 - (origin/master) Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
* | 0af5c64 - (origin/second-branch, second-branch) Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
|/
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

This created a `merge commit` to integrate the changes from `first-branch` into `master`. Now, all changes are part of master.

## Cherry picking

Let's we didn't do that merge and we are still at this stage:

```sh
* 4e87837 - (HEAD -> master, origin/master) Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
* 0af5c64 - (origin/second-branch, second-branch) Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
| * 07c7128 - (origin/first-branch, first-branch) Added other file (2020-06-25 22:08:23 +1000) <User Usernikov (user@userni.kov)>
|/
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

Another way we can add the `first-branch` commit to master is by `cherry-picking` it. This is useful when we have commits in different branches, but we don't want to merge the whole branch, we just want a single commit. To do this:

```sh
# Assuming we are in master
$ git cherry-pick 07c7128
[master 8116729] Added other file
 Date: Thu Jun 25 22:08:23 2020 +1000
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 other.file

$ git lg
* 8116729 - (HEAD -> master) Added other file (2020-06-26 21:57:14 +1000) <User Usernikov (user@userni.kov)>
* 4e87837 - (origin/master) Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
* 0af5c64 - (origin/second-branch, second-branch) Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
| * 07c7128 - (origin/first-branch, first-branch) Added other file (2020-06-25 22:08:23 +1000) <User Usernikov (user@userni.kov)>
|/
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

We can see that the result here is different. A copy of the commit was added to master, but `first-branch` is not integrated into `master`.

## Rebasing

Rebasing is an alternative to merging that doesn't create a merge commit. The result is similar to following these steps. We are going to call `current branch` the branch where we are standing and `base branch` the branch we are rebasing to.

- Checkout `base branch`
- Go back in history and find the first common commit for `base branch` and `current branch`
- Cherry pick the first commit in `current branch`
- Cherry pick the next commit in  `current branch`
- Keep cherry picking until there are no more commits
- Make `current banch` point to the last cherry-picked commit
- Make `base branch` point to the same place it was pointing before the rebase

One thing to keep in mind when rebasing is that the direction of the rebase matters. Let's again imagine we are at this stage:

```sh
* 4e87837 - (HEAD -> master, origin/master) Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
* 0af5c64 - (origin/second-branch, second-branch) Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
| * 07c7128 - (origin/first-branch, first-branch) Added other file (2020-06-25 22:08:23 +1000) <User Usernikov (user@userni.kov)>
|/
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

And we rebase from `master` to `first-branch`:

```sh
# Assuming we are in master
$ git rebase first-branch
First, rewinding head to replay your work on top of it...
Applying: Add title to readme
Applying: Add file-in-master

$ git lg
* 9493b7b - (HEAD -> master) Add file-in-master (2020-06-26 22:11:13 +1000) <User Usernikov (user@userni.kov)>
* 2908379 - Add title to readme (2020-06-26 22:11:13 +1000) <User Usernikov (user@userni.kov)>
* 07c7128 - (origin/first-branch, first-branch) Added other file (2020-06-25 22:08:23 +1000) <User Usernikov (user@userni.kov)>
| * 4e87837 - (origin/master) Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
| * 0af5c64 - (origin/second-branch, second-branch) Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
|/
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

This is not good because `master` and `origin/master` are now in different branches (`origin/master` should always be behind `master`). In this case, what we should have done is:

```sh
$ git checkout first-branch
Switched to branch 'first-branch'

$ git rebase master
First, rewinding head to replay your work on top of it...
Applying: Added other file

# Now, `first-branch` is ahead of `master`. We can advance `master`
$ git lg
* f2bd6e6 - (HEAD -> first-branch) Added other file (2020-06-26 22:14:03 +1000) <User Usernikov (user@userni.kov)>
* 4e87837 - (origin/master, master) Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
* 0af5c64 - (origin/second-branch, second-branch) Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
| * 07c7128 - (origin/first-branch) Added other file (2020-06-25 22:08:23 +1000) <User Usernikov (user@userni.kov)>
|/
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>

$ git checkout master
Switched to branch 'master'
Your branch is up to date with 'origin/master'.

$ git rebase first-branch
First, rewinding head to replay your work on top of it...
Fast-forwarded master to first-branch.

$ git lg
* f2bd6e6 - (HEAD -> master, first-branch) Added other file (2020-06-26 22:14:03 +1000) <User Usernikov (user@userni.kov)>
* 4e87837 - (origin/master) Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
* 0af5c64 - (origin/second-branch, second-branch) Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
| * 07c7128 - (origin/first-branch) Added other file (2020-06-25 22:08:23 +1000) <User Usernikov (user@userni.kov)>
|/
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

## Deleting branches

Our history contains now a bunch of branches that we don't need anymore. To delete them:

```sh
$ git branch -d first-branch second-branch 
Deleted branch first-branch (was f2bd6e6).
Deleted branch second-branch (was 0af5c64).
```

If the branches are not part of master yet, the previous command won't work. This is done to prevent people from deleting branches by mistake. If we are sure we want to delete a branch that we haven't integrated into master, we can use:

```sh
$ git branch -D branch-name
```

We also have some branches in our remote that we are not going to need. Let's delete them from there (Keep in mind that this deletes the branches from the remote, so this will affect all users of that remote):

```sh
$ git push origin :second-branch 
To ../main-repo/
 - [deleted]         second-branch

$ git push origin :first-branch
To ../main-repo/
 - [deleted]         first-branch

$ git lg
* f2bd6e6 - (HEAD -> master) Added other file (2020-06-26 22:14:03 +1000) <User Usernikov (user@userni.kov)>
* 4e87837 - (origin/master, origin/HEAD) Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
* 0af5c64 - Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

## Getting changes from remotes

So far we have been using our repo as if there was only one person using it. In real life, there might be multiple people working on the same repo. In the last section we left with our `master` branch ahead of `origin/master`:

```sh
* f2bd6e6 - (HEAD -> master) Added other file (2020-06-26 22:14:03 +1000) <User Usernikov (user@userni.kov)>
* 4e87837 - (origin/master, origin/HEAD) Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
* 0af5c64 - Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

Let's imagine another person made a change and pushed it to `origin/master` before we try to push our change. When we try to push, we would get an error:

```
$ git push
To ../main-repo/
 ! [rejected]        master -> master (fetch first)
error: failed to push some refs to '../main-repo/'
hint: Updates were rejected because the remote contains work that you do
hint: not have locally. This is usually caused by another repository pushing
hint: to the same ref. You may want to first integrate the remote changes
hint: (e.g., 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

As the error message says, we need to `fetch` first. Fetching means getting the latest changes from a remote. Let's do that:

```sh
$ git fetch origin master
remote: Counting objects: 2, done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 2 (delta 0), reused 0 (delta 0)
Unpacking objects: 100% (2/2), done.
From ../main-repo
 * branch            master     -> FETCH_HEAD
   4e87837..4f243e1  master     -> origin/master

$ git lg
* 4f243e1 - (origin/master, origin/HEAD) Added developer-file (2020-06-27 19:43:44 +1000) <Adrian Ancona Novelo (annovelo@amazon.com)>
| * f2bd6e6 - (HEAD -> master) Added other file (2020-06-26 22:14:03 +1000) <User Usernikov (user@userni.kov)>
|/
* 4e87837 - Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
* 0af5c64 - Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

To use the fetch command we specify the `remote` and the `brach` we want to fetch. Once we have the latest changes we can either `merge` or `rebase` so our `master` is ahead of `origin/master`.

An alternative to fetch is `pull`. A `pull` is the same as doing a merge, followed by a merge:

```sh
$ git pull origin master
From ../main-repo
 * branch            master     -> FETCH_HEAD
Merge made by the 'recursive' strategy.
 developer-file | 0
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 developer-file

$ git lg
*   5cd5cd7 - (HEAD -> master) Merge branch 'master' of ../main-repo (2020-06-27 19:51:16 +1000) <User Usernikov (user@userni.kov)>
|\
| * 4f243e1 - (origin/master, origin/HEAD) Added developer-file (2020-06-27 19:43:44 +1000) <Adrian Ancona Novelo (annovelo@amazon.com)>
* | f2bd6e6 - Added other file (2020-06-26 22:14:03 +1000) <User Usernikov (user@userni.kov)>
|/
* 4e87837 - Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
* 0af5c64 - Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

We can tell `pull` to `rebase` instead of `merging`:

```sh
$ git pull --rebase origin master
From ../main-repo
 * branch            master     -> FETCH_HEAD
First, rewinding head to replay your work on top of it...
Applying: Added other file

$ git lg
* 555d898 - (HEAD -> master) Added other file (2020-06-27 19:54:59 +1000) <User Usernikov (user@userni.kov)>
* 4f243e1 - (origin/master, origin/HEAD) Added developer-file (2020-06-27 19:43:44 +1000) <Adrian Ancona Novelo (annovelo@amazon.com)>
* 4e87837 - Add file-in-master (2020-06-26 21:40:08 +1000) <User Usernikov (user@userni.kov)>
* 0af5c64 - Add title to readme (2020-06-25 22:03:42 +1000) <User Usernikov (user@userni.kov)>
* 0eba272 - Added readme file (2020-06-25 21:53:16 +1000) <User Usernikov (user@userni.kov)>
```

## Conflicts

In all the previous example we were able to merge or rebase without any conflicts. In this section I'm going to show what happens when conflicts occur. Let's imagine we have two branches that made modifications to the same file and we want to merge them:

```sh
$ git lg
* cfa8d8b - (HEAD -> master) Added content to README (2020-06-27 21:21:30 +1000) <User Usernikov (user@userni.kov)>
| * ddb5a80 - (temp) Updated README (2020-06-27 21:20:45 +1000) <User Usernikov (user@userni.kov)>
|/
* 555d898 - Added other file (2020-06-27 19:54:59 +1000) <User Usernikov (user@userni.kov)>

$ git merge temp 
Auto-merging README.md
CONFLICT (content): Merge conflict in README.md
Automatic merge failed; fix conflicts and then commit the result.
```

Int this case, git can't safely merge the changes without human intervention. If we look at the status of our repo:

```sh
$ git status
On branch master
Your branch is ahead of 'origin/master' by 2 commits.
  (use "git push" to publish your local commits)

You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)

	both modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
```

We find some information telling us our options. One option is to cancel the merge using `git merge --abort`, which will leave the repo in the state it was before we tried to merge. Most of the time, we will need to fix the conflicts so we can integrate our work with the origin.

In the output above, we see README.md marked as `both modified`. This means it has conflicts we need to fix. If we open the file we see something like this:

```
Git demo

<<<<<<< HEAD
Different content
=======
Adding some information
>>>>>>> temp
```

The `<<<<<<<`, `=======` and `>>>>>>>` markers tell us where our conflicts are. The first section is the contents of `HEAD`(`master`) and the second section is the contents of `temp`. What we do in this scenario depends on us. We could delete one of the sections, combine them or keep both. In this case, we are going to keep both. We'll modify the file to look like this:

```
Git demo

Adding some information
Different content
```

Once conflicts have been resolved we need to tell git we are done and continue the merge:

```sh
$ git add README.md

$ git status
On branch master
Your branch is ahead of 'origin/master' by 2 commits.
  (use "git push" to publish your local commits)

All conflicts fixed but you are still merging.
  (use "git commit" to conclude merge)

Changes to be committed:

	modified:   README.md

$ git commit
[master 555c386] Merge branch 'temp'
```

Conflicts can appear in any situation when we are trying to integrate code. Some examples are: merge, rebase, cherry-pick. The way to deal with them is the same in any scenario.

## Amending

It's common in software development to write some code and have someone else review it. What this means is that we can end with a history like this:

```sh
...
* ccccc - More fixes
* bbbbb - Fixes from code review
* aaaaa - Developed awesome feature
```

This makes the history hard to understand. To avoid this problem, we can ammend changes to a commit instead of creating new commits. Amending, means adding changes to the commit currently on our `HEAD`. This effetively adds the new changes to the commit where we are stading without creating a new commit. Let's say we made a commit, but realized we need to make some more changes. We can add those changes to our commit like this:

```sh
$ git lg
* cfa8d8b - (HEAD -> master) Added content to README (2020-06-27 21:21:30 +1000) <User Usernikov (user@userni.kov)>

$ git status
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

	modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")

$ git add README.md

$ git commit --amend
[master 5fed73d] Added content to README
 Date: Sat Jun 27 21:21:30 2020 +1000
 1 file changed, 3 insertions(+)

$ git lg
* 5fed73d - (HEAD -> master) Added content to README (2020-06-27 21:55:08 +1000) <User Usernikov (user@userni.kov)>
```

Notice that the hash of the commit changed from `cfa8d8b` to `5fed73d`. This is because the contents of the commit also changed.


## Diffs

A `diff` is the difference between one version of a file (or multiple files) and another. Here are some ways we can use `git diff` to see the changes to our files:

```sh
# Show changes that I have made but I have not committed or staged
git diff

# Show changes that are currently in my staging area
git diff --cached

# Show changes that were made in the commit we're currently standing
git diff HEAD~

# Show changes that were made in the last two commits (from where we stand)
# This can be generalized to any number of commits
git diff HEAD~2

# Show the difference between two branches
git diff one-branch other-branch

# Show the difference between two commits
git diff 4f243e1 0af5c64
```

## The stash

Sometimes we are working on something and we get interrupted for something that will require us to make some changes in our repo. Since we don't want to mix the new changes with whatever we were working before, we wan't to save our state before we start working on something new. One way we could do this is by creating a branch and commiting our changes to that branch. Git can do this automatically for us with stashes. If we want to save our current state, we can use:

```sh
git stash
```

The `stash` works like a stack. We can keep stashing things and they will go one on top of the previous one. When we want to retrieve our chnages we do:

```sh
git stash pop
```

Since stashes don't have identifiers (like branch names), it's best to use them only for quick things, otherwise we might forget what's on our stash.

## Rewriting history




## selecting just some files / Selecting just part of some files

## Bisect

## Undoing stuff reflog / clean / checkout / reset

## Configuration

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
