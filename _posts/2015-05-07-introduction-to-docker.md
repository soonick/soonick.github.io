---
id: 2840
title: Introduction to docker
date: 2015-05-07T07:28:24+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2840
permalink: /2015/05/introduction-to-docker/
categories:
  - Linux
tags:
  - linux
  - productivity
---
What is docker?

Docker is a a way to create &#8220;virtual machines&#8221; that contain your app(and its dependencies) and can be easily deployed to any environment. The thing about docker is that these virtual machines that it creates are not &#8220;complete&#8221; virtual machines. Docker uses a light weight virtualization technology that doesn&#8217;t need an hypervisor. Because it doesn&#8217;t use an hypervisor it can pack more virtual machines in a single server, which translates to more efficient use of hardware.

How does this compare to the traditional model?

In the traditional model you most likely get a server(or more), create a virtual server image with all the requirements for your app and then create all the virtual machines you need on your server. When you are ready to deploy your app you grab a build of the app and install it on all of the virtual machines.

<!--more-->

In the docker model you get a server(or more) and install the docker daemon on it. When you are ready to deploy your app you tell the docker daemon to create containers based on the image of your app.

They don&#8217;t look that different because they really aren&#8217;t, but there are some important things to note:

  * Regular VMs use an hypervisor which adds some overhead. Docker claims to provide a lighter alternative that will allow you to run more containers per host
  * In the traditional model VMs are created up-front. Docker creates a new container every time you want to deploy your app. Because it has to create a container from scratch the deploy of your app might take longer
  * Docker images are recipes for creating containers. These recipes come in layers. Generally the recipe will be something like: Give me an Ubuntu system, install Apache and install this version of my app. Docker will download these layers from it&#8217;s registry and it will cache them. If you need to deploy another container that uses any of the layers, it will only download the new layers
  * A docker container can be created in any system with the docker daemon installed. This means that developers can easily run an exact copy of the production environment in their machines with no effort

From here it doesn&#8217;t seem like the pros or cons of one of the approaches makes it much better than the other. Lets play a little with docker to see if something changes.

## Installation

You can use yum to install the docker daemon and the docker client in fedora

```
sudo yum -y install docker
```

You can start the docker daemon the same way you start any other daemon in fedora:

```
sudo systemctl start docker
```

And to have it start every time the system starts:

```
sudo systemctl enable docker
```

## Running images

To run a docker image, you use the **docker run** command:

```
sudo docker run -i fedora /bin/echo 'Hello world'
```

Here we are telling docker to start a container using the **fedora** image and then run **/bin/echo &#8216;Hello world&#8217;** inside that container. If the fedora image is not already on your host, the docker daemon will try to download it from docker hub. Once an image is downloaded, it will be cached so docker doesn&#8217;t need to download it again in case it is needed in the future.

The docker run command will run the specified command and then close the container. In the previous example you will see &#8220;Hello world&#8221; in your terminal and then the container will be closed. This doesn&#8217;t seem very useful but keep in mind that you can specify any command you want. Most of the time you will specify a command that runs as a daemon(like a server) so the container will just keep running until that daemon is killed.

Very often docker is used to run servers so a better alternative is to start the container as a daemon. This will run the specified command and will send the process to the background and keep it running until the command ends. To run a container as a daemon add a -d flag:

```
sudo docker run -i -d fedora /bin/echo 'Hello world'
```

Running a container as a daemon doesn&#8217;t stop it from closing when the specified command is done. The previous example instead of echoing &#8220;Hello world&#8221; will echo a unique ID for the container. This ID can later be used for interacting with the container.

## Working with containers

Lets now create a long living container and see how we can intetact with it:

```
sudo docker run -i -d fedora /bin/bash
```

Now we have a container running in the background. To see all containers currently running you can use **docker ps**:

```
[anovelo@localhost ~]$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
4358553afdc7        fedora:latest       "/bin/bash"         6 seconds ago       Up 5 seconds                            prickly_swartz
```

Here we can see our running containers. We can refer to a specific container using it&#8217;s container id or its name. To kill the container that is currently running we can use any of these commands:

```
sudo docker stop 4358553afdc7
sudo docker stop prickly_swartz
```

If you run **docker ps** now you will see an empty list, but if you add the -a flag you will see all the containers you have started and stopped in the past:

```
sudo docker ps -a
```

If you know you are not going to use those containers anymore you can delete them:

```
sudo docker rm 4358553afdc7
```

Keeping a reference to the stopped container is useful in case you want to analyze the logs to find out what cased it to stop. You can also restart a container if you need to:

```
sudo docker start 4358553afdc7
```

If for some reason you want to clean docker by removing all stopped containers you can use this [command I borrowed from jpetazzo](https://twitter.com/jpetazzo/status/347431091415703552)

```
docker ps -a | grep 'weeks ago' | awk '{print $1}' | xargs docker rm
```

## Creating images

Now that we know how to run images and manage the running containers it&#8217;s time to create our own images. Before we start creating our image lets understand why and when we want to create our own images.

If you are working on a web project you probably already use a version control system. If you have a continuous integration environment you probably do a build for every commit and then deploy an artifact to some test environment. The process is very similar when using docker. The only difference is that instead of deploying an artifact you deploy a custom image created by you.

To create an image we first need to create a recipe, and for this we use a Dockerfile. The Dockerfile contains a [set of instructions to create an image](https://docs.docker.com/reference/builder/). The best way to understand it is with an example:

```
mkdir docker-test
cd docker-test
touch Dockerfile
```

And then add this to Dockerfile:

```
FROM fedora:21
MAINTAINER Adrian Ancona <adrian@ncona.com>
```

To create an image from that recipe run:

```
sudo docker build .
```

At the end you will get the id of the generated image. If you are doing this as part of a CI process you probably want to tag every image you create. You can tag an image with something like this:

```
sudo docker build -t user/image-name:1.2.3 .
```

This creates an image for the user &#8220;user&#8221; with a name &#8220;image-name&#8221; and a tag &#8220;1.2.3&#8221;. You can see the images on your host like this:

```
[anovelo@localhost docker-example]$ sudo docker images
REPOSITORY                  TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
user/image-name                   1.2.3               e1dd1a2ed03f        5 minutes ago       241.3 MB
```

Keep in mind that the user you choose here should be your user name on the docker registry you are using. If you are working on a private project be careful not to upload your images to docker hub.

We have created a custom docker image, but probably of not much use. We want our container to run our app so lets look at a more useful example:

```
FROM fedora:21
MAINTAINER Adrian Ancona <adrian@ncona.com>

RUN yum update -y && \
    yum install npm -y;
COPY build/ /app

EXPOSE 1337
```

This time I install node and copy the contents of my build folder to the image. I also expose port 1337 which is the port my app is listening to. After building that image I can start my node app with something like this:

```
sudo docker run -d -t 3ccfbfd9fd5a node /app/app.js
```

This runs our app in a container, but we can&#8217;t access it yet. We need to map a port from the container to a port in the host by using the -P flag:

```
sudo docker run -d -P 1337 3ccfbfd9fd5a node /app/app.js
```

The -P flag will map the exposed ports(defined in the Dockerfile) to random ports in the host. To find out the port that was assigned you can use any of these options:

```
sudo docker ps
sudo docker port <container_id>
```

If you want to map to an specific port you can do it with the -p flag:

```
sudo docker run -d -p 8799:1337 c45917800ae2 nodejs /app/app.js
```

The first number is the port in the host and the second the port in the container. If we go to localhost:8799 on our host we will see the contents of our web server.
