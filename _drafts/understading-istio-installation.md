---
title: Understanding Istio installation
author: adrian.ancona
layout: post
# date: 2022-06-15
# permalink: /2022/06/understanding-and-using-istio-gateways
tags:
  - architecture
  - automation
  - docker
  - networking
---

In my article [Kubernetes networking with Istio](/2022/02/kubernetes-networking-with-istio) I showed how to install Istio in a Kubernetes cluster but I didn't really explain what happens during the installation. In order to understand Istio a little better, I'm going to explain what happens when we install Istio.

In my article I use this command to install Istio:

```
istioctl install --set profile=demo -y
```

[`istioctl`](https://istio.io/latest/docs/reference/commands/istioctl/) is a tool that can be used to operate on an Istio cluster. As shown above, it can also be used to install Istio in a Kubernetes cluster.


The [istioctl install command](https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-install) generates an Istio install manifests and applies it to a Kubernetes cluster.

https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/
https://istio.io/latest/docs/setup/additional-setup/config-profiles/
https://istio.io/latest/docs/setup/getting-started/
https://istio.io/latest/docs/setup/
