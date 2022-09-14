---
title: Kubernetes Operator Patern - Custom Resources and Controllers
author: adrian.ancona
layout: post
# date: 2022-06-15
# permalink: /2022/06/understanding-and-using-istio-gateways
tags:
  - architecture
  - automation
  - docker
---

In a previous article I wrote about [managing Kubernetes objects using yaml configuration files](/2021/12/managing-kubernetes-objects-with-yaml-configurations). In this article we're going to learn how we can create our own types of "objects" and why we would want to do this.

## Custom Resources and Controllers

There are two concepts we need to understand in order to implement the operator pattern successfully: Custom Resources and Controllers.

Kubernetes comes with a few built-in objects that can be managed through its API. Examples of these objects are: `Deployment`, `Service`, etc.

We can define objects with yaml. For example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-server-deployment
...
```

And use `kubectl` to create or modify the object:

```
kubectl create -f my-object.yaml
kubectl replace -f my-object.yaml
```

In the yaml definition above, the `kind` field is set to `Deployment`. With the operator pattern, we can define our own `kind` using CustomResourceDefinition (CRD) and manage that `kind` of objects with the help of controllers.

## CustomResourceDefinition (CRD)

We can use `CustomResourceDefintion` to define a `kind` of resources that can be managed the same way we manage built-in objects.

To define a `CRD` we use the `CustomResourceDefinition` kind:

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  # name must be in the form: <plural>.<group>
  name: myservices.company.me
spec:
  # group name to use for REST API: /apis/<group>/<version>
  group: company.me
  # list of versions supported by this CustomResourceDefinition
  versions:
    - name: v1
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                replicas:
                  type: integer
                image:
                  type: string
  scope: Cluster
  names:
    # plural name to be used in the URL: /apis/<group>/<version>/<plural>
    plural: myservices
    # singular name to be used as an alias on the CLI and for display
    singular: myservice
    # kind is normally the CamelCased singular type. Your resource manifests use this.
    kind: MyService
    # shortNames allow shorter string to match your resource on the CLI
    shortNames:
    - ms
```

`CRDs` are basically containers for properties. In this case, our `CRD` can hold two properties `replicas` and `image`.

Later in this article, we are going to use these properties to create a service with the given `replicas` number, using the specified `image`. For now, this is just a schema for a way to store data.

To make our cluster aware of this Custom Resource we use:

```sh
kubectl apply -f my-service-crd.yaml
```

Once our cluster knows this resource, it can be managed similarly to how we manage built-in resources. Let's create a `MyService` to see it in action:

```yaml
apiVersion: "company.me/v1"
kind: MyService
metadata:
  name: my-service-with-crd
spec:
  replicas: 3
  image: ealen/echo-server
```

A few things to notice:

- `company.my/v1` - This matches the `group` and `name` specified in our `CRD`
- `MyService` - This matches the `kind` field in the `CRD`
- `spec` - Here is where we set the properties we defined in the `CRD`

Since our cluster already knows about `MyService`, we can create it as with other objects:

```sh
kubectl create -f my-service.yaml
```

We can also get all the instances of `MyService` that are currently running:

```sh
kubectl get myservices


NAME                  AGE
my-service-with-crd   58s
```

Or even look at more details for a specific instance:

```sh
kubectl describe myservice/my-service-with-crd


Name:         my-service-with-crd
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  company.me/v1
Kind:         MyService
Metadata:
  Creation Timestamp:  2022-07-04T18:26:54Z
  Generation:          1
  Managed Fields:
    API Version:  company.me/v1
    Fields Type:  FieldsV1
    fieldsV1:
      f:spec:
        .:
        f:image:
        f:replicas:
    Manager:         kubectl-create
    Operation:       Update
    Time:            2022-07-04T18:26:54Z
  Resource Version:  153281
  UID:               8190c9a8-f00a-448e-b78d-4577009675d7
Spec:
  Image:     ealen/echo-server
  Replicas:  3
Events:      <none>
```

We can also update the spec and perform the operations we use for other types of resources.

The question now is: What happens when we create an instance of a Custom Resource? And the answer is: nothing. Right now kubernetes is just acting as a place to save and manage this structured data. For `CRDs` to be really useful, we need Controllers.

## Controllers

Controllers are applications that use the Kubernetes API to monitor resources and apply changes to the state of the cluster.

Controllers are implemented using a [control loop pattern](https://kubernetes.io/docs/concepts/architecture/controller/). This means, the controller will constantly look at the `desired` state of a resource (The latest state of the spec), compare it with the `current` state of the resource and apply the necessary changes to get to the `desired` state.

This loop is repeated forever, constantly monitoring for changes and applying them when necessary.

We are going to create a very simple controller to illustrate how they work.

First of all, let's define what we want our controller to do:
- Get all the resources where `kind` is `MyService`
- For each of the resources:
  - ...

Controllers can be created in any programming language 





https://thenewstack.io/kubernetes-crds-what-they-are-and-why-they-are-useful/
https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/
https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/

Custom Resource -> CRD -> Aggregated API



Creating our own kind of objects allows us to automate and standardize parts of our infrastructure. For example, we could create a deployment like this one:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-server-deployment
spec:
  selector:
    matchLabels:
      app: echo-server-deployment
  replicas: 5
  minReadySeconds: 60
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 100%
  template:
    metadata:
      labels:
        app: echo-server-deployment
    spec:
      containers:
      - image: ealen/echo-server
        name: echo-server
```

If we look at the deployment policy, there are two interesting things:
- `minReadySeconds: 60` - New pods aren't considered ready unless they have been running for 60 seconds
- `maxSurge: 100%` - When updating the deployment we spin all the new replicas at the same time 

These two settings together basically mean that when updating the deployment there will be twice the number of pods as is normal for a period of 60 seconds.

Let's say we want to implement this policy for a few services in our company because we consider it a good practice. We could of course include the same policy in all our deployments, but we could also create a custom resource that always includes that policy.




https://github.com/rohanKanojia/podsetoperatorinjava
