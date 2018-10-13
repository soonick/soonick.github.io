---
id: 5116
title: Taking over existing instances with Terraform
date: 2018-05-30T05:16:48+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=5116
permalink: /2018/05/taking-over-existing-instances-with-terraform/
categories:
  - Linux
tags:
  - automation
  - linux
  - productivity
  - terraform
---
A few days ago, while playing with Terraform I realized that I want Terraform to manage some instances that I had already created in Google Cloud. Because these instances existed before I was using Terraform, it doesn&#8217;t konw anything about them.

The first thing I had to do to take over them, was to add them to the configuration:

```groovy
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
```

Once I had the machine in my configuration, I just had to tell Terraform, which machine is that:

```bash
terraform import google_compute_instance.us-central1-c--f1-micro--001 ncona-179804/us-central1-c/us-central1-c--f1-micro--001
```

From here terraform can manage it as if it had created it.

<!--more-->
