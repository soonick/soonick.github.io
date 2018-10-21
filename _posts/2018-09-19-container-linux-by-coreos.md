---
id: 4653
title: Container Linux by CoreOS
date: 2018-09-19T18:23:04+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4653
permalink: /2018/09/container-linux-by-coreos/
tags:
  - docker
  - linux
---
It might be a little confusing, but CoreOS is not actually the name of an operating system. CoreOS is the name of the company that develops a set of tools for the container ecosystem. The name of the operating system that runs on each of the hosts in a CoreOS cluster is [Container Linux](https://coreos.com/os/docs/latest). Realizing this made it a lot easier to find the information I was looking for while trying to understand how all the tools work together.

As I mentioned before, Container Linux is a Linux distribution. The selling point of this distribution is that it contains the bare minimum for it to operate. It is designed to run applications inside of containers, so it doesn&#8217;t provide things that other Linux distributions provide (Browser, Office suite, GUI, etc&#8230;). Stripping the things that are not needed saves some disk space and probably some memory and CPU cycles (Assuming some daemons included in most distributions will not be running). Is it worth to change the distribution we are used to using just for a little more resources? Probably not, but lets talk about the things we would get if we decide to do it.

  * **Automatic software updates** &#8211; In other distributions, the system remains the same until a system administrator updates it. Linux container constantly updates the underlying system (including the kernel) with security and stability patches.
  * **Cluster configutaion** &#8211; Allows you to declaratively configure (partition disks, add users, etc&#8230;) all the machines in your cluster.
  * **Kubernetes** &#8211; CoreOs makes it easy to build a Kubernetes cluster in most cloud providers.

<!--more-->

Container Linux is just a part of the puzzle, but it changes the way we think about managing clusters of machines. With Container Linux, all machines in the cluster work together to achieve whatever tasks they were assigned (running different containers in different configurations).

## Running Container Linux

Most cloud platforms allow you to start hosts with Container Linux installed on them with a few clicks. If you want to run it in virtual machines or bare metal, there are [guides in CoreOS docs to start from scratch](https://coreos.com/os/docs/latest/).

Since I&#8217;ve been playing with Terraform, I&#8217;m going to use it for creating my instances. If you are not familiar with Terraform, you can read my [introduction to Terraform](https://ncona.com/2018/05/terraform/) post and [getting familiar with Terraform](https://ncona.com/2018/07/getting-familiar-with-terraform/).

To create a single CoreOS instance I used a configuration like this one:

```groovy
// Configure Google Cloud
provider "google" {
  credentials = "${file("credentials.json")}"
  project = "ncona-17504"
  version = "~> 1.13"
}

// CoreOS machines
resource "google_compute_instance" "us-central1-c--f1-micro" {
  name = "us-central1-c--f1-micro"
  machine_type = "f1-micro"
  zone = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "coreos-stable"
    }
  }

  network_interface {
    network = "default"
    access_config = {}
  }
}
```

After applying this configuration, the instance will be created and available. This instance is not very special, you can probably SSH to it, and run some commands on it, but nothing too exciting.

## Provisioning

One of the selling points of CoreOS is how they make it easy to provision machines for creating container management clusters. I&#8217;m not going to go into that much depth in this post, but I&#8217;ll show some simple provisioning examples.

CoreOS uses a provisioning system called _Ignition_. What it allows to do is very basic: configure partitions, create files and create users. This might not sound like much, but can be used to achieve most things.

Ignition config files are usually generated from Container Linux config files. This is a Container Linux config file that adds a user to a CoreOS instance:

```yml
passwd:
  users:
    - name: adrian
      ssh_authorized_keys:
       - my_public_key
      groups: [sudo, docker]
```

This file can be transformed to an Ignition file using their [config transpiler (ct)](https://github.com/coreos/container-linux-config-transpiler/releases).

```
ct --in-file config.yml --out-file config.ign
```

The resulting ignition file looks something like this:

```json
{
  "ignition": {
    "config": {},
    "timeouts": {},
    "version": "2.1.0"
  },
  "networkd": {},
  "passwd": {
    "users": [
      {
        "groups":["sudo","docker"],
        "name": "adrian",
        "sshAuthorizedKeys": [
          "my_public_key"
        ]
      }
    ]
  },
  "storage": {},
  "systemd": {}
}
```

The way to tell the CoreOS instance to use this ignition file is by using the metadata field when creating the instance. It would be something like this in Terraform:

```groovy
metadata {
  user-data = "${file("provisioning/ignition/config.ign")}"
}
```

Adding this to your instance would create the specified user and allow SSH access with the given key.
