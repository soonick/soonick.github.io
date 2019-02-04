---
title: Using lsof to find who is using a file or socket
author: adrian.ancona
layout: post
date: 2019-03-06
permalink: /2019/03/assembly-variables-instructions-and-addressing-modes/
tags:
  - linux
  - debugging
  - networking
---

`lsof` stands for **L**i**s**t **O**pen **F**iles. It can help us find which process is using a file at a given point in time. The reason `lsof` is so useful in Unix/Linux systems is that `sockets` and `devices` are treated the same way as files (Pretty much everything is considered a file in Unix/Linux).

Running `lsof` without any arguments will list all open files in the system. If you have a lot of processes working with a lot of files, prepare to wait. The output looks somethins like this:

```
$ sudo lsof
COMMAND     PID   TID            USER   FD      TYPE             DEVICE  SIZE/OFF       NODE NAME
systemd       1                  root  cwd       DIR              253,1      4096          2 /
systemd       1                  root  rtd       DIR              253,1      4096          2 /
systemd       1                  root  txt       REG              253,1   1577264    5374284 /lib/systemd/systemd
systemd       1                  root  mem       REG              253,1     18976    5375835 /lib/x86_64-linux-gnu/libuuid.so.1.3.0
...
```

<!--more-->

This command works better if executed by `root` or using `sudo`. If you execute as any other user, you might only be able to see files owned by that user.

You can see a few things in the output:

- `COMMAND` - The unix command associated with the process. This field might be truncated
- `PID` - ID of the process using the file
- `TID` - ID of the thread using the file
- `USER` - User that owns the process
- `FD` - Usually this is a number representing a file a descriptor, but there are also some special values (they can be found in `man lsof`). A file descriptor can be followed by `r`, `w` or `u` to represent `read`, `write` and `read-write` modes
- `TYPE` - Because pretty much everything is considered a file, `lsof` will list all kinds of things. This field helps identify exactly what is this thing (file, directory, socket, etc.)
- `DEVICE` - Identifier for the device
- `SIZE/OFF` - Depending on the type of file, this will be the size of the file or offset
- `NODE` - This varies depending on the type of file, but it can be an inode number for a regular file
- `NAME` - Name of the file, device, stream, etc

## Find who is using the network

The most common use I have for `lsof` is finding which process is using a port I'm trying to use. I wrote an article a while ago explaining how to do this with [ss (netstat)](/2015/10/socket-statistics-with-ss/), but it's good to know how to do this with `lsof` too, in case `ss` is not available in the machine.

To see all the network connections we can use:

```
lsof -i
```

To find who is using port 4000, we can use:

```
lsof -i :4000
```

It is also possible to filter by the protocol, but I haven't had a use case for this:

```
lsof -i tcp
lsof -i udp
```

## Find information about a program

If you have a process ID, you can find all files opened by that process using this command:

```
lsof -p 950
```

If you are not sure about the process ID, but you know the command that was used, you can use:

```
lsof -c jekyll
```

The command doesn't have to be an exact match. The output will include anything that starts with `jekyll`. If more flexibility is needed, the argument can be surrounded by slashes to search using a regular expression (`/<regex>/`):

```
lsof -c /.*kyll/
```

## Specific files

If you know the file you are interested in, you can find all processes using that file with this command:

```
lsof /var/log/syslog
```

If you want to list all processes that are using anything inside a directory:

```
lsof +D /home/adrian/
```

## What a user is doing

If you want to know what a specific user is doing:

```
lsof +u adrian
```

## Conclusion

`lsof` is a very powerful command with many options that I didn't mention in this article. If you need lsof to do something not mentioned here, you should take a look at the man pages: `man lsof`.
