---
id: 4088
title: Host your Docker images for free with canister.io
date: 2017-02-01T11:17:34+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4088
permalink: /2017/02/host-your-docker-images-for-free-with-canister-io/
categories:
  - Linux
tags:
  - automation
  - docker
  - productivity
---
I&#8217;m slowly incrementing the number of projects I host in my personal servers and as the number increases I find the need to standardize the way I deploy each service. Currently each service has a different way of running and I have to try to remember how to do it each time I have an update. As one of the steps to a more streamlined deploy process I decided for each service to have a production ready image hosted in a Docker registry. The deploy will then just be a matter of downloading and running the image in the production machine (not perfect, but a step forward).

My first idea was to host a Docker registry myself, but luckily I found a service that offers 20 private repositories for free. To start using [canister.io](https://canister.io), you just need to [register for the basic plan](https://canister.io/solo) and create a new repo.

To push images you can use the command line. Start by logging in:

```
docker login --username=username cloud.canister.io:5000
```

<!--more-->

The next step is to tag an image that you want to publish:

```
docker tag ae5da82730b1 cloud.canister.io:5000/username/my-repo:latest
```

Notice the format of the tag: <registry-url-including-port>/<username>/<repo-name>:<tag>. I used latest as my tag name but you can use any tag name you want.

Finally we just need to push the tag:

```
docker push cloud.canister.io:5000/username/my-repo
```

Note that this command doesn&#8217;t include the tag being pushed. It will push all tags in the given repo.

For the deploy I had to do something similar. First, log in to canister.io in the production server:

```
docker login --username=username cloud.canister.io:5000
```

Pull the image:

```
docker pull cloud.canister.io:5000/username/my-repo:latest
```

And finally start it:

```
docker run -d --restart=on-failure --name my-service-container cloud.canister.io:5000/username/my-repo:latest
```
