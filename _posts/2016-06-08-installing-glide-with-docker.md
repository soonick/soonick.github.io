---
id: 3673
title: Installing Glide with Docker
date: 2016-06-08T17:07:32+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3673
permalink: /2016/06/installing-glide-with-docker/
tags:
  - linux
  - automation
  - docker
  - golang
---
I was looking for a simple recipe to install Glide into one of my Docker images and I couldn&#8217;t find it so I created my own:

```docker
# Install glide
RUN mkdir /tools
WORKDIR /tools
RUN wget https://github.com/Masterminds/glide/releases/download/0.10.2/glide-0.10.2-linux-386.tar.gz
RUN tar -zxvf glide-0.10.2-linux-386.tar.gz
RUN mv linux-386/ glide/
ENV PATH /tools/glide:$PATH
```

It is pretty simple. The only part that caught me by surprise was adding a path to the $PATH. The best way to do it is by using the ENV instruction:

```
ENV PATH /tools/glide:$PATH
```

Now, all containers created from this image will have glide available in their path.

<!--more-->
