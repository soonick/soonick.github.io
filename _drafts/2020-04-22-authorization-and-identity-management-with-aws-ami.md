---
title: Identity and Access Management with AWS IAM
author: adrian.ancona
layout: post
date: 2020-04-22
permalink: /2020/04/identity-and-access-management-with-aws-iam/
tags:
  - authentication
  - aws
  - security
---

In a previous post I wrote about [AWS CLI](/2020/03/introduction-to-aws-cli/). In that post I explained how to create an admin user and how to use that user with the CLI. In this post I'm going to go in more depth into AWS IAM and show some examples.

## The root user

When someone signs up to AWS they will need to provide an e-mail address and password they want to use to access their account. At this point, they are the only person who knows that combination of e-mail and password, so it can be safely assumed that whoever holds those two pieces of information is the owner of the account.

The owner of the account has the power to create or delete resources as they desire, so it's very important that the password doesn't fall in the wrong hands.

<!--more-->

To protect this account, it is recommended that it is only used to create an Admin user. This admin user account can create and delete any resource, but it can't, for example, close the account or change the account settings.

For the rest of this post I will assume the admin account has been created and the CLI has been configured to use the admin user. If you don't know how to do this, take a look at my [introduction to AWS CLI](/2020/03/introduction-to-aws-cli/).

## IAM glossary

At a high level, IAM will help us identify who someone is and what they are allowed to do.

In order to understand how to use IAM effectively, we need to understand the diferent pieces that interact when authenticating (who they are) and authorizing (what they can do) a request.

- **Resource** - A resource is pretty much anything that can be managed in AWS. An EC2 instance or an S3 bucket are resources, that can be created or destroyed. Users are also resources that can be managed through AWS.
- **User** - A user can be given permissions to perform actions on other resources. A user can have permissions to read certain S3 buckets, for example.
- **Group** - Groups can be used to give permissions to users that are similar. For example, imagine an organization uses `CodeCommit` (Private git repository) to store their source code. All developers in that organization will probably need permissions to work on these repositories. A user can be created for each developer and all users added to a single group. Then this group can be given permissions on all `CodeCommit` repos. If a new developer joins the team, it's just a matter of adding the user to the group.
- **Role** - A role is an identity that can be assumed by an entity to allow it to perform specific operations. When a user or service assumes a role, AWS provides it with temporary credentials that can be used to act as the assumed role.
- **Policy** - A policy is a set of permissions. Policies can be assigned to users, groups or roles to allow them to perfom actions on resources.
- **Identity** - A user, group or role.
- **Entity** - When a person or system authenticates to AWS, it will provide credentials that identify it as an entity (user or role).
- **Principal** - A person or system that authenticates to AWS.

These terms can be a little confusing, so I'll try to explain it with an example:

I (the writer of this post) am a `principal`. I have an AWS account that I created and in that account I created a `user` named `myself`. Because I have multiple users in that account, I created a `group` and named it `admins`. I attached a `policy` to this group that allows managing any kind of `resource` in my account.

I have a service (The service is a `principal`) that creates S3 buckets (S3 buckets are `resources`) in my account. I created a `role` for this service and assigned a `policy` that allows it to create buckets. In order for the service to authenticate to AWS it needs some credentials. I create a `user` for my service and I allow it to assume the `role` I just created. When the service starts, it will claim to be the service `entity` and try try to assume to correct `role`. Since the credentials are valid, it will be given temporary credentials that it can use to create the `resources` it needs.

Hopefully, that makes it a little clearer.

## Policies

Policies are used to define permissions for an Identity or Resource. AWS supports a few types of policies, but I'm just going to go over `Identity based policies`, which are policies that can be attached to an Identity.

Policies are represented using JSON. They have the following structure:

```js
{
  "Version": "2012-10-17",
  "Statement": []
}
```

`Version` refers to the version of the policy language. It hasn't been updated in a few years (which is a good thing), so the same value appears in all policies. The policy also contains an array of statements. Each `Statements` defines a permission.

When AWS validates if an Entity has the correct permissions to perform an action, it will `OR` all the statements in all the policies attached to that Entity.

A statement looks like this:

