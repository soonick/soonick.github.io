---
title: Command Line Efficiency With Tmux
author: adrian.ancona
layout: post
date: 2022-07-06
permalink: /2022/07/command-line-efficiency-with-tmux
tags:
  - bash
  - linux
  - productivity
---

I'm a a Software Developer that uses Ubuntu as his main OS and Vim as his main editor. I like Ubuntu (more specifically Gnome) because it allows me to move windows around without having to use the mouse. If I need to maximize a window, move a window to a different screen or split the screen between two windows, I just need to type a keyboard shortcut.

When I'm focused on writing or reading code, Vim also allows me to move around the code easily without a mouse.

Tmux is a tool that allows us to expand the capabilities of the terminal so we can manipulate terminal panes similar to how we can manipulate windows with Gnome, or navigate code in a similar fashion as with Vim.

<!--more-->

## What's Tmux?

Tmux is an open source terminal multiplexer.

The puzzling part about the sentence above is the `multiplexer` part. What it means is that it lets us have multiple sessions running at the same time.

Inside each session, we can also do many different things at the same time. This nesting can be a little confusing at first, but it will make more sense when we see it in action in the next sections.

## Installation

For the most up-to-date installation instructions it's always good to check the [official documentation](https://github.com/tmux/tmux/wiki/Installing). On Ubuntu, this was enough:

```
sudo apt install tmux
```

Tmux is a command line application that runs in our terminal. To start Tmux we can type `tmux` in any terminal window:

```
tmux
```

After doing so, not much will change. We will still get a terminal window with a prompt. The only noticeable difference might be a bar at the bottom of the screen with some information about the session:

[<img src="/images/posts/tmux-status-bar.png" alt="Tmux status bar" />](/images/posts/tmux-status-bar.png)

## The prefix key

Tmux works similar to Vim in the sense that there is a special key combination used to interact with it. In Vim we have the `Leader` key. In Tmux we have the `Prefix` key.

By default, when we are in a Tmux session, it will work like any other terminal. We can type commands and they will be executed as normal.

To interact with Tmux we need to use the `Prefix` key, which is actually a key combination. By default the prefix key is: `Ctrl`+`b`, but it can be configured to be something else if we so desire. Since the combination might be changed, I will refer to it as `Prefix` from now on.

## Working with sessions

Sessions can be used to organize the way we work in our terminal. For example, we could have a session for each different project we work on.

Whenever we type the `tmux` command, we start a new Tmux session. By default new sessions are started with a consecutive numeric name, but we can also give names to our sessions to make them easier to remember.

To start a new session named `ncona`, we can use this command:

```
tmux new -s ncona
```

Now, let's say we are working on the `ncona` project for a bit, but then need to move to a different project. We can keep the current state of our session but `detach` from it by typing `Prefix` `d` (The prefix combination followed by the letter `d`).

