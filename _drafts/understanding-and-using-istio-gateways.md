---
title: Understanding and using Istio Gateways
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

In a previous article I wrote an [introduction to Kubernetes networking with istio](/2022/02/kubernetes-networking-with-istio) where we use an Istio Gateway to make an application accessible from the internet. The problem with that article is that I showed an example, but I didn't explain what was happening. In this article we are going to take a closer look at Istio Gateway.

## Istio Gateway

An `Istio Gateway` is a load balancer that is accessible from the Internet and will route requests to Istio Proxies.

To understand this better, let's take a closer look to the application we ran in [Kubernetes networking with istio](/2022/02/kubernetes-networking-with-istio). If we look at the Gateway configuration, we will find:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: bookinfo-gateway
spec:
  selector:
    istio: ingressgateway # use istio default controller
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
```

Probably the most important and confusing part of this configuration is the `selector`:

```yaml
selector:
  istio: ingressgateway # use istio default controller
```

[The documentation says](https://istio.io/latest/docs/reference/config/networking/gateway/#Gateway): `One or more labels that indicate a specific set of pods/VMs on which this gateway configuration should be applied`. For me, this is not very clear, so let's untangle it.

When we create a pod, we can assign it labels, for example:

```yaml
...
metadata:
  name: details
  labels:
    app: details
    service: details
...
```

These labels can be used as selectors too. For example, to match all pods that have an `app` label set to `details`, I can use this selector:

```yaml
selector:
  app: details
```

If we want to be more specific, we could use more than one label and we would only be selecting those pods that have all the labels we specify.

So far we know how to select pods, but what does it mean to apply a gateway to those pods? It basically means that requests intended to pods that match those tags are going to be sent to the Gateway instead of being sent to the pod.

This leads us to the selector used in the example:

```yaml
selector:
  istio: ingressgateway # use istio default controller
```

How do I know which pods match that selector? For that, we can use this command (Note that we use `=` instead of `:` in the filter):

```
kubectl get pods -l 'istio=ingressgateway'
```

If we run that command in our example Istio cluster we will get nothing back. Why!? because this actually matches an istio control plane pod, which lives in a different namespace. To find the actual pod, we need to use this command:

```
kubectl get pods -l 'istio=ingressgateway' --namespace istio-system
```

When I ran that command, I got this as a result:

```
NAME                                    READY   STATUS    RESTARTS   AGE
istio-ingressgateway-668cb7dfd7-m56qc   1/1     Running   0          55m
```

This pod is created by Istio automatically when it's installed to on a Kubernetes cluster. If we describe this pod, we will see that this pod is running `istio/proxyv2`:

```
kubectl --namespace istio-system describe pod/istio-ingressgateway-668cb7dfd7-m56qc

...
Containers:
  istio-proxy:
    Container ID:  containerd://1974a8fb7254ed83120a0f4c022f76a17c7fbe62c9bc6bee094efdf60638d0e9
    Image:         docker.io/istio/proxyv2:1.14.0
...
```

Which is basically [Envoy](https://istio.io/latest/docs/ops/deployment/architecture/#envoy). This pod also has a service associated to it:

```
kubectl -n istio-system get svc istio-ingressgateway

NAME                   TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)                                                                      AGE
istio-ingressgateway   LoadBalancer   10.32.6.210   104.154.47.222   15021:30392/TCP,80:32568/TCP,443:31924/TCP,31400:30545/TCP,15443:30946/TCP   132m
```

We can see that the type of this service is `LoadBalancer`, which means [a load balancer from our cloud provider](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer) is going to be created.

This explains how traffic from the internet gets to the `istio-proxy`, but it's not yet clear what the `Gateway` is doing.

The `Gateway` basically tells Istio: Whenever this `istio-proxy` receives an http request on port 80, use the Gateway to handle it.

So, how will our Gateway handle it? This is configured with a different configuration:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bookinfo
spec:
  hosts:
  - "*"
  gateways:
  - bookinfo-gateway
  http:
  - match:
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    route:
    - destination:
        host: productpage
        port:
          number: 9080
```

We can see in the spec that this `VirtualService` applies to our Gateway:

```yaml
gateways:
- bookinfo-gateway
```

We can also see that it will route some requests (specified by the match rules) to the `productpage` service at port `9080`.