```js
{
  "Sid": "StatementName",
  "Effect": "Allow",
  "Action": ["s3:Get"],
  "Resource": "arn:aws:s3:::someBucket/*"
}
```

- `Sid` - An optional name for the statement
- `Effect` - Either **Allow** or **Deny**
- `Action` - Specifies the actions that this statement refers to. For a list of all the possible values look at the [actions' documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_actions-resources-contextkeys.html)
- `Resource` - Resources this statement refers to (Using the [ARN](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) format). Some actions can apply only to some resources.

## IAM with AWS CLI

Often, when working with AWS CLI, I want to know which Identity is being used by the CLI. This information can be obtained with this command:

```sh
aws sts get-caller-identity
```

To list all the users in an account:

```sh
aws iam list-users
```

To list all roles:

```sh
aws iam list-roles
```

To list all groups:

```sh
aws iam list-groups
```

There are a lot of policies provided by default by AWS, those can be listed using the following command (warning: takes a very long time):

```sh
aws iam list-policies
```

A more useful (and much faster) command to list only policies created by this account:

```sh
aws iam list-policies --scope Local
```

Now that we know how to inspect IAM resources, we might want to create some of our own.

To create a policy we can use this command

```sh
aws iam create-policy --policy-name SourceCodeCommitter --description "Allows reading and committing to CodeCommit repos" --policy-document file://policy.json
```

Notice that we specify the actual policy in another file. Also notice that we need to prefix the path to the file with `file://`.

To create a new group we just need to provide a name:

```sh
aws iam create-group --group-name developers
```

Creating a user also requires only the name:

```sh
aws iam create-user --user-name carlos
```

To add a user to a group:

```sh
aws iam add-user-to-group --group-name developers --user-name carlos
```

To add a policy to a group:

```sh
aws iam attach-group-policy --group-name developers --policy-arn arn:aws:iam::123456789:policy/source-code-comitter
```

## Roles and AWS STS (Security Token Service)

You might have noticed that I didn't mention how to create a role using AWS CLI. The reason for this is that `roles` work a little different to `users` and `groups`.

The main difference between a `user` and a `role` is that there are no long living credentials for roles. If we need to use the permissions of a `role`, we need to `assume` that role and we will be given temporary credentials that we can use.

Roles are necessary for some advanced use cases:

- **Delegation** - Allow a user in one AWS account to manage resources on a different AWS account.
- **Federation** - Allow users that already have credentials in other directories (LDAP, OpenID, etc,) to manage resources in an AWS account, whithout having to create users for them.

I'm not going to cover those scenarios in this post. Instead, I'm just going to show how to create and assume a role within the same account.

### Assume role policy

Before we can create a role, we need to define an assume role policy, which defines who can assume this role. The format is the same as Identity policies:

```js
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::1234567890:user/carlos"
      },
      "Action": [
        "sts:AssumeRole"
      ]
    }
  ]
}
```

This policy will allow the user identified by ARN `arn:aws:iam::1234567890:user/carlos`, to assume the role this policy is attached to.

### Creating the role

With the assume role policy ready, we can create our role:

```sh
aws iam create-role --role-name blog-role --assume-role-policy-document file://assume-policy.json
```

At this point the role doesn't have any permissions. We can assign permissions the same way we assign permissions to users or groups.

### Assuming the role

To use a role we need to "assume" it. If our cli user is allowed to assume the role, we can use this command:

```sh
aws sts assume-role --role-arn arn:aws:iam::1234567890:role/blog-role --role-session-name cli-session
```

The session name can be any arbitrary string. The only limitation is that there can't be two sessions for the same role using the same name at the same time.

The command above, outputs some credentials that can be used to assume the role. To use these credentials from the CLI, we can set 3 environment variables:

```
export AWS_ACCESS_KEY_ID="<access key id>"
export AWS_SECRET_ACCESS_KEY="<access key>"
export AWS_SESSION_TOKEN="<session token>"
```

We can verify this works with the following command:

```
aws sts get-caller-identity
```

If everything worked correctly, we will see the identity as that of the role we just assumed.

## Conclusion

IAM allows for very fine grained control of users and resources. This is good, but comes with some complexity. In this post I try to unravel some of the complexity by defining some of the terms; then I show some simple examples of how to use it from AWS CLI.
