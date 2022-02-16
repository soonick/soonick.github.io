---
title: Kubernetes networking with Istio
author: adrian.ancona
layout: post
date: 2022-02-16
permalink: /2022/02/kubernetes-networking-with-istio
tags:
  - architecture
  - automation
  - docker
  - networking
---

A few months ago I wrote an [Introduction to Kubernetes](https://ncona.com/2021/11/introduction-to-kubernetes). In that article I created a `service` to achive communication between containers. This `service` acts as a load balancer that redirects requests to pods that are part of a `deployment`. We communicate with this load balancer via an IP that is assigned to it.

A service that needs to communicate with another service can query Kubernetes to `discover` the IP address for the load balancer and use that IP address for communication. This is does the job, but there are some things that are not possible with this configuration that we get from Istio.

<!--more-->

## What is Istio?

Istio is described as a `Service Mesh`, so let's start by defining what this is.

A Service Mesh is a piece of infrastructure that helps achieve communication between different services in a Service Oriented Architecture (Or Micro-Services Architecture if you prefer that term). Some of the features that a Service Mesh provides are:

- Security
  - Allows us to restrict which services can talk to which other services
  - Allows us to configure TLS between services
- Observability
  - Allows us to collect information about network traffic (Requests sent and received from a service, etc.)
- Traffic splitting
  - Allows us to split traffic between different services (can be used for canary testing)
- Reliability
  - Allows us to configure retry logic for requests
  - Allows us to configure backoff and circuit breakers

A Service Mesh usually has two parts:

- `Data Plane` - A proxy that is usually co-located with our services (One proxy for each pod). All network communication is done through this proxy
- `Control Plane` - A bunch of services deployed inside our cluster. They provide an API that can be used to configure the network. It communicates with the different proxies and instructs them how to behave

Now that we know what a Service Mesh is, it's easy to define Istio. It's an implementation of a Service Mesh. Istio uses `Envoy` as its proxy / data plane. The Control Plane is called `Istiod`.

## Getting started

To start playing with Istio we will need a Kubernetes cluster. If you don't already have one, you can follow my [introduction to Kubernetes](https://ncona.com/2021/11/introduction-to-kubernetes) to learn how to set one up in Google Cloud.

We start by getting the Istio CLI. Execute the following command to download and extract the latest version of Istio in the current folder:

```
curl -L https://istio.io/downloadIstio | sh -
```

This command will create a folder (e.g. `istio-1.13.0`). We need to add the bin folder to our path. For example:

```
export PATH=$HOME/bin/istio-1.13.0/bin:$PATH
```

Now that we have `istioctl`, we can use it to install Istio into our cluster.

To install Istio we need our `gcloud` cli to be configured for an account with `Kubernetes Engine Admin` permissions. We can see which account is currently configured with this command:

```
gcloud auth list
```

To figure out which roles are assigned to an account we can use this command:

```
gcloud projects get-iam-policy <GCLOUD PROJECT ID>  \
    --flatten="bindings[].members" \
    --format="table(bindings.role)" \
    --filter="bindings.members:<SERVICE ACCOUNT>"
```

We will also need to have `kubectl` configured with the cluster where we want to install Istio. To see our currently configured cluster we can use the following command:

```
kubectl config current-context
```

This is the cluster where Istio will be installed. To continue with the installation we can use this command:

```
istioctl install --set profile=demo -y
```

If everything goes well, we should see a message similar to this one:

```
✔ Istio core installed
✔ Istiod installed
✔ Ingress gateways installed
✔ Egress gateways installed
✔ Installation complete                                                                                                                                 Making this installation the default for injection and validation.

Thank you for installing Istio 1.13.  Please take a few minutes to tell us about your install/upgrade experience!  https://forms.gle/pzWZpAvMVBecaQ9h9
```

Next, we want to instruct Istio to automatically install `Envoy` as a sidecar proxy when we deploy applications. To do this, we can use this command:

```
kubectl label namespace default istio-injection=enabled
```

At this point we have Istio installed in our cluster, and it's configured to add Envoy to all applications we deploy.

We can test our installation by deploying one of the sample applications that comes in the Istio package we downloaded earlier:

```
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
```

We can see the pods deployed by this application with this command:

```
kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-79f774bdb9-mwgbd       2/2     Running   0          17m
productpage-v1-6b746f74dc-lmh4p   2/2     Running   0          17m
ratings-v1-b6994bb9-bfhdg         2/2     Running   0          17m
reviews-v1-545db77b95-9nlj7       2/2     Running   0          17m
reviews-v2-7bf8c9648f-w84zp       2/2     Running   0          17m
reviews-v3-84779c7bbc-4scpw       2/2     Running   0          17m
```

If Istio was configured correctly, each pod should also have an istio proxy installed (`Envoy`). To verify the sidecar is actually there we need to look into the pod details:

```
kubectl describe pod reviews-v3-84779c7bbc-4scpw
```

The sample application also creates a few service:

```
kubectl get services
NAME          TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
details       ClusterIP   10.32.14.44   <none>        9080/TCP   20m
kubernetes    ClusterIP   10.32.0.1     <none>        443/TCP    35m
productpage   ClusterIP   10.32.3.78    <none>        9080/TCP   20m
ratings       ClusterIP   10.32.1.43    <none>        9080/TCP   20m
reviews       ClusterIP   10.32.4.172   <none>        9080/TCP   20m
```

As mentioned in the beginning of this article, services can be used to communicate with services inside the cluster.

## Opening a service to the world

Now that we have a Kubernetes cluster with Istio, we can make a service accessible to the outside world by using the `gateway` it provides:

```
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
```

This creates a load balancer that is accessible to the outside world:

```
kubectl get svc istio-ingressgateway -n istio-system
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                                                                      AGE
istio-ingressgateway   LoadBalancer   10.32.10.237   34.70.45.76   15021:31163/TCP,80:31311/TCP,443:30366/TCP,31400:32387/TCP,15443:32092/TCP   40m
```

To verify this worked we can open this URL in the browser: `http://<EXTERNAL-IP>/productpage`.

## How are sidecars injected?

We achieved a lot in this article, but there were a lot that I didn't quite explain. One of them is: How did Istio make it so the Envoy is automatically included in all pods?

The answer to that question is [Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/).

Admission Controllers allow us to intercept requests to the Kubernetes API and execute validations or mutations to these requests. In the case of Istio, it uses an Admission Controller that comes installed in most default Kubernetes clusters: `MutatingAdmissionWebhook`.

For each request to Kubernetes API, the Admission Controller calls all configured webhooks; those webhooks then modify the request, by for example, adding extra containers to the pod, like Istio does.

## Where is Istio Control Plane (istiod)?

Previously in the article, we listed all the pods in the cluster and we saw only the pods for our application:

```
kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-79f774bdb9-mwgbd       2/2     Running   0          17m
productpage-v1-6b746f74dc-lmh4p   2/2     Running   0          17m
ratings-v1-b6994bb9-bfhdg         2/2     Running   0          17m
reviews-v1-545db77b95-9nlj7       2/2     Running   0          17m
reviews-v2-7bf8c9648f-w84zp       2/2     Running   0          17m
reviews-v3-84779c7bbc-4scpw       2/2     Running   0          17m
```

This made me wonder: where is `istiod` running? It turns out, `istiod` is running in the cluster, just not in the default namespace.

We can see all the namespaces in our cluster with this command:

```
kubectl get namespaces
NAME              STATUS   AGE
default           Active   114m
istio-system      Active   111m
kube-node-lease   Active   114m
kube-public       Active   114m
kube-system       Active   114m
```

If we inspect the `istio-system` namespace, we'll see `istiod` running there:

```
kubectl get pods --namespace istio-system
NAME                                   READY   STATUS    RESTARTS   AGE
istio-egressgateway-6cf5fb4756-qfdnd   1/1     Running   0          110m
istio-ingressgateway-dc9c8f588-4587s   1/1     Running   0          110m
istiod-7586c7dfd8-mjg9n                1/1     Running   0          111m
```

## Conclusion

In this article we learned what is Istio, why would we want to use it, and how to get started with it.

We didn't cover some of the most interesting features, like mutual TLS and security, but we got a foundation so we can explore those features in future articles.
