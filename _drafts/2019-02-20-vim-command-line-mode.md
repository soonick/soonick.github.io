---
title: Vim command line mode
author: adrian.ancona
layout: post
date: 2019-02-20
permalink: /2019/02/vim-command-line-mode/
tags:
  - vim
  - productivity
---

The vim command-line mode is the mode we enter when typing Ex commands (`:`), search patterns (`/`, `?`) or filter commands (`!`). This mode works a little like insert mode, in that whatever we type, is going to appear in the command line. It is not as powerful as the normal mode, but there are a few combinations we can use to move more efficiently:

- `Ctrl+left`, `Ctrl+right` - Using the arrow keys we can move left and right one character at a time. If we press Ctrl together with the left or right keys, we will move one word at a time
- `Ctrl+B`, `Ctrl+E` - Move to the beginning and end of the command line, respectively
- `Ctrl+W` - Deletes the word before the cursor (Only deletes characters at the left of the cursor)

<!--more-->

## cmdline-special

There is a key combination (`Ctrl+R`) that allows us to add some special things in the command line. To use this combination, we just have to type `Ctrl+R`, followed by one of the following characters:

- `%` - Current file name
- `"` - Last yanked text
- `*` - Clipboard contents
- `/` - Last search pattern

There are more combinations (`help Cmdline`), but these are the ones I find more useful.

## cmdline-window

If you really hate command line mode, you might want to use `cmdline-window` to type commands. If you enter command mode (`:`, `/`, `?`, `!`) and type `Ctrl+F`, a new buffer will be opened where you can finish entering your command. In this buffer, you can use all the functionality you are used to from normal mode.
