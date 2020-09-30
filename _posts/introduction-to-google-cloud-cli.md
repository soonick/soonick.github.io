---
title: Introduction to Google Cloud CLI
author: adrian.ancona
layout: post
date: 2020-09-30
permalink: /2020/09/introduction-to-google-cloud-cli/
tags:
  - gcp
  - productivity
---

A few months ago, I wrote an article about [AWS CLI](/2020/03/introduction-to-aws-cli/). Today I'm going to explore `gcloud`, Google Cloud's CLI.

## Installation

The `gcloud` CLI requires python 3.5 or later. Let's verify our version will work:

```sh
python3 --version
```

If everything is good, we can download the cli:

```
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-309.0.0-linux-x86_64.tar.gz
```

Extract it:

```
tar -xvf google-cloud-sdk-309.0.0-linux-x86_64.tar.gz
```

<!--more-->

And install it:

```
./google-cloud-sdk/install.sh
```

The installation will prompt us to update an rc file. In my case, I updated `~./bashrc`. The last step is to source this file:

```
. ~/.bashrc
```

Finally, we have the `gcloud` command installed.

## Configuring gcloud

For `gcloud` to be usedful, we need to connect it to an actual Google Cloud account. To do this, we need to get a JSON key file from our console. We can do this from the `Service Accounts` section:

[<img src="/images/posts/gcp-service-accounts.png" alt="GCP Service Accounts" />](/images/posts/gcp-service-accounts.png)

Select `Create Service Account`:

[<img src="/images/posts/gcp-create-service-account.png" alt="GCP Create Service Account" />](/images/posts/gcp-create-service-account.png)

Fill the form:

[<img src="/images/posts/gcp-service-account-form.png" alt="GCP Service Account Form" />](/images/posts/gcp-service-account-form.png)

Assign permissions:

[<img src="/images/posts/gcp-service-account-permissions.png" alt="GCP Service Account Permissions" />](/images/posts/gcp-service-account-permissions.png)

Click `Done`:

[<img src="/images/posts/gcp-service-account-done.png" alt="GCP Service Account Done" />](/images/posts/gcp-service-account-done.png)

Then, we need to go to edit the account and `Create new key`:

[<img src="/images/posts/gcp-create-new-key.png" alt="GCP Create new key" />](/images/posts/gcp-create-new-key.png)

And download it:

[<img src="/images/posts/gcp-download-json-key.png" alt="GCP download JSON key" />](/images/posts/gcp-download-json-key.png)

Once we have the key, we need to pass it to `gcloud`:

```
gcloud auth activate-service-account --key-file=projectid-123456789.json
```

To verify the account was registered correctly, we can use this command:

```
gcloud auth list
```

The output looks like this:

```
               Credentialed Accounts
ACTIVE  ACCOUNT
*       gcloud@yoyo-1234567.iam.gserviceaccount.com
```

We can now log into the account:

```
gcloud auth login gcloud@yoyo-1234567.iam.gserviceaccount.com 
```

## Using gcloud

There are a lot of options available on `gcloud`, a good way to explore them is to use the help:

```
gcloud --help
```

The output is pretty long. One thing to note is that the `GROUPS` section holds the different Google Cloud services that can be managed with the CLI:

```
GROUPS
    GROUP is one of the following:

     access-context-manager
        Manage Access Context Manager resources.

     bigtable
        Manage your Cloud Bigtable storage.

     builds
        Create and manage builds for Google Cloud Build.

     compute
        Create and manipulate Compute Engine resources.

     config
        View and edit Cloud SDK properties.

     ...
```

From here, we can use the help to figure out how to use the different services. For example:

```
gcloud compute --help
```

We can start a new compute instance with this command:

```
gcloud compute instances create my-new-instance --zone=europe-west1-b
```

Since we didn't specify a machine type, a default will be used (In my case: `n1-standard-1`).

## Conclusion

In this article I covered how to set up `gcloud` cli and how to navigate the help to achive our needs. The help menu is organized in a way that makes it easy to find what we are looking for, but if that doesn't work, there is always the option of asking Google.
