---
title: Sharing the Clipboard. Linux, Vim, Tmux and Docker
author: adrian.ancona
layout: post
date: 2025-05-14
permalink: /2025/05/sharing-the-clipboard-linux-vim-tmux-docker/
tags:
  - linux
  - productivity
  - vim
---

In this article, we are going to explore how the clipboard works when using different tools inside a terminal and how we can configure these tools so we get and intuitive experience.

## Linux

The most basic example of using the clipboard would be using it directly from the operating system.

Most Linux distributions come with a built-in clipboard. This clipboard works as a temporary data storage that can hold a single item. To add an item to the clipboard, we can select it, right click it and select "Copy" or we can use the shortcut `Ctrl-C`.

There are different tools that can be used to inspect the clipboard. We will use `xclip`. To install:

```bash
sudo apt install xclip
```

<!--more-->

Once installed, we can check the contents of the clipboard with this command:

```bash
xclip -selection clipboard -o
```

It's important to remember that the clipboard can only store one item, if a new item is added, the previous one is removed.

## Vim

The `yank` command in Vim provides something similar to a clipboard, but is only accessible from within Vim.

When we yank some text, we are copying it to a Vim register. By default, the yanked text is copied to the `unnamed` register (Other registers exist, but we won't cover those in this article).

There are a few commands that can be used to yank text. Some examples are:

- Select text on visual mode and use `y` to yank it
- Use `yy` while in command mode to yank the current line
- Use `yiw` while in command mode to yank the word currently at the cursor

We can then "paste" the yanked text by using `p` while on command mode.

So far, things are pretty straight forward, but some people (me included) prefer to have a single clipboard for both Vim and the OS. This way, if we can yank something inside Vim, we can easily paste it in any other application.

To achieve this behavior, we can add this to our `.vimrc`:

```bash
set clipboard=unnamedplus
```

Or this to our `init.lua`:

```bash
vim.opt.clipboard = 'unnamedplus'
```

This tells Vim to use the `unnamedplus` register (The system clipboard) by default for all yank and paste operations. Keep in mind, that this requires `xclip` to be installed in the system and vim to be compiled with clipboard support.

## Tmux

Tmux has its own internal buffer where it stores data copied using its internal commands (`Ctrl+b [` and `Ctrl+b ]`). As with Vim, we would ideally want a shared clipboard so we can paste into any other applications. To do this, we can add this line to `.tmux.conf`:

```bash
bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -sel clip -i"
```

This configuration does two things:

- Tells tmux to copy the selected text when the `y` key is pressed (like in Vim)
- When `y` is pressed it sends the content to `xclip`, copying it to the system clipboard

As this command uses `xclip`, it's necessary to have `xclip` installed for this work.

## Docker

For some of my projects, I run Vim inside a docker container. In these cases, I would like Vim to use the docker host's clipboard.

Xclip doesn't work inside of docker, because by default, a docker container doesn't have a display server attached:

```bash
Error: Can't open display: (null)
```

In order to share the host's display with the container, we first need to allow docker to access the display of the host by running this command from a terminal:

```bash
xhost +local:docker
```

Then we need to add this to our `docker run` command:

```bash
-e DISPLAY=$(DISPLAY) -v /tmp/.X11-unix:/tmp/.X11-unix
```

## Conclusion

Both Vim and Tmux offer their own implementation of a clipboard, which allow users to work very efficiently internally. This efficiency can be taken expanded by integrating their functionality with the system's clipboard. Luckily, both these tools allow us to do this with some simple configurations.

When working in docker, the problem is a little different, since it comes from the lack of displays. In this article, we learned how to walk around this issue.
