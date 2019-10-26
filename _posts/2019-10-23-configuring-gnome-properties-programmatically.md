---
title: Configuring gnome properties programmatically
author: adrian.ancona
layout: post
date: 2019-10-23
permalink: /2019/10/configuring-gnome-properties-programmatically/
tags:
  - linux
  - automation
  - bash
---

After installing a new distribution in my computer, I usually want to make some tweaks to gnome. In this post I'm going to explain how to do these tweaks from the command line, so they can be scripted.

## gsettings

Gsettings is a command-line tools that allows us to modify gnome settings. To modify a setting we can use the `set` command. The format is like the following:

```sh
gsettings set SCHEMA[:PATH] KEY VALUE
```

<!--more-->

This means, to modify a setting we need to know its schema and path. We can list all the schemas using:

```sh
gsettings list-schemas
```

But it might still be hard to find the schema and path we need to modify. What I have found more effective is to google for the setting I'm interested in.

### Keyboard shortcuts

One of the things I usually modify is keyboard shortcuts. The schema for modifying keyboard shortcuts is: `org.gnome.settings-daemon.plugins.media-keys`. To see which shorcuts are available by default we can use `list-keys`:

```sh
gsettings list-keys org.gnome.settings-daemon.plugins.media-keys
```

To set the shortcut for openning the terminal, I used this command:

```sh
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Ctrl><Alt>t']"
```

### Hide dock

```
gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
```

### Show battery percentage

```
gsettings set org.gnome.desktop.interface show-battery-percentage true
```

## Conclusion

We can configure most things about gnome with `gsettings`, the only problem is finding which setting needs to be changed. So far, the best I have found is to use Google to find the correct setting.
