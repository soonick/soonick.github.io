---
title: Kubernetes ConfigMaps
author: adrian.ancona
layout: post
date: 2022-07-13
permalink: /2022/07/kubernetes-configmaps
tags:
  - architecture
  - automation
  - docker
---

It's common for applications to require some kind of configuration. These configurations make it easy to change settings depending on the environment where the application is running.

For example, we might want to connect to a back-end server when running in a testing environment, but to a different one when running in production. An application might read these settings from environment variables, configuration files, or other means.

`ConfigMaps` are a way to make configurations available to pods so they can be used by our applications.

<!--more-->

## Using ConfigMaps

From here on, I assume you have a Kubernetes cluster up and you know how to operate on Kubernetes objects using Yaml configurations. If you need a refresher on any of those things, you can take a look at these articles:

- [Running a local Kubenetes cluster with Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [Introduction to Kubenetes](https://ncona.com/2021/11/introduction-to-kubernetes)
- [Managing Kubernetes Objects With Yaml Configurations](https://ncona.com/2021/12/managing-kubernetes-objects-with-yaml-configurations)

Like `Deployment` and `Service`, [ConfigMaps are part of the Kubernetes api](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#configmap-v1-core). This means they can be managed the same way we manage deployments and services.

In this article we are only going to use the declarative API (using Yaml configufation files), but the same things can be achieved with the imperative API.

A simple `ConfiMap` Yaml file looks like this:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-app-configmap
data:
  backend-service: the.backend.server
```

The most important section for us is the information inside `data`. In the example above we set a single key-value pair, but we could have set as many as we wanted (To a maximum of 1MB at the time of this writing):

```yaml
backend-service: the.backend.server
```

We have 4 options to make this configuration available to an application:

- Environment variables
- Files
- Container command and arguments
- Kubernetes API

### Environment variables

Let's create a deployment that consumes a value from a `ConfigMap` as an environment variable:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app-deployment
spec:
  selector:
    matchLabels:
      app: test-app-pod
  replicas: 1
  template:
    metadata:
      labels:
        app: test-app-pod
    spec:
      containers:
      - image: alpine
        name: test-app-container
        command: ["sleep", "99999"]
        env:
          - name: BACKEND_ENDPOINT
            valueFrom:
              configMapKeyRef:
                name: test-app-configmap
                key: backend-service
```

The important part is:

```yaml
valueFrom:
  configMapKeyRef:
    name: test-app-configmap
    key: backend-service
```

Here we specify that the value for the `BACKEND_ENDPOINT` variable will come form a ConfigMap named `test-app-configmap` in the key `backend-service`.

To create the ConfigMap in our cluster:

```sh
kubectl create -f config-map.yaml
```

The ConfigMap will then be visible in the output of this command:

```sh
kubectl get configmaps
```

We can see the actual contents of the ConfigMap with this command:

```sh
kubectl describe configmap/test-app-configmap
```

The output looks like this:

```yaml
Name:         test-app-configmap
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
backend-service:
----
the.backend.server

BinaryData
====

Events:  <none>
```

Now that the ConfigMap is ready, we can create the deployment that uses it:

```sh
kubectl create -f deployment.yaml
```

To verify the environment variable was set correctly, first we need the id of a pod, which we can get with:

```
kubectl get pods
```

Then we get a shell to the pod:

```sh
kubectl exec -it pod/<pod id> -- sh
```

From there we can echo the variable:

```sh
echo $BACKEND_ENDPOINT
```

## Files

Let's look at an example where the ConfigMap is mounted as a volume in the pod:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app-deployment-file
spec:
  selector:
    matchLabels:
      app: test-app-pod
  replicas: 1
  template:
    metadata:
      labels:
        app: test-app-pod
    spec:
      containers:
      - image: alpine
        name: test-app-container
        command: ["sleep", "99999"]
        volumeMounts:
          - name: config
            mountPath: "/my-configs"
            readOnly: true
      volumes:
        - name: config
          configMap:
            name: test-app-configmap
            items:
            - key: "backend-service"
              path: backend.file
```

There are two important parts we need to take a closer look at:

```yaml
volumes:
  - name: config
    configMap:
      name: test-app-configmap
      items:
      - key: "backend-service"
        path: backend.file
```

Here we create a volume named `config`. This volume will create files based on `ConfigMaps`. For the `ConfigMap` named `test-app-configmap` we are going to create a single file named `backend.file`. The content of this file will be the content of the key `backend-service`.

To make this volume available to pods, we need to mount it:

```yaml
volumeMounts:
  - name: config
    mountPath: "/my-configs"
    readOnly: true
```

Here we specify the name of the volume we want to mount (`config`, as defined in the `volumes` section) and where we want to mount it: `/my-configs`.

We can create the deployment and get a terminal to a pod with the same steps shown in the previous section. We will be able to find a file at `/my-configs/backend.file` that contains `the.backend.server`.

## Conclusion

We can now use ConfigMaps to pass configuration to our pods. We only covered how to pass them as environment variables and files because those are the most common use cases.

If you want to see the full examples in action, you can find them at: [kubernetes-config-maps](https://github.com/soonick/ncona-code-samples/tree/master/kubernetes-config-maps)
