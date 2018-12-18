---
title: Load bash preferences when SSH to a host
author: adrian.ancona
layout: post
date: 2019-01-23
permalink: /2019/01/load-bash-preferences-when-ssh-to-a-host/
tags:
  - linux
  - productivity
  - bash
  - ssh
---

I have a laptop computer where I customize my bash using a `.bashrc` file. Whenever I SSH to a remote host, I always find myself trying to use aliases or other functionality that I have set on my laptop, but they are not there. Today I found a little trick that I can use to copy my `.bashrc` configuration to a remote host, so I can feel at home.

What we need to do is copy our `.bashrc` file to the host we are going to SSH to. Something like this would work:

```bash
scp ~/.bashrc user@host:/tmp/.my-bashrc
```

The next step is to source the file, but we don't want to do it manually. Luckily `ssh` allows us to specify commands to execute when we connect to a host:

```bash
ssh -t user@host "bash --rcfile /tmp/.my-bashrc"
```

Generally when using `ssh` with a command, you are not given a terminal. The `-t` option forces a terminal allocation, which allows us to run bash the way we intend. The last argument (between quotes), is the command we want to execute, which is just `bash`, telling it to source the file we just copied.

Having to remember these commands is probably too much work, so it's better to create an alias:

```bash
function ssh() {
  scp ~/.bashrc $1:/tmp/.my-bashrc
  /usr/bin/ssh -t $1 "bash --rcfile /tmp/.my-bashrc"
}
```

That's it, from now on remote hosts will feel like home.
