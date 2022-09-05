---
title: Kubernetes Java Client
author: adrian.ancona
layout: post
date: 2022-09-07
permalink: /2022/09/kubernetes-java-client
tags:
  - docker
  - java
  - programming
---

If you are [getting started with Kubernetes](https://ncona.com/2021/11/introduction-to-kubernetes), you probably have been using `kubectl` to perform operations on your cluster. `Kubectl` is a client library that communicates with the Kubernetes cluster using the [Kubernetes API](https://kubernetes.io/docs/concepts/overview/kubernetes-api/).

In this article we are going to learn how to use the [Kubernetes Java Client](https://github.com/kubernetes-client/java) to communicate with our cluster from a Java program.

## Installation

The official installation instructions can be found here: https://github.com/kubernetes-client/java/wiki/1.-Installation

For Bazel, we need to have the maven repository configured in the namespace and the `client-java` artifact:

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
    'io.kubernetes:client-java:15.0.1',
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
    '@maven//:io_kubernetes_client_java',
    '@maven//:io_kubernetes_client_java_api'
  ],
)
```

## Example usage

One of the simplest things we can do with Kubernetes client is list all pods in all namespaces:

```java
package demo;

import io.kubernetes.client.openapi.ApiClient;
import io.kubernetes.client.openapi.ApiException;
import io.kubernetes.client.openapi.Configuration;
import io.kubernetes.client.openapi.apis.CoreV1Api;
import io.kubernetes.client.openapi.models.V1Pod;
import io.kubernetes.client.openapi.models.V1PodList;
import io.kubernetes.client.util.Config;

import java.io.IOException;

public class PodLister {
  public static void main(String[] args) throws IOException, ApiException {
    ApiClient client = Config.defaultClient();
    Configuration.setDefaultApiClient(client);

    CoreV1Api api = new CoreV1Api();
    V1PodList list = api.listPodForAllNamespaces(null, null, null, null, null, null, null, null, null, null);

    for (V1Pod item : list.getItems()) {
        System.out.println(item.getMetadata().getName());
    }
  }
}
```

Note that the example above uses `Config.defaultClient()`; The default client looks for `~/.kube/config`, which contains the information and credentials necessary to connect to a cluster.

If our configuration is in another path, we instruct the client to use this path:

```java
ApiClient client = ClientBuilder
    .kubeconfig(KubeConfig.loadKubeConfig(new FileReader("/path/to/config")))
    .build();
```
You can see a full running example in: https://github.com/soonick/ncona-code-samples/tree/master/kubernetes-java-client/default-client

## Conclusion

The Kubernetes Java Client provides a way to programatically perform operations on a Kubernetes cluster. This can be used to automate tasks or check on the status of the cluster.

Although this is the official client, there is [another java client by fabric8.io](https://github.com/fabric8io/kubernetes-client) that is more widely used and you should probably be considered too.
