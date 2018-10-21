---
id: 1050
title: Introduction to Vim
date: 2013-01-03T03:46:17+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1050
permalink: /2013/01/introduction-to-vim/
tags:
  - productivity
  - programming
  - vim
---
## Why vim?

I have in the past done most of my development in Linux machine using gedit with a series of plugins to help me do stuff faster. Some times out of necessity I found myself developing on a Windows machine in which case Notepad++ helped me not miss Gedit too much. Today I have found myself in the necessity to develop on a Mac computer and I realized that using a different editor each time I change my development machine wasn&#8217;t going to be a good solution in the long term.

People have recommended me to use some IDEs and editors that work in most platforms but most of them are really slow and the ones that are not slow require you to buy a license which is something I would rather avoid.

Vim is not a very friendly editor in the beginning but I have heard a lot of people say awesome things about it and it has the advantage of being available for virtually all operating systems out there (comes by default on MAC and most Linux machines), be very lightweight, extendable and most importantly, free.

<!--more-->

## Normal mode

When you start Vim for the first time it starts in what is called **normal** mode. This is something most popular editors don&#8217;t have so it scares most people at the beginning. The normal mode is used to input commands that help us move around or manipulate text on a file.

Normal mode is not for entering content into a file but for moving around or modifying it via commands, so if you try to write something you will get frustrated because you won&#8217;t see the text you are typing appearing in the screen and you have probably caused other side effects by entering commands accidentally.

I will explain some commands I think are the most important to get started later, for now you only need to know that there are other modes available but if you get lost and you want to get back to normal mode you can always do it by pressing the **ESC** key.

## Insert mode

This is the mode we are used to in other editors. Here you just input text and it gets shown in your screen. The most common way to enter insert mode is by pressing **i** while in normal mode. Now you can enter and delete text as normally. You can go back to normal mode by pressing **ESC**

## Visual mode

This mode allows you to make a selection of more than one character using the cursor and then perform commands against that selection. You can enter visual mode by pressing **v** when in command mode. When you enter visual mode the cursor will start a selection from the current position of your cursor to wherever you move it using the arrow keys. You can give a try making a selection and then pressing **d** to delete the selected text.

## Useful commands to get started

Note that the commands shown here are case sensitive. Beware of this because sometimes the same command in a different case has a completely different result. Commands that use the Ctrl modifier are always case insensitive.

**:w** &#8211; If you are editing a file that is already saved somewhere in the file system it will overwrite the file with the current contents of the file you are editing. If you are working on a new file and this is the first time you are saving you need to include the name you want to use to save it. Example **:w myfile.c**.

**:q** &#8211; Quit vim or close the current tabs if working with multiple tabs. If you have changes pending vim won&#8217;t let you quit. To quit without saving changes you can use **:q!**

**i** &#8211; Enter insert mode in your current cursor position.

**I** &#8211; Enter insert mode at the beginning of the current line.

**A** &#8211; Enter insert mode at the end of the current line.

**G** &#8211; Move to the last line on the file.

**$** &#8211; Move to the end of the line.

**gg** &#8211; Move to the first line of the file.

**:set nu** &#8211; Show line numbers.

**H** &#8211; Jump to the top of the screen.

**L** &#8211; Jump to the bottom of the screen.

**Ctrl+F** &#8211; Move one page forward.

**Ctrl+B** &#8211; Move one page backwards.

**:5** &#8211; Go to line 5. You can replace the number 5 for any line number you want to navigate to.

**u** &#8211; Undo a change.

**Ctrl+R** &#8211; Redo a change.

**/word** &#8211; Find the text **word** from the current cursor position forward. If you want to search for more matches of the same word you can type **n** to find the next match or **N** to find the previous match. If you want to do a case insensitive search you need to use the \c modifier **/word\c**.

**:set syntax=SYNTAX** &#8211; Replace SYNTAX with the name of a vim syntax file and vim will do code highlighting for you using that syntax file.

**dd** &#8211; Delete current line.

**:tabnew** &#8211; Open a new tab. You can specify the path to a file to open if you want to open a file a new tab.

**:tabn or gT** &#8211; Move to the next tab.

**:tabp or gt** &#8211; Move to the previous tab.

**:tabfirst** &#8211; Move to the first tab.

**:tablast** &#8211; Move to the last tab.

**:tabm 4** &#8211; Move the tab to the 4th position. Note that this is 0 based.

**:2gt** &#8211; Move to the 2nd tab. The first tab is number 1.

**:qa** &#8211; Close all tabs and quit Vim.

## Other useful things to know

**Select all the text on a file** &#8211; Input these commands one after the other **gg v G $**

**Copy all the selected text to the clipboard** &#8211; Input these commands one after the other while you are in visual mode **&#8220;+y** or on some systems **&#8220;*y**

**Open multiple files in tabs** &#8211; From bash or your OS terminal: **vim -p file1 file2 file3**
