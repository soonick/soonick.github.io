---
id: 3277
title: Local development with Docker
date: 2015-11-12T10:01:03+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3277
permalink: /2015/11/local-development-with-docker/
categories:
  - Linux
tags:
  - docker
  - linux
  - productivity
  - testing
---
Docker came with the promise of ending the &#8220;works on my machine&#8221; syndrome. I have to admit that when I first read about Docker and thought about it, it sounded like they were just bragging. With the little knowledge I had, I thought that the only way to have all developers work in a consistent environment was to start a container and somehow work inside the container. Now that I know a little more, I realize that it is not the answer, and the answer is actually really easy.

## Volumes

Docker comes with something called [data volumes](http://docs.docker.com/engine/userguide/dockervolumes/). These basically allow you to mount a folder from the host system into the docker container. This effectively allows you to have your project folder available in the container. This means that you can keep developing the way you have always done it, and have the code run inside the container.

<!--more-->

## Example

To better understand how this works, lets do a little exercise. We are going to create a project that consists of a single HTML file. We are going to use a docker container with NGINX to serve this file. This will be our production setup. Once we have that working, we are going to use volumes to mount our project folder into the container and see how we can modify the file and have the changes be reflected in the running container.

Lets start by creating our project:

```
mkdir ~/project
echo "Awesome project" >> ~/project/index.html
```

That should do the trick. Now, lets create a Dockerfile for this project:

```
FROM nginx

WORKDIR /usr/share/nginx/html
COPY index.html index.html
```

Build and run it:

```
docker build .
docker run -d -p 9999:80 <image_id>
```

Now, you should see the page running at http://localhost:9999. We have an image ready for production and we have tested it locally. But how do we do further development on it? Just mount a volume.

```
docker run -d -p 9999:80 -v $(pwd):/usr/share/nginx/html <image_id>
```

Now you can modify index.html

```
echo "<br>New line" >> index.html
```

And you will see the changes reflected right away.
