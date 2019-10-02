---
title: Configuring gnome terminal programmatically
author: adrian.ancona
layout: post
date: 2019-11-13
permalink: /2019/11/configuring-gnome-terminal-programmatically/
tags:
  - linux
  - automation
  - bash
---

As part of getting a new computer, I want to be able to run a script to configure gnome terminal to my preferred configuration. Doing this is not very hard, but finding how to do it took me some time.

Configuration for gnome terminal lives in [`dconf`](https://wiki.gnome.org/Projects/dconf); gnome's default configuration system.

The first thing we need to do is get the default terminal profile id:

```sh
$ dconf read /org/gnome/terminal/legacy/profiles:/default
'b1dcc9dd-5262-4d8d-a863-c897e6d979b9'
```

<!--more-->

We will need this value later, so let's save it in a variable:

```sh
GNOME_TERMINAL_PROFILE=`dconf read /org/gnome/terminal/legacy/profiles:/default | awk -F \' '{print $2}'`
```

Next, we need to load our desired configuration into this profile:

```sh
dconf load /org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ < terminal-profile
```

My `terminal-profile` file looks like this:

```ini
[/]
foreground-color='rgb(175,175,175)'
palette=['rgb(0,0,0)', 'rgb(204,0,0)', 'rgb(78,154,6)', 'rgb(196,160,0)', 'rgb(52,101,164)', 'rgb(117,80,123)', 'rgb(6,152,154)', 'rgb(211,215,207)', 'rgb(85,87,83)', 'rgb(239,41,41)', 'rgb(138,226,52)', 'rgb(252,233,79)', 'rgb(114,159,207)', 'rgb(173,127,168)', 'rgb(52,226,226)', 'rgb(238,238,236)']
cursor-shape='block'
use-system-font=false
use-theme-colors=false
use-transparent-background=false
font='Monospace 10'
use-theme-transparency=false
background-color='rgb(18,18,18)'
background-transparency-percent=0
audible-bell=false
```

If you like your current terminal profile, you can get the settings for your current default profile using:

```sh
dconf dump /org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/
```

You can make modifications to this file if you desire and then load them on other machines to get the same configuration.