This will bring us back to our standard terminal (The Tmux status bar won't be there anymore), but the state of our Tmux session will be saved. We can now start new sessions and detach from them as desired.

Of course, after detaching from a session we want to be able to recover it.

To see which sessions are currently running we can use:

```
tmux ls
```

The output will be something similar to:

```
ncona: 1 windows (created Sun Jul  3 13:45:33 2022)
```

We can see that currently there is only one session, and it's named `ncona`. To attach to our session we can use this command:

```
tmux attach -t ncona
```

We can kill a session by typing `exit` during that session, or by using this command:

```
tmux kill-session -t ncona
```

## Working with windows

A Tmux session can contain multiple windows. When we start a new session we will get a single window by default, but we can add more if we desire.

Let's start a new session:

```
tmux new -s windows
```

We get a terminal prompt as expected. We can create a new window with `Prefix` `c`. It might seem like nothing happened, but if we look at the status bar, we will see something new:

[<img src="/images/posts/tmux-status-windows.png" alt="Tmux status bar showing windows" />](/images/posts/tmux-status-windows.png)

The satus bar shows two windows running bash, each of them has a number associated with it. This number will be useful when we start to move between windows.

To help us keep organized, we can give a name to the current with `Prefix` `,`.

There are a few ways we can navigate windows:

- `Prefix` `n` - Go to next window
- `Prefix` `p` - Go to previous window
- `Prefix` `2` - Go to window number 2 (Replace the number `2` with the number of the desired window)
- `Prefix` `w` - Shows a list of all the windows that lets us select which one we want

We close windows by typing `exit`. When all windows are closed, the session is closed too.

## Working with panes

Panes are a way to show multiple things in a single screen. Let's create a new session to learn more:

```
tmux new -s panes
```

As we now know, we just opened a new session with a single window. We can use `Prefix` `%` to split the window in two. We now have one pane in the left and one in the right. Using `Prefix` `"` will split our current pane (the right pane) in two panes (one on top of the other).

We can cycle through the panes by using `Prefix` `o`.

If we decide to use panes, we might want to arrange them in specific ways. Tmux has a few built-in layouts that are helpful for different scenarios. We can cycle through them using `Prefix` `spacebar`.

## Configuring Tmux

Tmux provides a lot of flexibility, but once we find our ideal setup, we want to be able to do things as quickly as possible. Luckily, Tmux allows us to customize a lot of things so we can perform common tasks with less keystrokes.

Tmux looks in two places for configurations:

- `/etc/tmux.conf` - System wide settings
- `~/.tmux.conf` - User specific settings

The first thing we are config to change is our prefix key. The default is `Ctrl+b`, but many people (including myself) find `Ctrl+a` a more comfortable combination. We can make this change in `~/.tmux.conf`:

```
set -g prefix C-a
```

Let's take a closer look at what this does:

- `set` - set-option command, let's us set session level configurations
- `-g` - Global. Sets it for all sessions
- `prefix` - This is the option we are modifying (the prefix key)
- `C-a` - The new combination will be `Ctrl+a`

To reload the configuration file we need to close all Tmux sessions, or enter command mode (`Prefix` `:`) and type: 

```
source-file ~/.tmux.conf
```

While we are in the topic of re-loading the configuration file, we can create a shortcut to make it easier to do this task. Let's add this to our configuration file:

```
bind r source-file ~/.tmux.conf \; display-message "Tmux configuration reloaded"
```

A closer look:

- `bind` - We are defining a shortcut
- `r` - We are defining it for: `Prefix` `r`
- `source-file ~/.tmux.conf` - The command that will be executed
- `\;` - Can be used to separate multiple actions
- `diplay-message` - Shows a message in the status bar
- `"Tmux configuration reloaded"` - The message to show when the configuration is reloaded

## Working with the mouse

This article is about command-line efficiency, which means we want to stay away from the mouse as much as possible. Nevertheless, the default behaviour of scrolling the mouse wheel on top of a Tmux session can be confusing. If we want it to behave more intuitively we can add this option to our configuration:

```
set -g mouse on
```

Later in the article we'll see alternatives that might make us more efficient.

## Enabling 256 colors

By default Tmux only shows `8` colors, which might not work well with our current color scheme. To enable `256` colors, we can use this configuration:

```
set -g default-terminal "xterm-256color"
```

## Quick-start development environments

When we work on a project, we often use the same tools. For example, when I'm writing an article for my blog, I usually open these tabs:

- Vim
- Jekyll

With Tmux, we can create scripts so we can tell Tmux: "I'm going to work on task X" and it starts all we need.

Let's say this is what we want to achieve:

- Start a new session named: "ncona"
- Navigate to ~/ncona-blog
- Start jekyll
- Open a new window in the same session
- Navigate to ~/ncona-blog
- Open vim

We can automate this by creating a script:

```
mkdir ~/tmux-scripts
cd ~/tmux-scripts
touch ncona
chmod +x ncona
```

And add this content to `ncona` file:

```bash
# If there is already a session named `ncona`, don't create it
tmux has-session -t ncona
if [ $? != 0 ]
then
    # Create a new session called `ncona`. The default window for this session will
    # be named `jekyll`. We detach from the session after creating it
    tmux new -s ncona -n jekyll -d

    # Send the command `cd ~/ncona-blog' followed by enter (`C-m`) to the session
    # named `ncona` (-t stands for `target`)
    tmux send-keys -t ncona 'cd ~/ncona-blog' C-m

    # Execute command `bundle exec jekyll build && bundle exec jekyll s -DIl`
    # in the `ncona` session
    tmux send-keys -t ncona 'bundle exec jekyll build && bundle exec jekyll s -DIl' C-m

    # Start a new window named `vim` in the `ncona` session
    tmux new-window -n vim -t ncona

    # Navigate to `~/ncona-blog` folder. Notice how the target is `ncona:1`.
    # This means: session `ncona`, window number `1`. The first window we created
    # is window number `0`
    tmux send-keys -t ncona:1 'cd ~/ncona-blog' C-m

    # Start vim
    tmux send-keys -t ncona:1 'vim' C-m

    # When we attach to the session we want window `1` to be displayed first
    tmux select-window -t ncona:1
fi

# Attach to the session
tmux attach -t ncona
```

We just need to execute the script and we'll get the setup we need:

```
~/tmux-scripts/ncona
```

We can create a terminal alias to make it easier to call this command.

## Removing the need for the mouse

When working on a terminal, the mouse is often used to scroll through a window, select text and copy it. In this section we are going to learn how to perform these tasks without the mouse.

Let's say we executed a command that gave a lot of output, so it doesn't all fit in the screen. Our first instinct to look at the output is probably to grab the mouse and use the scroll-wheel.

Instead, Tmux allows us to navigate the buffer the same way we would navigate a large file in Vim. But first, we need to tell Tmux that we want to enable Vim mode by adding this to our configuration file:

```
setw -g mode-keys vi
```

We use `setw`, which is an alias of `set-window-option`, this means we are setting an option that affects windows, as opposed to `set`, which applies to `sessions`.

After reloading our config file, we can enter `copy mode` by using: `Prefix` `[`. In copy mode we can navigate the buffer as if it a file opened with vim. i.e. we can move our cursor with `h`, `j`, `k`, `l`, we can search for text using `/`, we can use `Ctrl`+`b` to move one page backwards, etc...

To exit `copy mode` we just need to hit `enter`.

We still need to select and copy text. To do this we need some OS specific setup.

For Linux we need the `xclip` application to allow us to interact with the OS' clipboard. First, we need to install it:

```
sudo apt-get install xclip
```

Now we can add these configurations to `~/.tmux.conf`:

```bash
# Use v to trigger selection
bind-key -T copy-mode-vi v send-keys -X begin-selection

# Use y to yank current selection and put it in the OS' clipboard
bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -sel clip -i"
```

We can now use `v` to initiate a selection, just like in Vim. To yank the text, we type `y`, which will also exit copy mode. Once the text is in the OS' clipboard, we can paste as normal.

## Conclusion

In this article we learned how to set up and use Tmux's basic features. There are a lot of options I didn't cover and even plugins to achive specific tasks. I encourage you to configure it to your liking and explore the available plugins to get the best setup possible.
