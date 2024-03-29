---
title: Managing Kubernetes Applications with Helm
author: adrian.ancona
layout: post
date: 2021-12-08
permalink: /2021/12/managing-kubernetes-applications-with-helm
tags:
  - automation
  - docker
  - linux
---

Helm is a package manager for Charts.

You might already be familiar with package managers like the ones used for Linux distributions (apt, yum, etc.). In Linux, a package manager takes care of installing, updating, configuring and removing packages from a machine. Helm does something similar, but with Kubernetes applications.

`Charts` are a set of files that describe a Kubernetes application. These files must be laid out in a folder structure that follows a convention that looks like this:

```
.
├── Chart.yaml
├── templates
│   └── application.yaml
└── values.yaml
```

The `Chart.yaml` contains some information about the Chart. It looks something like this:

<!--more-->

```yaml
apiVersion: v2
name: example-helm
description: A Helm chart for an example application

type: application
version: 0.1.0

appVersion: "1.16.0"
```

`values.yaml` contains values that are combined with `templates` to generate valid Kubernetes manifest files. It can look something like this:

```yaml
replicaCount: 1
```

The `templates` directory contains files that will be processed by Helm's template engine to generate Kubernetes files. Template files use [Go's templating language](https://pkg.go.dev/text/template), extended with [sprig](https://github.com/Masterminds/sprig) and [other specialized functions](https://helm.sh/docs/howto/charts_tips_and_tricks/).

We could have a file named `application.yaml` inside our `templates` folder with something like this:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-server-deployment
spec:
  selector:
    matchLabels:
      app: echo-server-deployment
  {% raw %}replicas: {{ .Values.replicaCount }}{% endraw %}
  template:
    metadata:
      labels:
        app: echo-server-deployment
    spec:
      containers:
      - image: ealen/echo-server
        name: echo-server
```

The file is a pretty standard Kubernetes manifest file, except for the `{% raw %}replicas: {{ .Values.replicaCount }}{% endraw %}`. This line will replace the template part with the `replicaCount` from our `values.yaml` file.

Before we can use our Chart, we need the Helm CLI.

## Helm CLI

The Helm CLI is the brains of Helm. It takes care of parsing, publishing and deploying Charts.

The [Helm Installation Guide](https://helm.sh/docs/intro/install/) has the most up-to-date instructions for installing the Helm CLI. At the time of this writing, this command is enough:

```sh
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

We can verify the install completed correctly with this command:

```sh
helm version
```

## Working with Charts

Now that we have the Helm CLI installed, we can start playing with Charts. We can bootstrap a Chart with this command:

```sh
helm create test-chart
```

This creates a folder named `test-chart` with some files we need to create Chart. We can check if the Chart has any problems by changing into the Chart folder and running this command:

```sh
helm lint
```

We can create a very simple Chart by adding this content to `Chart.yaml`:

```yaml
apiVersion: v2
name: test-chart
description: A tiny test application
type: application
version: 0.1.0
appVersion: "1"
```

Set `values.yaml` to:

```yaml
replicaCount: 1
```

And create a `templates/application.yaml` file with this content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-server-deployment
spec:
  selector:
    matchLabels:
      app: echo-server-deployment
  {% raw %}replicas: {{ .Values.replicaCount }}{% endraw %}
  template:
    metadata:
      labels:
        app: echo-server-deployment
    spec:
      containers:
      - image: ealen/echo-server
        name: echo-server
```

We can delete everything else.

Now that we have our Chart, we can inspect how the compiled templates will look like:

```sh
helm template .

---
# Source: test-chart/templates/application.yaml
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

We can see that replicas is set to `1` as specified in `values.yaml`.

If we have `kubectl` installed and configured, we can install our Chart to our cluster:

```sh
helm install . --generate-name
```

We can see all our helm deployments with:

```sh
helm list

NAME            	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART           	APP VERSION
chart-1637726261	default  	1       	2021-11-23 22:57:48.127492259 -0500 EST	deployed	test-chart-0.1.0	1
```

Let's update the number of replicas in `values.yaml`:

```yaml
replicaCount: 2
```

We can now update our Chart deployment:

```sh
helm upgrade chart-1637726261 .
```

And we'll see that our Chart now has 2 replicas:

```sh
helm get manifest chart-1637726261

---
# Source: test-chart/templates/application.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-server-deployment
spec:
  selector:
    matchLabels:
      app: echo-server-deployment
  replicas: 2
  template:
    metadata:
      labels:
        app: echo-server-deployment
    spec:
      containers:
      - image: ealen/echo-server
        name: echo-server
```

Finally, we can delete our Chart with this command:

```sh
helm uninstall chart-1637726261
```

## Working with repositories

Besides using our own Charts, there are repositories where we can find open source Charts that are ready to use.

We can use the Helm CLI to search for available Charts in `ArtifactHub`. Let's say we are looking for a Chart for a node application:

```sh
helm search hub node -o yaml

- app_version: 16.13.0
  description: Event-driven I/O server-side JavaScript environment based on V8
  url: https://artifacthub.io/packages/helm/bitnami-aks/node
  version: 16.0.1
- app_version: 16.13.0
  description: Event-driven I/O server-side JavaScript environment based on V8
  url: https://artifacthub.io/packages/helm/bitnami/node
  version: 16.0.1
...
```

The output is a list of Charts that match the `node` keyword.

The URL included in each result is a link to the Chart in ArtifactHub. It can be used to learn more about the Chart and currently is the only way to know which repo a Chart is in.

`AftifactHub` is website that allows us to search multiple repositories for Charts. A `repository` is where the Chart is actually hosted.

If we go to `https://artifacthub.io/packages/helm/bitnami/node` we'll find an `INSTALL` button that will give us instructions to install the repo:

```
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Once our repo is installed, we can install the Chart in our cluster:

```sh
helm install bitnami/node --generate-name
```

The Chart will be installed, the same way our own Chart was installed. We can see the Chart using `helm list`:

```sh
helm list

NAME           	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART      	APP VERSION
node-1637284508	default  	1       	2021-11-18 20:15:20.849604214 -0500 EST	deployed	node-16.0.1	16.13.0
```

## Conclusion

In this article we learned how to create a simple Chart and consume Charts from a repository. While doing this we got familiar with the basic operations available in the `helm` CLI.
