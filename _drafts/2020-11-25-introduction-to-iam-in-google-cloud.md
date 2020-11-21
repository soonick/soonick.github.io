---
title: Identity and Access Management (IAM) with Google Cloud
author: adrian.ancona
layout: post
date: 2020-11-25
permalink: /2020/11/identity-and-access-management-with-google-cloud/
tags:
  - authentication
  - gcp
  - security
---

In this post we're going to learn how to use Google Cloud IAM (Identity and Access Management) to limit who can manage resources in a Google Cloud account.

If you are interested in AWS IAM, you can check my [Identity and Access Management with AWS](/2020/04/identity-and-access-management-with-aws-iam/) article.

## Concepts

- **Member** - An entity that needs to perform an action on a resource. An end user or a service are examples of members
- **Identity** - Another name for **Member**
- **Resource** - A resource is pretty much anything that can be managed in GCP. A compute engine instance or a cloud storage bucket are examples of resources
- **Permission** - Allows or denys access to resources. For example: create a storage bucket
- **Role** - A collection of permissions. Roles can be granted to **members**
- **Policy** - Defines who (**member**) can perform which actions (**permissions**) on which **resources**

<!--more-->

## Owner

When we create a new project, there will be a single `Member` with the `Owner` role assigned to it:

[<img src="/images/posts/gcp-iam-owner.png" alt="GCP IAM owner" />](/images/posts/gcp-iam-owner.png)

This is the person that created the Google Cloud account and has complete domain over it. A project must have at least one owner.

## Service accounts

Service accounts are a way to allow software to do things in Google Cloud. Some examples of software that wants to do something in Google Cloud are:

- [Google Cloud CLI](/2020/09/introduction-to-google-cloud-cli/)
- A build system that publishes docker images to container registry
- A program that stores photos in storage buckets

Depending on what the software needs to do, we should assign a role with only the necessary permissions to do what it needs.

Service accounts are created from the [Identity -> Service Accounts section](https://console.cloud.google.com/identity/serviceaccounts) on the cloud console.

Since we're going to be using `gcloud` for the rest of the article, take a look at my [introduction to Google Cloud CLI](/2020/09/introduction-to-google-cloud-cli/) for how to configure it. Notice that this role is all powerful, so it should be only used by the owner of the account.

Once we have `gcloud` configured, we can see all the service accounts:

```sh
gcloud iam service-accounts list
```

To create a new service account:

```sh
gcloud iam service-accounts create <NAME> \
    --description="<DESCRIPTION>" \
    --display-name="<NAME>"
```

To delete a service account:

```sh
gcloud iam service-accounts delete <SERVICE ACCOUNT>
```

## Members

Gcloud's interface is not the prettiest, so if we want to get information about the members we have to use this command:

```sh
gcloud projects get-iam-policy <PROJECT>
```

The output will show all members (including service accounts) and all the roles associated with them.

In the previous section we saw how to add service accounts. Other types of members are:

- Google account
- Google group
- Google Workspace
- Cloud Identity

I'm not going to explain these in detail.

A Google account is any account that was opened on Google (e.g. myname@gmail.com). We can add a google account as a member of our project using this command:

```sh
gcloud projects add-iam-policy-binding <PROJECT> \
    --member=user:<USER EMAIL> \
    --role=<ROLE>
```

I'll talk more about the possible values for `ROLE` later in this article

## Roles

Roles are a way to group permissions so they can easily be assigned to members. There are a lot of roles provided by default by Google (e.g. Editor), but it's better to create our own roles so we grant the least amount of permissions to each member.

We can see all the roles in our project with:

```
gcloud iam roles list
```

This command shows the roles' names and descriptions, but it doesn't show which permissions are assigned to the role. To see the permissions assigned to a role, we can use:

```sh
gcloud iam roles describe <ROLE>
```

For example:

```sh
$ gcloud iam roles describe roles/workflows.viewer
description: Read-only access to workflows and related resources.
etag: AA==
includedPermissions:
- resourcemanager.projects.get
- resourcemanager.projects.list
- workflows.executions.get
- workflows.executions.list
- workflows.locations.get
- workflows.locations.list
- workflows.operations.get
- workflows.operations.list
- workflows.workflows.get
- workflows.workflows.getIamPolicy
- workflows.workflows.list
name: roles/workflows.viewer
stage: BETA
title: Workflows Viewer
```

Getting the list of all the permissions that exist (and can be assigned to a role) is not easy. The best way I know to find which permissions I need to assign to a role is by asking google. There is a [permissions reference](https://cloud.google.com/iam/docs/permissions-reference), but it's pretty hard to navigate.

We can create our own role with this command:

```sh
gcloud iam roles create <ROLE ID> \
    --project="<PROJECT>" \
    --description="<DESCRIPTION>" \
    --permissions="<PERMISSIONS>"
```

For example:

```sh
gcloud iam roles create MyTestRole \
    --project=golden-frame-295509 \
    --description="Created this role because I wanted to" \
    --permissions="workflows.operations.list,workflows.operations.get"
```

We can modify a role we created. To remove permissions:

```sh
gcloud iam roles create <ROLE ID> \
    --project="<PROJECT>" \
    --description="<DESCRIPTION>" \
    --remove-permissions="<PERMISSIONS>"
```

To add permisions:

```sh
gcloud iam roles create <ROLE ID> \
    --project="<PROJECT>" \
    --description="<DESCRIPTION>" \
    --add-permissions="<PERMISSIONS>"
```

Now that we know how to create `members` and `roles`, we can learn how to manage them.

We add a `role` to a service account by attaching a policy binding:

```sh
gcloud projects add-iam-policy-binding <PROJECT> \
    --member serviceAccount:<SERVICE ACCOUNT> \
    --role <ROLE>
```

To remove a role:

```sh
gcloud projects remove-iam-policy-binding <PROJECT> \
    --member serviceAccount:<SERVICE ACCOUNT> \
    --role <ROLE>
```

To see all the roles assigned to a member:

```sh
gcloud projects get-iam-policy <PROJECT>  \
    --flatten="bindings[].members" \
    --format='table(bindings.role)' \
    --filter="bindings.members:<SERVICE ACCOUNT>"
```

Now we have all we need to create members and attach the correct roles to those members.

## Conclusion

I'm not and expert in Identity and Access Management, but I was surprised by how hard it was to get the commands right with gcloud. The way `gcloud` commands are organized makes it really difficult to use the help to discover how to achieve something. I had to do multiple Google searches to find how to do some things.

The concepts of organization and project can also be tricky. In all the examples above, we created resources at the project level, but it's also possible to create resources at the organization level, which might make navigation confusing.
