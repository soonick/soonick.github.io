---
title: Managing Kubernetes Objects With Yaml Configurations
author: adrian.ancona
layout: post
date: 2021-12-01
permalink: /2021/12/managing-kubernetes-objects-with-yaml-configurations
tags:
  - architecture
  - automation
  - docker
  - linux
  - productivity
---

I wrote an article not long ago showing how to [get started with Kubernetes](/2021/11/introduction-to-kubernetes).

In that article we started pods by passing options as command line arguments to `kubectl create`. This works for demostration purposes, but it's not usually the way Kubernetes deployments are managed.

Having files that describe the characteristics of our deployment allows us to add these files to source control, which gives us the benefit of keeping track of changes as well as making it easy to change things like the number of pods without having to remember all other details.

For this article, I'll assume you already have a Kubernetes cluster and a configured `kubectl` client. If you don't have these ready, you might want to take a look at my [introduction to Kubernetes](/2021/11/introduction-to-kubernetes) to get those set up.

<!--more-->

## Kubernetes Objects

A `Kubernetes Object` is a unit we can manage with kubectl; Examples of objects are: `pods`, `deployments`, `services`, etc.

## Config files

Let's start by looking at a kubectl command with inline arguments:

```sh
kubectl create deployment echo-server-deployment \
  --image=ealen/echo-server \
  --replicas=1
```

The minimal configuration file required to create the same deployment looks like this:

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

The `apiVersion` field defines the schema of the file and the `kind` field tells us that this is defining a `deployment`.

It's necessary to specify a name for our object. We do that in the top level `metadata` section:

```yaml
metadata:
  name: echo-server-deployment
```

Next is our deployment `spec`. The `selector` section is used to specify the pods that are managed by this deployment. This must match the pods labels:

```yaml
spec:
  selector:
    matchLabels:
      app: echo-server-deployment
```

The `replicas` field is pretty self explanatory.

The `template` section describes the pods that will be created. We start by adding a label to identify the pods created by this deployment:

```yaml
  template:
    metadata:
      labels:
        app: echo-server-deployment
```

Followed by our pods `spec`:

```yaml
    spec:
      containers:
      - image: ealen/echo-server
        name: echo-server
```

If we save this to a file named `deployment.yaml`, we can use this command to create the deployment:

```sh
kubectl create -f deployment.yaml
```

If we want to change the number of replicas in our deployment, we can just update the number in the configuration file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-server-deployment
spec:
  selector:
    matchLabels:
      app: echo-server-deployment
  replicas: 3
  template:
    metadata:
      labels:
        app: echo-server-deployment
    spec:
      containers:
      - image: ealen/echo-server
        name: echo-server
```

To update our deployment, we use this command:

```sh
kubectl replace -f deployment.yaml
```

The replace command replaces the configuration, but the `pods` are still updated in a safe manner (rolling update). If we list the pods, we can see that the original pod wasn't touched (The `AGE` is older) but two new pods were created:

```sh
kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
echo-server-deployment-c4dd99ffc-4ptq6   1/1     Running   0          3m2s
echo-server-deployment-c4dd99ffc-9svg6   1/1     Running   0          4s
echo-server-deployment-c4dd99ffc-n5d5p   1/1     Running   0          4s
```

Since our configuration is very minimal, a lot of configuration options use their default value. To see the whole runtime configuration, we can use:

```sh
kubectl get -f deployment.yaml -o yaml
```

The output looks something like this:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: "2021-11-17T00:41:10Z"
  generation: 2
  name: echo-server-deployment
  namespace: default
  resourceVersion: "20568"
  uid: 62954d9a-3645-4d34-a897-821ec8428a5d
spec:
  progressDeadlineSeconds: 600
  replicas: 3
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: echo-server-deployment
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: echo-server-deployment
    spec:
      containers:
      - image: ealen/echo-server
        imagePullPolicy: Always
        name: echo-server
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status:
  availableReplicas: 3
  conditions:
  - lastTransitionTime: "2021-11-17T00:41:10Z"
    lastUpdateTime: "2021-11-17T00:41:12Z"
    message: ReplicaSet "echo-server-deployment-c4dd99ffc" has successfully progressed.
    reason: NewReplicaSetAvailable
    status: "True"
    type: Progressing
  - lastTransitionTime: "2021-11-17T00:44:11Z"
    lastUpdateTime: "2021-11-17T00:44:11Z"
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  observedGeneration: 2
  readyReplicas: 3
  replicas: 3
  updatedReplicas: 3
```

We can see all the fields defined in our file, plus a lot more that are just grabbing the default value.

Finally, we can delete our deployment with:

```sh
kubectl delete -f deployment.yaml
```

## Conclusion

In this article we learned how to use the imperative configuration files to manage Kubernetes objects. We only covered deployments, but other objects work similarly.

The [Full documentation for the configuration API](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.22/) can be used to learn all the options that can be configured for all the available objects.
