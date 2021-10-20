---
title: Introduction to Kubernetes
author: adrian.ancona
layout: post
# date: 2021-10-20
# permalink: /2021/10/introduction-to-jdbi
tags:
  - architecture
  - docker
  - gcp
---

Kubernetes is an open source system used to automate management of containerized applications. A containerized application, simply means an application that runs inside a container. The management part refers, among other things to:

- Deployment of changes
- Rollbacks
- Load balancing and discoverability
- Secret and configuration management
- Container placement
- Scaling applications

## Kubernetes clusters

A Kubernetes cluster is a set of machines that are configured in a way that allows us to tell Kubernetes that we need to run our application without having to worry about exactly where it runs. A Kubernetes cluster consists of two things:

- The Control Planes
- Nodes

The `Control Plane` refers to hosts that are responsible for managing the cluster, while the `Nodes` are the hosts where applications are run.

Kubernetes `Nodes` need to have a container management system (Docker, for example) as well as an agent used for communicating with the `Control Plane`. The name of this agent is `Kubelet`.

When we need to perform and operation on the Kubernetes cluster (For example, deploy an application), we tell the `Control Plane` that we want to deploy the application. The `Control Plane` will then decide in which `Nodes` it should run the application and communicate with those nodes to get the application to the desired state.

## Creating a cluster


