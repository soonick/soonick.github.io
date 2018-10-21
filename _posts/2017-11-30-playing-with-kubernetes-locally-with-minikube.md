---
id: 4172
title: Playing with Kubernetes locally with Minikube
date: 2017-11-30T05:01:02+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4172
permalink: /2017/11/playing-with-kubernetes-locally-with-minikube/
tags:
  - automation
  - docker
  - linux
  - productivity
---
I want to start using Kubernetes to manage my services. Before I go all-in I will do some playing around with their easy-to-install version that can run on a single machine.

## Requirements

Before we can run Minikube locally we need to have a virtualization solution installed in our host. Since my computer supports **KVM**, I decided to go with it. You can check if your computer supports **KVM** with this command:

```
egrep -c '(vmx|svm)' /proc/cpuinfo
```

<!--more-->

If your system supports **KVM**, you will get a 1 or higher number.

I&#8217;m running Ubuntu, so I can use apt-get to install **KVM**:

```
sudo apt-get install qemu-kvm libvirt-bin bridge-utils
```

The next step is to install **kubectl**. On Linux you can use these command to download the binary and put it in your path:

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

Probably also a good idea to enable auto-completion to save some typing while using **kubectl**:

```
. <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

## Minikube

Minikube is still under very active development so the best thing to do is to follow the [installation instructions on github](https://github.com/kubernetes/minikube/releases). At the time of this writing, I used this command to install it:

```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.18.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```

Minikube requires a driver to communicate with **KVM**:

```bash
sudo curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.7.0/docker-machine-driver-kvm -o /usr/local/bin/docker-machine-driver-kvm
sudo chmod +x /usr/local/bin/docker-machine-driver-kvm
```

And finally we are ready to start the Minikube cluster:

```
minikube start --vm-driver=kvm
```

The Minikube cluster consists of a single virtual machine:

```sh
$ virsh --connect qemu:///system
Welcome to virsh, the virtualization interactive terminal.

Type:  'help' for help with commands
       'quit' to quit

virsh # list
 Id    Name                           State
----------------------------------------------------
 1     minikube                       running
```

The cluster doesn&#8217;t have any containers running yet, but it has the kubernetes client installed so it is ready to start running services.

## Vocabulary

Before we start, it is necessary to define some terms that are common when working with Kubernetes.

_Pod_ &#8211; Is a group of 1 or more containers with configurations on how to run those containers. They are always co-located (deployed in the same data center) and co-scheduled (deployed at the same time). It is basically a single application. Containers within a pod can find each other via _localhost_. Applications in different pods have different IP addresses. Users will generally not create Pods directly, but rather use Deployments.

_Replica set_ &#8211; A ReplicaSet ensures that a specified number of replicas (of a Pod) are running at any given time.

_Deployment_ &#8211; Provides a way to issue updates on Pods or Replica Sets.

_Service_ &#8211; A Service in Kubernetes is an abstraction which defines a logical set of Pods and a policy by which to access them. Services enable a loose coupling between dependent Pods. Although Pods each have a unique IP address, those IPs are not exposed outside the cluster without a Service. Services allow your applications to receive traffic.

## Kubectl

You can get more information about your cluster using kubectl:

```sh
$ kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /home/adrian/.minikube/ca.crt
    server: https://192.168.42.232:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /home/adrian/.minikube/apiserver.crt
    client-key: /home/adrian/.minikube/apiserver.key
