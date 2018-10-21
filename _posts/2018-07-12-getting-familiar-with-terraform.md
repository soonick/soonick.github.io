---
id: 5101
title: Getting familiar with Terraform
date: 2018-07-12T03:26:48+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=5101
permalink: /2018/07/getting-familiar-with-terraform/
tags:
  - automation
  - linux
  - productivity
  - terraform
---
In a previous post I covered the [basics of Terraform](http://ncona.com/2018/05/terraform/). In this post I&#8217;m going to cover a few more things that I find necessary in most infrastructures I create.

## The machines

I&#8217;m going to start with a couple of machines:

```groovy
// Configure Google Cloud
provider "google" {
  credentials = "${file("credentials.json")}"
  project = "ncona-1504"
  version = "~> 1.13"
}

// Machines
resource "google_compute_instance" "us-central1-c--f1-micro--001" {
  name         = "us-central1-c--f1-micro--001"
  machine_type = "f1-micro"
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170815a"
    }
  }

  network_interface {
    network = "default"
  }
}

resource "google_compute_instance" "us-central1-c--f1-micro--002" {
  name         = "us-central1-c--f1-micro--002"
  machine_type = "f1-micro"
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170815a"
    }
  }

  network_interface {
    network = "default"
  }
}
```

<!--more-->

At this point, I can run _terraform apply_ and I will get my two machines.

## Avoid repetition

The example above works fine, but doing this for each machine that needs to be created would result in huge configurations for a large infrastructure. We can use some Terraform syntax magic to avoid repetition:

```groovy
// Configure Google Cloud
provider "google" {
  credentials = "${file("credentials.json")}"
  project = "ncona-1504"
  version = "~> 1.13"
}

// Machines
resource "google_compute_instance" "us-central1-c--f1-micro" {
  count = 2
  name = "us-central1-c--f1-micro--${format("%03d", count.index + 1)}"
  machine_type = "f1-micro"
  zone = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170815a"
    }
  }

  network_interface {
    network = "default"
  }
}
```

We used the _count_ parameter to specify how many copies of the resource we want to create. Then we used interpolation to give a different name to each of the instances: _us-central1-c&#8211;f1-micro&#8211;${format(&#8220;%03d&#8221;, count.index + 1)}_.

This changes the names of our machines, but makes our infrastructure more maintainable.

## SSH access

Most likely we will want to be able to access these machines via SSH for debugging or other purposes. Adding an access\_config parameter to the network\_interface will give us an external IP:

```groovy
// Configure Google Cloud
provider "google" {
  credentials = "${file("credentials.json")}"
  project = "ncona-1504"
  version = "~> 1.13"
}

// Machines
resource "google_compute_instance" "us-central1-c--f1-micro" {
  count = 2
  name = "us-central1-c--f1-micro--${format("%03d", count.index + 1)}"
  machine_type = "f1-micro"
  zone = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170815a"
    }
  }

  network_interface {
    network = "default"

    access_config = {
    }
  }
}
```

[<img src="/images/posts/ssh-access.png" />](/images/posts/ssh-access.png)

This is of course not enough to be able to SSH to our server. We also need to specify who can SSH to this machine. We can do this using the metadata attribute:

```groovy
variable "gc_ssh_user" {}
variable "gc_ssh_pub_key" {}

// Configure Google Cloud
provider "google" {
  credentials = "${file("credentials.json")}"
  project = "ncona-1504"
  version = "~> 1.13"
}

// Machines
resource "google_compute_instance" "us-central1-c--f1-micro" {
  count = 2
  name = "us-central1-c--f1-micro--${format("%03d", count.index + 1)}"
  machine_type = "f1-micro"
  zone = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170815a"
    }
  }

  network_interface {
    network = "default"

    access_config = {
    }
  }

  metadata {
    sshKeys = "${var.gc_ssh_user}:${var.gc_ssh_pub_key}"
  }
}
```

We created two variables so we don&#8217;t have to check-in our secrets to source control. We can store the secrets in a file called terraform.tfvars:

```groovy
gc_ssh_user = "theuser"
gc_ssh_pub_key = "<ssh public key>"
```

We can run _terraform apply_ and we will be able to SSH using: _ssh theuser@<the-ip-address>_

## Networking

Another important aspect of our infrastructure is the network. In a previous article I wrote a little about [how networking works in google cloud](http://ncona.com/2018/06/introduction-to-networking-in-google-cloud/).

Here I&#8217;m going to show how to create a network with a single subnet and a web server that will be listening on port 80.

To create the network and the subnet:

```groovy
// Configure the network
resource "google_compute_network" "testy-network" {
  name = "testy-network"
}

resource "google_compute_subnetwork" "testy-subnet" {
  name = "testy-subnet"
  region = "us-central1"
  ip_cidr_range = "10.0.0.0/24"
  network = "${google_compute_network.testy-network.self_link}"
}
```

The configuration above creates a network called **testy-network**. A subnet called **testy-subnet** is created inside this network with an IP range 10.0.0.0/24 in the **us-central1** region.

We can now create a machine in this subnet with port 80 open to the internet:

```groovy
variable "gc_ssh_user" {}
variable "gc_ssh_pub_key" {}

// Configure Google Cloud
provider "google" {
  credentials = "${file("credentials.json")}"
  project = "ncona-1504"
  version = "~> 1.13"
}

// Configure the network
resource "google_compute_network" "testy-network" {
  name = "testy-network"
}

resource "google_compute_subnetwork" "testy-subnet" {
  name = "testy-subnet"
  region = "us-central1"
  ip_cidr_range = "10.0.0.0/24"
  network = "${google_compute_network.testy-network.self_link}"
}

// Firewall rules for our web instances
resource "google_compute_firewall" "web-firewall" {
  name = "web-firewall"
  network = "${google_compute_network.testy-network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

  target_tags = ["web"]
}

// Web machine
resource "google_compute_instance" "us-central1-c--f1-micro--web" {
  name = "us-central1-c--f1-micro--web"
  machine_type = "f1-micro"
  zone = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170815a"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.testy-subnet.self_link}"
    address = "10.0.0.2"

    access_config = {
    }
  }

  tags = ["web"]

  metadata {
    sshKeys = "${var.gc_ssh_user}:${var.gc_ssh_pub_key}"
  }
}
```

We created a firewall rule in the network we just created. This rule allows traffic only on port 80 and 22 from anywhere in the world for all machines tagged &#8220;web&#8221;. We also created our web machine in the correct subnet and assigned a static IP address to this machine. Finally, we added the tag &#8220;web&#8221; to this machine so the firewall applies to it.

## Provisioning

A more advanced step in creating our infrastructure consists on provisioning our machines. Provisioning a machine consists of installing all the software or files that are necessary for it to do its job. There are many ways to do provisioning with different provisioners (chef, salt, etc&#8230;). In this article I&#8217;m only going to cover one of the simplest ones, the file provisioner.

The file provisioner can be used to copy a file from the machine running Terraform to the machine being created. For example, we could copy a specific **.bashrc** file to our machines to tune the shell. This is how we would do that:

```groovy
resource "google_compute_instance" "us-central1-c--f1-micro--web" {
  name = "us-central1-c--f1-micro--web"
  machine_type = "f1-micro"
  zone = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170815a"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.testy-subnet.self_link}"
    address = "10.0.0.2"

    access_config = {
    }
  }

  tags = ["web"]

  metadata {
    sshKeys = "${var.gc_ssh_user}:${var.gc_ssh_pub_key}"
  }

  provisioner "file" {
    source = "provisioning/file/.bashrc"
    destination = "/home/${var.gc_ssh_user}/.bashrc"

    connection {
      type = "ssh"
      user = "${var.gc_ssh_user}"
      private_key = "${file("~/.ssh/gcp")}"
    }
  }
}
```

We added a provisioner section to the resource. In this section we specify the local path of the file (source) and the destination in the machine we are creating. We also need to tell Terraform how it is going to connect to the machine so it can copy the file. In this case I chose to use the private SSH key that lives in my computer.

One thing to keep in mind is that the provisioner is only run when the machine is first created. If we modify a resource and add a provisioner, the provisioner won&#8217;t run.

We can have as many provisioner sections as needed.

## Conclusion

I covered a few steps that allows us to create basic but functional infrastructures. There is a lot that can be done to make the infrastructure more manageable but I&#8217;ll explore those aspects in the future.
