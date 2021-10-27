---
title: Introduction to Kubernetes
author: adrian.ancona
layout: post
date: 2021-11-03
permalink: /2021/11/introduction-to-kubernetes
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

- Control Plane
- Nodes

The `Control Plane` refers to hosts that are responsible for managing the cluster, while the `Nodes` are the hosts where applications are run.

Kubernetes `Nodes` need to have a container management system (Docker, for example) as well as an agent used for communicating with the `Control Plane`. The name of this agent is `Kubelet`.

<!--more-->

When we need to perform and operation on the Kubernetes cluster (For example, deploy an application), we tell the `Control Plane` that we want to deploy the application. The `Control Plane` will then decide in which `Nodes` it should run the application and communicate with those nodes to get the application to the desired state.

## Creating a cluster

Creating a cluster from scratch it's not a simple task. Instead, we are going to create a cluster in Google Cloud. This cluster might incur some costs (Less than 1 USD if we run it for one day), but we are going it to tear it down at the end of this article.

I assume that you have a Google Cloud account and gcloud cli set up. You can take a look at my [introduction to Google Cloud CLI](https://ncona.com/2020/09/introduction-to-google-cloud-cli/), if you need help setting it up.

We can use this command to verify we are connected to the right account:

```bash
gcloud auth list
```

To list all our Kubernetes clusters we can use this command:

```bash
gcloud container clusters list
```

If we don't have any clusters running, the command won't return any output.

Before we create a cluster we need to [install `kubectl`](https://kubernetes.io/docs/tasks/tools/), which is a command line utility to interact with our Kubernetes cluster.

In Linux, we can download it:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

And then install it:

```bash
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

To keep costs at a minimum, we are going to be creating a cluster with only 1 node:

```bash
gcloud container clusters create our-test-cluster --zone us-central1-a --num-nodes 1
```

After some time, our cluster will be ready. We can see the status of the cluster using `gcloud`:

```bash
gcloud container clusters list
NAME              LOCATION     MASTER_VERSION   MASTER_IP       MACHINE_TYPE  NODE_VERSION     NUM_NODES  STATUS
our-test-cluster  us-central1  1.20.10-gke.301  104.197.87.172  e2-medium     1.20.10-gke.301  9          RUNNING
```

## Configuring kubectl

Now that we have our cluster running, we need to configure `kubectl` so it can manage this cluster. `kubectl`, has the concept of `context`, which basically means the cluster the tool will talk to if no other cluster is specified with the `--cluster` flag.

To get the current context:

```bash
kubectl config current-context
```

If a `context` hasn't been set, we will recieve a message saying so. To set our context we can:

```
gcloud container clusters get-credentials our-test-cluster --zone us-central1-a
```

After doing that, the `context` will be set:

```
kubectl config current-context
gke_test-123456_us-central1_our-test-cluster
```

The information `kubectl` uses to connect to a cluster is stored under `~/.kube/config`.

## Deploying an application

Now that we have `kubectl` set up, we can use it to deploy applications in our cluster.

Before we deploy our application we need to get familiar with some concepts. First of all, I'll assume you are familiar with what an image and a container are in the Docker world. On top of these concepts, Kubernetes introduces the concept of `pod`. A `pod` is a group of one or more containers with shared storage and network resources. These containers always run together in a single `node`.

Basically, a `pod` contains a group of application containers that always need to run together.

Pods are the unit of deployment in Kubernetes. We don't deploy `containers`, we deploy `pods`. We can deploy a pod that consists of a single container with this command:

```sh
kubectl create deployment echo-server-deployment --image=ealen/echo-server --replicas=1
```

`echo-server-deployment` is the name of our deployment. [`ealen/echo-server`](https://hub.docker.com/r/ealen/echo-server) is the name of the docker image we are deploying, `--replicas=1` means that we only want one instance of this `pod` to run.

We can see our deployments:

```sh
kubectl get deployments
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
echo-server-deployment   1/1     1            1           2m10s
```

The `READY` column tells us how many of our replicas are ready to be used by our end users. It follows the format `<ready>/<desired>`.

`UP-TO-DATE` tells us how many replicas have been updated to the latest desired state. Currently it shows that all our `pods` are `UP-TO-DATE`, but during a rolling deployment this number might be lower than our total replicas for some time.

`AVAILABLE` tells us how many replicas are available to our users.

We can also see our `pods`:

```sh
kubectl get pods
NAME                                     READY   STATUS    RESTARTS   AGE
echo-server-deployment-c4dd99ffc-2kmkh   1/1     Running   0          2m34s
```

We can see the name of the `pod` starts with the name of our `deployment`. In this case, `READY` means how many containers of our pod are available to our users. Since our `pod` has only one `container`, it only shows `1/1`.

Let's scale our deployment so we are running two pods instead of just one:

```sh
kubectl scale deployment/echo-server-deployment --replicas=2
```

If we check our deployment, we will see that we now have 2 replicas:

```sh
kubectl get deployments
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
echo-server-deployment   2/2     2            2           9m53s
```

If we inspect the `pods`, we'll see that both of them are running in the same `node` because we only have one:

```sh
kubectl get pods -o wide
NAME                                     READY   STATUS    RESTARTS   AGE     IP          NODE                                              NOMINATED NODE   READINESS GATES
echo-server-deployment-c4dd99ffc-q52bj   1/1     Running   0          3m40s   10.0.0.12   gke-our-test-cluster-default-pool-ad01764f-trn6   <none>           <none>
echo-server-deployment-c4dd99ffc-s8g6t   1/1     Running   0          13m     10.0.0.10   gke-our-test-cluster-default-pool-ad01764f-trn6   <none>           <none>
```

If we describe the `deployment` we can see the change we made in the events:

```sh
kubectl describe deployment/echo-server-deployment

...

Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  17m   deployment-controller  Scaled up replica set echo-server-deployment-c4dd99ffc to 1
  Normal  ScalingReplicaSet  8m5s  deployment-controller  Scaled up replica set echo-server-deployment-c4dd99ffc to 2

```

We successfully scaled our application.


## Troubleshooting

Kubernetes provides a set of tools that can be used to diagnose problems if they arise. Let's look at some of them.

If we want to see all the pods in our cluster we can use:

```bash
kubectl describe pods
```

This will output a lot of information if we have a lot of pods in a cluster. If we only care about a single pod, we can use:

```bash
kubectl describe pods/<pod id>
```

The output of the describe command contains a lot of useful information. Some of it is the id of the `node` where the pod is running, information about the containers and their state, and the last events that have happened in the `pod`. If there are issues starting containers, or passing health checks, these will be visible in the events.

Another way to troubleshoot problems with a pod is to look at the logs:

```bash
kubectl logs <pod id>
```

If this is not enough, we can get a shell to a container:

```bash
kubectl exec -it <pod id> -- sh
```

If our `pod` has more than one container, we need to specify which container we want to connect to:

```bash
kubectl exec -it <pod id> -c <container name> -- sh
```

## Services

When we deploy an application in Kubernetes, all `pods` are given a private IP address that allows them to communicate with other pods in the same cluster.

The problem with is that pods can come and go, so it's hard to keep track of the IPs we need to call to reach a service. We need something like a load balancer where pods can register so it's easy to find a specific service. This is what `services` do.

The simplest `service` type is the `ClusterIP` (which is the default). This creates an IP address in the private network and acts as a load balancer that will redirect requests to that IP to the desired `pods`.

By default, there is a service called `kubernetes`:

```bash
kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.3.240.1   <none>        443/TCP   31m
```

This service is used by pods to find the control plane host. To expose our own service, we can use the following command:

```bash
kubectl expose deployment/echo-server-deployment --port 80
```

We can now see our service:

```bash
kubectl get services
NAME                     TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
echo-server-deployment   ClusterIP   10.3.248.92   <none>        80/TCP    34s
kubernetes               ClusterIP   10.3.240.1    <none>        443/TCP   6m29s
```

Since the IP assigned to the service is internal to the cluster (`10.3.248.92`), we need to get in the cluster to test that it's doing what we want. We can do this by getting a shell into a pod:

```bash
kubectl exec -it <pod id> -- sh
```

From inside the pod, we can use `wget` to make a request:

```bash
wget 10.3.248.92?query=test -O output
```

If we then check the pod logs, we are going to see that requests are balanced between both pods:

```bash
kubectl logs <pod id>
```

## Cleaning up

Now that we are done playing around, we can destroy our cluster so we are not charged for it anymore:

```bash
gcloud container clusters delete our-test-cluster --zone us-central1-a
```

## Conclusion

In this article we scratched the surface of what can be done with Kubernetes. We created a cluster and deployed some pods using a docker image. We also learned some debugging tools that will be used to diagnose problems in our future clusters.
