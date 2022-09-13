---
title: Monitoring Kubernetes Resources with Fabric8 Informers
author: adrian.ancona
layout: post
date: 2022-09-21
permalink: /2022/09/monitoring-kubernetes-resources-with-fabric8-informers
tags:
  - automation
  - docker
  - java
  - programming
---

In my previous article we learned how to use the [fabric8 java kubernetes client](/2022/09/fabric8-kubernetes-java-client). In this article we are going to explore their Informer API.

The Informer API can be used to monitor Kubernetes resources (pods, services, etc.). This can be useful for a number of things like performing actions when a resource is created, destroyed, etc.

## Using Informers

Informers are used to monitor Kubernetes resources. We create an informer with `SharedInformerFactory`:

<!--more-->

```java
final KubernetesClient client = new KubernetesClientBuilder().build();

final SharedInformerFactory informerFactory = client.informers();

final SharedIndexInformer<Pod> podInformer = informerFactory
    .sharedIndexInformerFor(Pod.class, 10_000);
```

In the example above we create an informer that will listen for changes in pods (`Pod.class`). The second argument is the number of miliseconds the informer will wait before doing a full resync. A resync is the action of getting all the resources of the specified type (in this case `Pod.class`) and emiting and event for them based on the current state of that resource.

The next step is to add listeners for the different types of event:

```java
podInformer.addEventHandler(new ResourceEventHandler<Pod>() {
  @Override
  public void onAdd(Pod pod) {
    System.out.println("pod " + pod.getMetadata().getName() + " added");
  }

  @Override
  public void onUpdate(Pod oldPod, Pod newPod) {
    System.out.println("pod " + oldPod.getMetadata().getName() + " modified");
  }

  @Override
  public void onDelete(Pod pod, boolean b) {
    System.out.println("pod " + pod.getMetadata().getName() + " deleted");
  }
});
```

We can see that there are 3 events:

- `onAdd` - Executed when the resource is seen for the first time. When the informer is started it emits `onAdd` for each pod currently running
- `onModifed` - Executed when the spec for a resource is modified. This event is also triggered for all running resources every `resync` period, even if there were no changes
- `onDelete` - Executed after a resource has been completely deleted

## Informer in action

The sample code above starts an informer that simply prints the events to the console. Let's see it actions. For this we will need a cluster. I'll use [minikube](https://minikube.sigs.k8s.io/docs/start/) to start a cluster in my computer.

This is the complete code for the Informer:

```java
public class InformerSample {
  public static void main(String[] args) {
    KubernetesClient client = new KubernetesClientBuilder().build();
    final SharedInformerFactory informerFactory = client.informers();

    final SharedIndexInformer<Pod> podInformer = informerFactory
        .sharedIndexInformerFor(Pod.class, 10_000);

    podInformer.addEventHandler(new ResourceEventHandler<Pod>() {
      @Override
      public void onAdd(Pod pod) {
        System.out.println("pod " + pod.getMetadata().getName() + " added");
      }

      @Override
      public void onUpdate(Pod oldPod, Pod newPod) {
        System.out.println("pod " + oldPod.getMetadata().getName() + " modified");
      }

      @Override
      public void onDelete(Pod pod, boolean b) {
        System.out.println("pod " + pod.getMetadata().getName() + " deleted");
      }
    });

    informerFactory.startAllRegisteredInformers();
  }
}
```

Once the cluster is running, we can start the informer and we will see this being printed (your result might vary slightly):

```
pod coredns-64897985d-rqnnn added
pod etcd-minikube added
pod kube-apiserver-minikube added
pod kube-controller-manager-minikube added
pod kube-proxy-94vkk added
pod kube-scheduler-minikube added
pod storage-provisioner added
```

These are all the default pods started by Kubernetes by default. If we wait some time we will see this being printed:

```
pod kube-apiserver-minikube modified
pod kube-controller-manager-minikube modified
pod kube-proxy-94vkk modified
pod kube-scheduler-minikube modified
pod storage-provisioner modified
pod etcd-minikube modified
pod coredns-64897985d-rqnnn modified
```

This will be printed every `resync` period. It basically gets the information of all the pods to make sure we have the most up to date information even if we missed an event for some weird reason.

Let's see what happens when we start a new deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-server-deployment
spec:
  selector:
    matchLabels:
      app: echo-server-deployment
  replicas: 1
  template:
    metadata:
      labels:
        app: echo-server-deployment
    spec:
      containers:
      - image: ealen/echo-server
        name: echo-server
```

We can apply that deployment with:

```bash
kubectl apply -f deployment.yaml
```

We will get something like this:

```
pod echo-server-deployment-9cfdb56d7-jwfpk added
pod echo-server-deployment-9cfdb56d7-jwfpk modified
pod echo-server-deployment-9cfdb56d7-jwfpk modified
```

A pod is first created and then is updated until it gets to a stable state.

We can delete the deploymet:

```bash
kubectl apply -f deployment.yaml
```

And we will see the pod being modified, until it finally gets deleted:

```
pod echo-server-deployment-9cfdb56d7-n8gr6 modified
pod echo-server-deployment-9cfdb56d7-n8gr6 modified
pod echo-server-deployment-9cfdb56d7-n8gr6 modified
pod echo-server-deployment-9cfdb56d7-n8gr6 modified
pod echo-server-deployment-9cfdb56d7-n8gr6 deleted
```

You can find the full code with instructions to run it, at: [Monitoring Kubernetes Resources with Fabric8 Informers](https://github.com/soonick/ncona-code-samples/tree/master/monitoring-kubernetes-resources-with-fabric8-informers)

## Conclusion

Informers can be used to easily listen for changes to a Kubernetes resource and react to those changes. In this scenario we reacted to events on Pods, but we can listen on events for any type of resource.

Informers are specially useful when we want to create controllers for custom resources, which is something we'll explore in a future article.
