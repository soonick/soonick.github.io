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

The first thing we need to do is get the default terminal profile id:

```sh
$ gsettings get org.gnome.Terminal.ProfilesList default
'b1dcc9dd-5262-4d8d-a863-c897e6d979b9'
```

<!--more-->

We will need this value later, so let's save it in a variable:

```sh
GNOME_TERMINAL_PROFILE=`gsettings get org.gnome.Terminal.ProfilesList default | awk -F \' '{print $2}'`
```

Next, we can use gsettings to change the properties we want to change. For my terminal I use these settings:

```sh
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ font 'Monospace 10'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-system-font false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ audible-bell false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ use-theme-colors false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ background-color '#000000'
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ foreground-color '#AFAFAF'
```

You can list all the properties that can be configured:

```
gsettings list-keys org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/
```

If you want to see the current value for a setting you can use:

```
gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$GNOME_TERMINAL_PROFILE/ foreground-color
```
