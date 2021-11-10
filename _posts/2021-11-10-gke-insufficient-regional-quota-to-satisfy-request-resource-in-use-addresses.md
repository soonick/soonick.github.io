---
title: "GKE - Insufficient regional quota to satisfy request: resource \"IN_USE_ADDRESSES\""
author: adrian.ancona
layout: post
date: 2021-11-10
permalink: /2021/11/gke-insufficient-regional-quota-to-satisfy-request-resource-in-use-addresses
tags:
  - architecture
  - docker
  - error_messages
  - gcp
---

In noticed this error when I was trying to create a new GKE cluster:

> ERROR: (gcloud.container.clusters.create) ResponseError: code=403, message=Insufficient regional quota to satisfy request: resource "IN_USE_ADDRESSES": request requires '9.0' and is short '1.0'. project has a quota of '8.0' with '8.0' available. View and manage quotas at https://console.cloud.google.com/iam-admin/quotas?usage=USED&project=test-123456

GCP by default has a limit of 8 static global IP addresses per project, we need to raise that limit to make this error go away.

We can see the current limit with this command:

```bash
gcloud compute project-info describe | grep STATIC_ADDRESSES -C 2
```

Sadly, there is currently no way to increase quotas from `gcloud` cli, so we need to use the web UI.

From the console, search for `quotas` and select the `IAM & Admin` result:

[<img src="/images/posts/gcp-quotas-search.png" alt="GCP Quotas Search" />](/images/posts/gcp-quotas-search.png)

<!--more-->

Once in the quotas page, filter by `Compute Engine API` service and `Static IP address global` quota:

[<img src="/images/posts/gcp-quotas-filter.png" alt="GCP Quotas Filter" />](/images/posts/gcp-quotas-filter.png)

Here, we can see that our current limit is `8`. To request an increase in the quota, select the row and click on `Edit Quotas`:

[<img src="/images/posts/gcp-quotas-edit.png" alt="GCP Quotas Edit" />](/images/posts/gcp-quotas-edit.png)

Then we need to increase the quota limit. We can choose 10, for example:

[<img src="/images/posts/gcp-quotas-increase.png" alt="GCP Quotas Increase" />](/images/posts/gcp-quotas-increase.png)

Google asks for some personal information before submitting the request:

[<img src="/images/posts/gcp-quotas-pi.png" alt="GCP Quotas Personal Information" />](/images/posts/gcp-quotas-pi.png)

And finally, we'll get a confirmation that the request was submitted:

[<img src="/images/posts/gcp-quotas-success.png" alt="GCP Quotas Success" />](/images/posts/gcp-quotas-success.png)

We might need to do the same process for `In-use IP addresses` in the region:

[<img src="/images/posts/gcp-quotas-in-use-ips.png" alt="GCP Quotas In Use IP Addresses" />](/images/posts/gcp-quotas-in-use-ips.png)

I received an e-mail telling me that the request will take 2 business days to be processed, but a few minutes later I received a confirmation of the increase (Probably 20 minutes in total).

Once the quota increases are done, we should be able to proceed with the cluster creation.
