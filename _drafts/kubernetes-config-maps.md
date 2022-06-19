---
title: Kubernetes ConfigMaps
author: adrian.ancona
layout: post
# date: 2022-06-15
# permalink: /2022/06/understanding-and-using-istio-gateways
tags:
  - architecture
  - automation
  - docker
---

It's common for applications to requiere some kind of configuration. These configurations make it easy to change settings depending on the environment where the application is running.

For example, we might want to connect to a back-end server when running in a testing environment, but to a different one when running in production. An application might read these settings from environment variables, configuration files, or other means.

`ConfigMaps` are a way to make configurations available to pods so they can be used by our applications.

## Using ConfigMaps

From here on, I assume you have a Kubernetes cluster up and you know how to operate on Kubernetes objects using Yaml configurations. If you need a refresher on any of those things, you can take a look at these articles:

- [Running a local Kubenetes cluster with Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [Introduction to Kubenetes](https://ncona.com/2021/11/introduction-to-kubernetes)
- [Managing Kubernetes Objects With Yaml Configurations](https://ncona.com/2021/12/managing-kubernetes-objects-with-yaml-configurations)

Like `Deployment` and `Service`, [ConfigMaps are part of the Kubernetes api](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#configmap-v1-core). This means they can be managed the same way we manage deployments and services.

In this article I'm going to only show the declarative API (using Yaml configufation files), but the imperative API can also be used.

Let's create a simple `ConfiMap` Yaml file:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-app-configmap
data:
  backend-service: the.backend.server
```

The most important part is the information inside `data`. In the example above we set a single key-value pair, but we could have set as many as we wanted (To a maximum of 1MB at the time of this writing):

```yaml
backend-service: the.backend.server
```

The next step is to decide how we want to make this information available to our application. We have 4 options:

- Environment variables
- File
- Container command and arguments
- Kubernetes API

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
        name: ["sleep", "99999"]
        env:
          - name: BACKEND_ENDPOINT
            valueFrom:
              configMapKeyRef:
                name: test-app-configmap
                key: backend-service
```

To verify it's working, let's start by creating the deployment in our cluster:

```sh
```















https://kubernetes.io/docs/concepts/configuration/configmap/
https://kubernetes.io/docs/concepts/configuration/secret/
