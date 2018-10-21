---
id: 3266
title: SSH to a running docker container
date: 2015-11-05T07:46:03+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3266
permalink: /2015/11/ssh-to-a-running-docker-container/
tags:
  - docker
  - linux
---
Docker containers are created based on images. If you want to create a new container based on a fedora image and run a terminal on it you can do:

```
docker run -i -t fedora bash
```

Every time you execute this command a new container will be created based on the fedora image.

Most of the time we run docker containers with servers in a daemonized mode. Here is a very simple example:

```
docker run -i -d fedora bash
```

In this scenario, we know the container is running, but we can&#8217;t really interact with it anymore. If something is not working correctly and we want to debug why, we need to create a new container with a shell and try to reproduce all the steps that led to the error. Well, at least that was the way I used to do it.

<!--more-->

## Docker exec

Docker exec allows you to execute commands in a running container. It works very similar to docker run, but with a running container. Say we have a container running and we want to see which environment variables are defined in the container:

```
docker exec -i 46fbb818b9ca printenv
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=46fbb818b9ca
HOME=/root
```

We can use the same technique open a shell to a running container:

```
docker exec -i -t 46fbb818b9ca bash
```
