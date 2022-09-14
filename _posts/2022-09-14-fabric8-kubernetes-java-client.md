---
title: Fabric8 Kubernetes Java Client
author: adrian.ancona
layout: post
date: 2022-09-14
permalink: /2022/09/fabric8-kubernetes-java-client
tags:
  - docker
  - java
  - programming
---

In [my last article](/2022/09/kubernetes-java-client) we learned how we can use the [official Kubernetes Java Client](https://github.com/kubernetes-client/java) to operate on a Kubernetes cluster.

In this article we are going to learn how we can use the most popular Kubernetes Client for Java.

## Installation

For using fabric8's Kubernetes client with Bazel, we need to have the maven repository configured in the workspace and the `kubernetes-client` artifact:

<!--more-->

```py
load('@bazel_tools//tools/build_defs/repo:http.bzl', 'http_archive')

RULES_JVM_EXTERNAL_TAG = '4.1'
RULES_JVM_EXTERNAL_SHA = 'f36441aa876c4f6427bfb2d1f2d723b48e9d930b62662bf723ddfb8fc80f0140'

http_archive(
  name = 'rules_jvm_external',
  strip_prefix = 'rules_jvm_external-%s' % RULES_JVM_EXTERNAL_TAG,
  sha256 = RULES_JVM_EXTERNAL_SHA,
  url = 'https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip' % RULES_JVM_EXTERNAL_TAG,
)

load('@rules_jvm_external//:defs.bzl', 'maven_install')

maven_install(
  artifacts = [
    'io.fabric8:kubernetes-client:6.1.1',
  ],
  repositories = [
    'https://repo1.maven.org/maven2',
  ],
)
```

We also need to add the kubernetes client packages as dependencies:

```py
java_binary(
  name = 'demo',
  srcs = glob(['*.java']),
  main_class = 'demo.PodLister',
  deps = [
    '@maven//:io_fabric8_kubernetes_client',
    '@maven//:io_fabric8_kubernetes_client_api'
  ],
)
```

## Example usage

In my [Kubernetes client post](/2022/09/kubernetes-java-client) we learned how to list all pods, let's see how we can do the same thing with fabric8:

```java
package demo;

import io.fabric8.kubernetes.client.KubernetesClient;
import io.fabric8.kubernetes.client.KubernetesClientBuilder;

public class PodLister {
  public static void main(String[] args) {
    try (KubernetesClient client = new KubernetesClientBuilder().build()) {
      client.pods().inNamespace("default").list().getItems().forEach(
        pod -> System.out.println(pod.getMetadata().getName())
      );
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }
```

If we compare it with the official Kubernetes Client, Frabric8's API is much easier to follow. In the official client we had a method with a long list of arguments that are hard to read:

```java
api.listPodForAllNamespaces(null, null, null, null, null, null, null, null, null, null);
```

While here, it's easier to understand what's happening without having to look at the documentation:

```java
client.pods().inNamespace("default").list()
```

A full example can be found at [Fabric8 Kubernetes Java Client demo](https://github.com/soonick/ncona-code-samples/tree/master/fabric8-kubernetes-java-client/default-client)

## Conclusion

Fabric8's Kubernetes Client provides an easier to read API compared to the official [Kubernetes Java Client](https://github.com/kubernetes-client/java).

In this article I showed a very simple usage, but I'm planning on building a controller where we will use a lot more features.
