---
title: Resource Management in Kubernetes - Requests and Limits
author: adrian.ancona
layout: post
date: 2022-08-17
permalink: /2022/08/resource-management-in-kubernetes-requests-and-limits
tags:
  - linux
  - docker
---

This article assumes some basic knowledge of Kubernetes. If you need an introduction to Kubernetes you can look at:

- [Playing with Kubernetes locally with Minikube](https://ncona.com/2017/11/playing-with-kubernetes-locally-with-minikube/)
- [Introduction to Kubernetes](https://ncona.com/2021/11/introduction-to-kubernetes)
- [Managing Kubernetes Objects With Yaml Configurations](https://ncona.com/2021/12/managing-kubernetes-objects-with-yaml-configurations)

## Why do we need to know about requests and limit

If we tried to run a pod that requires 8GB of memory in a host that only has 4GB of memory, the host would run out of memory and it would crash. In this article we are going to learn how to specify how much resources a pod needs so the scheduler can make better decisions about where to run pods.

<!--more-->

## Resources

There are two main resources Kubernetes supports: CPU and memory. What they are is self explanatory, but how they are specified deserves a little more attention.

CPU is specified as the amount of CPU cores we need for our containers. We can use `1` to say we need one core or `5` to say we need five cores.

It's also possible to request fractions of a core, down to a single milicore using `1m`. Some examples:

- One core: `1`
- One core: `1000m`
- Half a core: `500m`
- A tenth of a core: `100m`
- Ten cores: `10`
- One and a half cores: `1500m`

Memory is specified in bytes. When specifying memory, we can use the following suffixes:

- `k` - Kilobytes (`1k` = `1000`)
- `M` - Megabytes (`1M` = `1000k`)
- `G` - Gigabytes (`1G` = `1000M`)
- `T` - Terabytes (`1T` = `1000G`)
- `P` - Petabytes (`1P` = `1000T`)
- `Ki` - Kibibytes (`1Ki` = `1024`)
- `Mi` - Mebibytes (`1Mi` = `1024Ki`)
- `Gi` - Gibibytes (`1Gi` = `1024Mi`)
- `Ti` - Tebibytes (`1Ti` = `1024Gi`)
- `Pi` - Petibytes (`1Pi` = `1024Ti`)

I was surprised, but It seems that at some point in history 1 kilobyte stopped meaning `1024` bytes and now it means `1000` bytes. The correct term for `1024` bytes is kibibyte: https://en.wikipedia.org/wiki/Byte#Multiple-byte_units

Here are some examples:

- One mebibyte: `1Mi`
- Five gigabytes: `5G`
- Five hunded bytes: `500`

Even though the scheduling unit in Kubernetes is a pod, resources are specified per container. The resources that a pod needs is just the sum of the resources all the containers in the pod need.

## Requests

Requests are specified for containers using the `resources` option. For example:

```yaml
apiVersion: apps/v1
kind: Pod
metadata:
  name: echo-server
spec:
  containers:
  - image: ealen/echo-server
    name: echo-server
    resources:
      requests:
        memory: 100Mi
        cpu: 100m
```

Requests are used by the Kubernetes scheduler to decide in which host (node) a pod will be scheduled. A pod like the one specified above will only be scheduled in hosts with `100Mi` of memory and `100m` of CPU available.

Another thing to keep in mind is that requests are guaranteed. This means, if we have a host with `2Gi` of memory, the scheduler can schedule two pods requesting `1Gi` each. If one pod is not using much memory and the other pod needs more than the requested `1Gi`, it will not be allowed to use more since the rest of the memory belongs to the other pod.

With CPU, it's a little different because even if one pod is allowed to use the CPU allocated to another pod, CPU can be made immediately available on request. If two pods are running in a host with `1` core and each of them requests `500m` cores. Any pod can use the whole `1` core if the other one doesn't need it. If at some point both pods are very busy and need to use 100% of their requested CPU, each will get their requested time (Each pod would get half of the Host's CPU time).

## Limits

Limits are specified similarly to requests:

```yaml
apiVersion: apps/v1
kind: Pod
metadata:
  name: echo-server
spec:
  containers:
  - image: ealen/echo-server
    name: echo-server
    resources:
      limits:
        memory: 100Mi
        cpu: 100m
```

If `limits` are specified, but no `requests`, then `requests` will be set to the same values as `limits`. If no `limits` is specified, the limits are set to `no limits` (i.e. Can use all resources in the host).

While `requests` are used to make scheduling decisions, `limits` are used to `limit` how much resources a container can use (this is typically enforced using [cgroups](https://en.wikipedia.org/wiki/Cgroups)).

If we set a CPU limit for a container, the OS Kernel will not allocate more CPU time even if there is CPU time available.

If we set a memory limit and a container tries to use more memory than this limit, the process running in the container will most likely be killed and the container will be restarted.

## Practical examples

If you want to see requests and limits in action, take a look at: [Resource management in Kubernetes](https://github.com/soonick/ncona-code-samples/tree/master/resource-management-in-kubernetes)

You'll find some examples you can run on your own. Follow the instructions in the README and try changing things some see what happens.

## Conclusion

In this post we learned the importance of setting requests and limits for our containers. In a production environment it's recommended to set these values for all our containers so it's easier to undestand the scheduler's decisions.
