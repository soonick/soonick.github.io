---
title: Introduction to Google Cloud Run
author: adrian.ancona
layout: post
date: 2021-01-06
permalink: /2021/01/introduction-to-google-cloud-run
tags:
  - architecture
  - gcp
  - projects
---

I'm exploring the different free tier offerings by Google Cloud trying to find ways to save some money and learn something new at the same time.

Currently I'm using an `F1-micro` instance (also free tier) to run an application inside a container. This works pretty well, except for:

- Google keeps telling me that the instance is overutilized
- I manually renew my SSL certificate every time it expires
- To update the container code I need to SSH to the instance, fetch the latest image and run it

I could probably do something to automate some of these points, but I'm hoping I can get all problems solved and stay in the free tier by moving to Cloud Run.

<!--more-->

## What is Cloud Run?

Cloud Run is a serverless platform for running containerized applications.

What this means is that if we have a container image (Docker image for example), we can tell Cloud Run to run this application, and it will take care of spinning containers for it as needed based on the load.

Cloud Run can scale down all the way to 0 containers, so there is no cost incurred if there is no traffic. It can also scale up very quickly when needed. The creation and destruction of containers is abstracted from developers, so we only pay based on the numbers of requests, network, memory and CPU usage.

## The free tier

At the time of this writing, the free tier includes:

- 2 million requests per month
- 360,000 GB-seconds of memory, 180,000 vCPU-seconds of compute time
- 1 GB network egress from North America per month
- Only available for "Fully managed"

Since my application's usage is very low at the moment, I don't expect it to exceed those numbers.

## Permissions

Before we can use Cloud Run, we need to create a service account that has `iam.serviceAccounts.actAs` permission. Let's start by creating a role with that permission:

```sh
gcloud iam roles create cloud_run_role \
    --project="<PROJECT>" \
    --description="For Cloud Run to create resources" \
    --permissions="iam.serviceAccounts.actAs"
```

We also need to create a service account:

```sh
gcloud iam service-accounts create cloud-run \
    --project="<PROJECT>" \
    --description="Cloud Run Service Account" \
    --display-name="cloud-run"
```

Finally, assing the role to the service account:

```sh
gcloud projects add-iam-policy-binding <PROJECT> \
    --member serviceAccount:cloud-run@<PROJECT>.iam.gserviceaccount.com \
    --role projects/<PROJECT>/roles/cloud_run_role
```

## Running a service

To run a service we need to already have an image in Container Registry. An image identifier looks like this (This article won't cover how to publish an imagine to Google Container Registry):

```sh
gcr.io/<project id>/<image name>:<tag>
```

Once we have the image identifier, we can create a service based on it:

```sh
gcloud run deploy <service name> \
    --platform managed \
    --allow-unauthenticated \
    --region us-central1 \
    --image gcr.io/<project id>/<image name>:<tag> \
    --service-account cloud-run@<PROJECT>.iam.gserviceaccount.com \
    --port <Port the app listens to>
```

If everything is successful, the command will return a URL that can be used to access the service:

```sh
Service URL: https://<service name>-12345678-uc.a.run.app
```

To update our service we can use the same `gcloud run deploy ...` command with a different image.

## Conclusion

Cloud Run seems like a good solution for running containerized applications with low load for a low price. Compared to [App Engine](/2020/12/introduction-to-google-app-engine), it seems like Cloud Run would be more cost effective since App Engine requires to have at least one container running for "flexible" apps.
