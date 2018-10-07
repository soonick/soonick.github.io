---
id: 3444
title: Restart a process automatically if it dies
date: 2016-01-20T18:51:18+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3444
permalink: /2016/01/restart-a-process-automatically-if-it-dies/
categories:
  - Linux
tags:
  - automation
  - linux
  - projects
  - server
---
I have a hobby server that I&#8217;m deploying to a digital ocean droplet. I run this server as any other program and it does what it was programmed to do:

```
./myserver
```

The problem is that this server is not perfect and I&#8217;m OK with that. Nevertheless, I don&#8217;t want to have to restart it manually every time it dies. For that reason I did some googling and found an easy way to restart my server if it unexpectedly dies:

```bash
#!/usr/bin/env bash

until /home/tacos/myserver >> myserver.log 2>> myserver.error.log; do
    echo "$(date -u) - Server crashed with exit code $?.  Respawning..." >> runner.log
    sleep 1
done

echo "$(date -u) - Server manually killed" >> runner.log
```

<!--more-->

This takes care of restarting the server if it dies, and it also logs a message to a file called runner.log so you can see when the server died or when it was manually killed.

Another important thing we should take care of, is what happens if the computer is restarted. We don&#8217;t want to have to manually start this script every time, so we should automate the start of this script. The easiest way I found is to use crontab.

```bash
crontab -e
```

And then add this line:

```
@reboot /home/tacos/run-myserver.sh
```

Now you have a script that will run on that machine all the time, unless you manually stop it.
