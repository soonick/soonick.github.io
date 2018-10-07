---
id: 2722
title: Bash productivity tips
date: 2015-04-01T16:56:38+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2722
permalink: /2015/04/bash-productivity-tips/
categories:
  - Linux
tags:
  - bash
  - linux
  - productivity
  - vim
---
## See command history

When I want to find a command I used in the past, but I don&#8217;t remember I usually use vim to search for it:

```
vim ~/.bash_history
```

This is useful because you get the whole list of commands in your history and all the power of vim to search for the command you are looking for. A faster way to show the list of the commands is with the history command:

```
history
```

<!--more-->

If you know the command was used recently you can limit the number of commands you want to see:

```
history 20
```

It will show you the 20 most recent commands on your history.

## Search command history

You probably already use the up and down arrows to move up and down your command history. What you probably didn&#8217;t know is that you can also search on the history by hitting Ctrl+R. This will take you to _reverse-i-search_ mode. Now you can start searching for commands on your history. The most recently used match will show first, if you want to keep searching the history for previous matches you can hit Ctrl+R again. Whenever you find the command you were looking for, just hit enter and the command will be executed.

## Go back to previous folder

You can go back to the folder you where before by using:

```
cd -
```

Here is an example of it in action:

```
[anovelo@localhost var]$ pwd
/var
[anovelo@localhost var]$ cd /home/anovelo/
[anovelo@localhost ~]$ cd -
/var
[anovelo@localhost var]$ cd -
/home/anovelo
```

## Verify if a command executed successfully

On Linux systems, programs exit with a code of 0 when everything works fine. An exit code different to 0, means something went wrong. If you want to know the exit code of a command you execute from a terminal, you can use:

```
echo $?
```

Here is an example in action:

```
[anovelo@localhost ~]$ ls tools/
gradle-2.2.1  gradle-2.3  jdk-7u75-linux-i586.rpm
[anovelo@localhost ~]$ echo $?
0
[anovelo@localhost ~]$ ls wjaoi
ls: cannot access wjaoi: No such file or directory
[anovelo@localhost ~]$ echo $?
2
```

## Add sudo to a command

I&#8217;m sure this has happened to you a few times. You execute a command and get a message telling you that you need to be root to execute that command. You can use !! to execute the last command in your history so you can simply do:

```
sudo !!
```

And you will be executing your last command with sudo.

## Suppressing command output

You can suppress a command output by directing it to /dev/null

```
ls > /dev/null
```

Although there are some scenarios where you might want to execute a command and not get the output, this gets more useful when you realize that programs usually dump both stdout and stderr to the terminal. In some scenarios you might want to get just the error logs, so you want to suppress anything in stdout

```
somecommand 1> /dev/null
```

In others, you might know there are going to be errors and not care about them. A common scenario when you might not want to get stderr is when using the find command because it usually logs a line for each folder you don&#8217;t have permissions to access. To avoid the errors use:

```
find /root/ 2> /dev/null
```

## Vi mode for navigating command history

If you like Vi(m), you will be happy to know that you can use vim to move around your command history by entering Vi mode:

```
set -o vi
```

At the beginning you might not notice the difference because you start in insert mode. You can switch to command mode by using ESC. You can use j to move back on your history and k to move forward. You can use w to move to the next word and b to move to the previous one. Give it a try.