When we open `http://104.154.47.222/productpage` in the browser we will first see the request arrive at our proxy:

```
[2022-06-09T02:30:34.551Z] "GET /productpage HTTP/1.1" 200 - via_upstream - "-" 0 5293 412 411 "10.28.0.1" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36" "15eed29f-3288-956a-bba5-3f7dc763d3c4" "104.154.47.222" "10.28.0.18:9080" outbound|9080||productpage.default.svc.cluster.local 10.28.0.12:38672 10.28.0.12:8080 10.28.0.1:10097 - -
```

And then we'll see it at the `productpage` pod:

```
INFO:werkzeug:::ffff:127.0.0.6 - - [09/Jun/2022 02:30:34] "GET /productpage HTTP/1.1" 200 -
```

If submit a request for a route that is not configured in our `VirtualService` (for example: `http://104.154.47.222/abc`), the request will be received by our proxy, but it won't be directed to any backend:

```
[2022-06-09T02:39:01.400Z] "GET /asdf HTTP/1.1" 404 NR route_not_found - "-" 0 0 0 - "10.28.0.1" "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36" "084d5dfb-4bc0-9b35-93c5-12c53d4b338f" "104.154.47.222" "-" - - 10.28.0.12:8080 10.28.0.1:1745 - -
```

## Configuring an internal Gateway

Now that understand how an external gateway works, it shouldn't be very hard to create an internal gateway.

There are two main differences between the external gateway from the previous section and an internal gateway that we'll be creating here:
- We don't need an external load balancer
- We need to create our own istio-proxy

To create an istio-proxy, we need a template like this one:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: internal-istio-proxy
  labels:
    app: internal-istio-proxy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: internal-istio-proxy
  template:
    metadata:
      labels:
        app: internal-istio-proxy
    spec:
      containers:
      - name: istio-proxy
        image: docker.io/istio/proxyv2:1.14.0
```

This will run single `istio-proxy` named `internal-istio-proxy`. To make it easy to discover, we also need to create a service for it:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: internal-istio-proxy
  labels:
    app: internal-istio-proxy
    service: internal-istio-proxy
spec:
  ports:
  - port: 80
    name: http
  selector:
    app: internal-istio-proxy
```

If we deploy this service into our cluster:

```
kubectl apply -f internal-istio-proxy.yaml
```

We'll see our pod and a service with an IP address assigned to it:

```
kubectl get pods -l 'app=internal-istio-proxy'

NAME                                    READY   STATUS    RESTARTS   AGE
internal-istio-proxy-5744dcdf54-jdsj7   1/1     Running   0          10m


kubectl get svc internal-istio-proxy

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
internal-istio-proxy   ClusterIP   10.32.13.107   <none>        80/TCP    2m12s
```

At this point we can send requests to our proxy, but since it's not configured to do anything, we'll just get an error. To test this we can get into a pod in our cluster:

```
kubectl exec -it internal-istio-proxy-5744dcdf54-jdsj7 -- sh
```

And use curl to send a request:

```
curl 10.32.13.107/hello
upstream connect error or disconnect/reset before headers. reset reason: connection failure, transport failure reason: delayed connect error: 111$ 
```

We can confirm that te request was actually received by our proxy by loking at the logs:

```
kubectl logs pod/internal-istio-proxy-5744dcdf54-jdsj7 | tail

...

[2022-06-09T16:06:06.942Z] "GET /hello HTTP/1.1" 503 UF upstream_reset_before_response_started{connection_failure,delayed_connect_error:_111} - "-" 0 145 0 - "-" "curl/7.68.0" "ffc1de9a-c7dd-9e0f-b62c-1c12b7a830ff" "10.32.13.107" "10.28.0.19:80" inbound|80|| - 10.28.0.19:80 10.28.0.1:9347 - default
```

For our proxy to be functional we need to configure it to forward requests to a back-end. We will need a `Gateway` and a `VirtualService` for that:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: internal-istio-proxy-gateway
spec:
  selector:
    app: internal-istio-proxy
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: internal-bookinfo
spec:
  hosts:
  - "*"
  gateways:
  - internal-istio-proxy-gateway
  http:
  - match:
    - uri:
        exact: /productpage
    route:
    - destination:
        host: productpage
        port:
          number: 9080
```

curl -H "Host: abc.com" 10.32.12.150/productpage