```

The next thing you probably want to do is create a Deployment:

```bash
$ kubectl run echo-server --image=gcr.io/google_containers/echoserver:1.4 --port=8080
deployment "echo-server" created
```

This command will create a new Deployment that consists of running the **echoserver:1.4** image. We have given the name **echo-server** to this deploy. The &#8211;port modifier serves to indicate which port we want this container to expose. In this case it exposes 8080 because the service inside the container runs on that port.

We can see that the Pod is running with this command:

```bash
$ kubectl get pod
NAME                           READY     STATUS    RESTARTS   AGE
echo-server-4263713870-mbt9c   1/1       Running   0          4s
```

But even though we are now running a container that exposes port 8080, it is not really available to us yet (because the container is running inside Minikube). We can verify this by asking minikube to give us the URL of our service:

```
minikube service echo-server --url
Error opening service: Could not find finalized endpoint being pointed to by echo-server: Error validating service: Error getting service echo-server: services "echo-server" not found
```

We can fix this issue with this command:

```bash
$ kubectl expose deployment echo-server --type=NodePort
service "echo-server" exposed
```

This command will make your Deployment publicly available. The most important thing to notice is _&#8211;type=NodePort_, which tells Kubernetes how we want to expose the Deploy. The possible type values are: ClusterIP, NodePort or LoadBalancer.

**ClusterIP** &#8211; Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster. This is the default value.

**NodePort** &#8211; Exposes the service on each Node’s IP at a static port (the NodePort). A ClusterIP service, to which the NodePort service will route, is automatically created. You’ll be able to contact the NodePort service, from outside the cluster, by requesting <NodeIP>:<NodePort>.

**LoadBalancer** &#8211; Exposes the service externally using a cloud provider’s load balancer. NodePort and ClusterIP services, to which the external load balancer will route, are automatically created.

Now we can ask minikube for the URL:

```bash
$ minikube service echo-server --url
http://192.168.99.100:31714
```

And finally curl the service:

```bash
$ curl $(minikube service echo-server --url)
CLIENT VALUES:
client_address=172.17.0.1
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://192.168.99.100:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=192.168.99.100:31714
user-agent=curl/7.43.0
BODY:
-no body in request-
```

## Services

The above definition mentions that services allow applications to receive traffic. Interestingly I already presented a way to access an application running in the cluster:

```
kubectl expose deployment echo-server --type=NodePort
```

Although I didn&#8217;t mention it before, this command is actually creating a service:

```bash
$ kubectl get services
NAME          CLUSTER-IP   EXTERNAL-IP   PORT(S)          AGE
echo-server   10.0.0.181   <nodes>       8080:30314/TCP   55m
kubernetes    10.0.0.1     <none>        443/TCP          134d
```

We can get more information about the service using describe:

```bash
$ kubectl describe services/echo-server
Name:           echo-server
Namespace:      default
Labels:         run=echo-server
Selector:       run=echo-server
Type:           NodePort
IP:         10.0.0.64
Port:           <unset> 8080/TCP
NodePort:       <unset> 31786/TCP
Endpoints:      172.17.0.2:8080
Session Affinity:   None
No events.
```

If I was to delete the service:

```
kubectl delete service echo-server
```

We wouldn&#8217;t be able to access the application anymore:

```
minikube service echo-server --url
Error opening service: Could not find finalized endpoint being pointed to by echo-server: Error validating service: Error getting service echo-server: services "echo-server" not found
```

Now that we know a service is what exposes the application, the error message also becomes easier to understand.

## Managing deployments

We have already created a deployment using this command:

```
kubectl run echo-server --image=gcr.io/google_containers/echoserver:1.4 --port=8080
```

This command did a few things:

  * Searched for a suitable node where an instance of the application could be run (we have only 1 available node in the current configuration)
  * Scheduled the application to run on that Node
  * Configured the cluster to reschedule the instance on a new Node when needed
  * Set desired number of instances of this application to 1 (The scheduler will make sure there is always one instance of the application running)

In this section I&#8217;m going to cover some other things that can be done with deployments.

One common thing you might want to do with your deployment is have more instances of the application running. You can do this using the scale command:

```
kubectl scale deployments/echo-server --replicas=3
```

You can now see that the deployment has 3 replicas running:

```bash
$ kubectl get deployments
NAME          DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
echo-server   3         3         3            3           134d
```

And new pods were created:

```bash
$ kubectl get pods
NAME                           READY     STATUS    RESTARTS   AGE
echo-server-4263713870-c2thd   1/1       Running   0          36s
echo-server-4263713870-jpl9j   1/1       Running   0          36s
echo-server-4263713870-lzzt9   1/1       Running   1          134d
```

You can also scale down if necessary:

```
kubectl scale deployments/echo-server --replicas=1
```

Another common scenario for web applications is performing rolling updates. To perform an update we need to know the new version of the image we want our deployment to be running:

```
kubectl set image deployments/echo-server echo-server=gcr.io/google_containers/echoserver:1.6
```

Kubernetes will then 1 by 1 update all your pods to the new version. You can verify the status of the update with the describe command:

```
kubectl describe pods
```

For the example above there should be a line like this one:

```
Image:      gcr.io/google_containers/echoserver:1.6
```

For each one of the pods.

## Conclusion

This post shows the most basic uses of Kubernetes. Most importantly, we now understand the vocabulary that will allow us to dive deeper into the documentation and other articles in the subject. There are a lot of questions left unanswered that I&#8217;m going to look into in future posts.
