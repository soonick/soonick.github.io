---
title: Java development with Vim
author: adrian.ancona
layout: post
# date: 2020-03-04
# permalink: /2020/03/introduction-to-aws-cli/
tags:
  - java
  - productivity
  - programing
  - vim
---

I have been using Vim as my primary development environment for a few years now. I've been happy with it so far, but I just started working on a project that uses Java. All my team members keep telling me that I will be very inefficient if I don't use an IDE, but Vim has served me so well, that I don't want to give up without trying what's out there.

My team uses IntelliJ, and they mostly talk about a few features:
- Autocomplete - When you are typing something, the IDE suggest options. This is specially useful if you want to see what are the available methods on an object. Just type the variable name, followed by a dot (`.`) and the IDE suggests the methods
- Jump to definition - If you are looking at some code and see a function call that you want to know where it is defined, the IDE provides an easy way to take you directly to the definition
- Imports - Java files usually end up having many import statements at the top. The IDE can help automatically remove unused imports as well as automatically create import statements based on the code in that file
- Syntax check - If there is a Syntax error on the code, the IDE notifies you that there is an error without having to compile the whole program

I'm not sure I will be able to make all of these work in Vim, but my goal is to get close enough that I can move efficiently on any Java codebase.




Youcompleteme

```
sudo apt install build-essential cmake vim python3-dev
``

or 

```
sudo yum install cmake gcc-c++ make python3-devel
```


```
cd ~/.vim/pack/my-plugins/start
git clone https://github.com/ycm-core/YouCompleteMe.git
cd YouCompleteMe
git submodule update --init --recursive
python3 install.py --java-completer
```
