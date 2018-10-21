---
id: 4307
title: Introduction to Bitbucket Pipelines
date: 2017-09-13T04:16:44+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4307
permalink: /2017/09/introduction-to-bitbucket-pipelines/
tags:
  - automation
  - bash
  - docker
---
I have a few projects that I host on Bitbucket (Mostly because I can have private repos for free). As I was working on some of these projects last week, I realized that there are a lot of manual steps I have to execute in order to verify that my project is in good health and to publish it or deploy it.

Today I&#8217;m going to explore using Bitbucket&#8217;s Pipelines to generate a Docker image out of one of my projects and publish it to [Canister](https://ncona.com/2017/02/host-your-docker-images-for-free-with-canister-io/).

<!--more-->

## Pricing

Although Bitbucket Pipelines have a free tier, it only allows 50 build minutes a month. This is a pretty low limit most people will probably reach pretty quickly. The next tier is for $10 USD a month, so I&#8217;ll analyze moving to that tier if I find the service worth it.

## Goals

My main goal for this project is to automatically publish a Docker image to [Canister](http://ncona.com/2017/02/host-your-docker-images-for-free-with-canister-io/) for each push to my repo. For this to work, I will have to do a few things:

  * Tag every successful build with a consecutive number (1, 2, 3 &#8230;)
  * Create a docker image from that build and tag it with the same build number
  * Publish to Canister

## Creating a Pipeline

Pipelines are configured by creating a **bitbucket-pipelines.yml** file. Since what I want to do is build a docker image for my project, I&#8217;m going to follow the Docker sample and modify it:

```yml
# enable Docker for your repository
options:
  docker: true

pipelines:
  branches:
   # This means that I want to run this pipeline only for commits on master
    master:
     # Currently there can only be one step per pipeline
      - step:
          script:
           # But there can be multiple scripts here
            - sh scripts/publish.sh
```

I added some comments to explain what is going on. Most of the magic happens inside scripts/publish.sh.

```bash
# Constants
PROJECT='ncona'
REGISTRY_URL='cloud.canister.io:5000'

# Tags the current commit with the next consecutive number (1, 2, 3 ...)
LAST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
NEW_TAG=$((LAST_TAG + 1))
git tag $NEW_TAG
git push origin $NEW_TAG

# Build docker image
docker build . --tag $PROJECT

# Publish docker image
docker login --username=$REGISTRY_USERNAME --password=$REGISTRY_PASSWORD $REGISTRY_URL
docker tag $PROJECT "$REGISTRY_URL/$REGISTRY_USERNAME/$PROJECT:$NEW_TAG"
docker push "$REGISTRY_URL/$REGISTRY_USERNAME/$PROJECT:$NEW_TAG"
```

The script is commented to make it easier to understand. We use some shell magic to generate the tag number, but otherwise things are pretty simple. This script won&#8217;t actually work until we take care of two things: define the secret environment variables REGISTRY\_USERNAME and REGISTRY\_PASSWORD, and give the worker the correct SSH key so it can push the tag to our repo.

## Secure environment variables

The script above needs to log in to Canister in order to push the generated Docker image. We don&#8217;t want to allow anybody to push to our repository, so we need to authenticate before we can push. Bitbucket allows you to save the environment variables online and they will be securely stored for you. The variables can be created on a repository level or an account level:

[<img src="/images/posts/secure-variables.png" />](/images/posts/secure-variables.png)

## SSH key

For this specific scenario in which I want to tag each successful commit, I need the worker running my Pipeline to be able to push to my repository. This requires two steps:

First, we need to generate a new SSH key for our workers. This can be done from the repository settings:

[<img src="/images/posts/worker-ssh-key.png" />](/images/posts/worker-ssh-key.png)

Finally, since I want this key to have write access to the repo, I have to add the public key to the list of my user&#8217;s SSH keys:

[<img src="/images/posts/user-ssh-keys.png" />](/images/posts/user-ssh-keys.png)

After all this, I can have my pipeline automatically publish all my commits to canister so I can deploy whenever I want.
