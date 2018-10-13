---
id: 1789
title: Trasfering files via SSH
date: 2013-10-17T02:53:54+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1789
permalink: /2013/10/trasfering-files-via-ssh/
categories:
  - Linux
tags:
  - linux
  - productivity
  - ssh
---
I sometimes need to transfer files from one computer to another using SSH and I always forget how to do it so I decided to write a short post as a reminder.

To copy a file from one computer to another we use the scp command, which is very easy to use:

```
scp file.txt <remote user>@<some domain or ip>:<remote path>
```

The cool thing is that you can copy from the remote computer to your local computer inverting the order:

```
scp <remote user>@<some domain or ip>:<remote path to file> /home/adrian/
```

Finally, if you want to copy a folder with all it&#8217;s content you need to add a **-r** flag.

<!--more-->
