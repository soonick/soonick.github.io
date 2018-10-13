---
id: 3714
title: Set up SSH keys for logging into your server
date: 2016-06-29T13:45:13+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3714
permalink: /2016/06/set-up-ssh-keys-for-logging-into-your-server/
categories:
  - Linux
tags:
  - linux
  - ssh
---
I have a server that I can SSH to by using a username and password. This works fine, but I need to automate some things and now I have the need to SSH into my server without being prompted for a password. Using SSH keys is a very natural way of doing this so I decided to go ahead.

The first thing to do is generate an SSH key pair. This command should be run on the client (the computer that will SSH into the server):

```
ssh-keygen -t rsa
```

I named my key server\_key\_rsa. I also decided to use no passphrase because I don&#8217;t want to be prompted for it every time I SSH into my server.

Now, we need to copy this generated key to the server:

```
ssh-copy-id -i /home/myself/.ssh/server_key_rsa user@myhost
```

From now on I won&#8217;t be prompted for a password when I try to log into my server.

<!--more-->
