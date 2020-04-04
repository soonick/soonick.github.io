---
title: Identity and Access Management with AWS IAM
author: adrian.ancona
layout: post
# date: 2020-03-04
# permalink: /2020/03/introduction-to-aws-cli/
tags:
  - authentication
  - aws
  - security
---

In a previous post I wrote about [AWS CLI](/2020/03/introduction-to-aws-cli/). In that post I explained how to create an admin user and how to use that user with the CLI. In this post I'm going to go in more depth into what AWS IAM can do and what are some best practices.

## The root user

When someone signs up to AWS they will need to provide an e-mail address and password they want to use to access their account. At this point, they are the only person that knows that combination of e-mail and password, so it can be safely assumed that whoever holds those two pieces of information is the owner of the account.

The owner of the account has the power to create or delete resources as they desire, so it's very important that it doesn't fall in the wrong hands.

To protect this account, it is recommended that it is only used to create an Admin user. This admin user account can create and delete any resource, but it cannot for example, close the account or change the account settings.

For the rest of this post I will assume the admin account has been created and the CLI has been configured to use this user. If you don't know how to do this, take a look at my [introduction to AWS CLI](/2020/03/introduction-to-aws-cli/).

## IAM Terms

At a high level, IAM will help us identify who someone is and what they are allowed to do.

In order to understand how to use IAM, we need to understand the diferent pieces that interact when authenticating (who they are) and authorizing (what do they have permission to do) a request.

- **Resource** - A resource is pretty much anything that can be managed in AWS. An EC2 instance or an S3 bucker are resources, that can be created or destroyed. Users are also resources that can be managed through AWS.
- **User** - A user can be given permissions to perform actions on other resources. A user can have permissions to read certain S3 buckets, for example.
- **Group** - Groups can be used to give permissions to users that are similar. For example, imagine an organization uses `CodeCommit` (Private git repository) to store their source code. All developers in that organization will probably need permissions to work on these repositories. A user can be created for each developer and all users added to a single group. Then this group can be given permissions on all `CodeCommit` repos. If a new developer joins the team, it's just a matter of adding the user to the group.
- **Role** - A role is an identity that can be assumed by an entity to allow it to perform specific operations. When a user or service assumes a role, AWS provides it with temporary credentials that can be used to act as the assumed role.
- **Policy** - A policy is a set of permissions. Policies can be assigned to users, groups or roles to allow them to perfom actions on resources.
- **Identity** - A user, group or role
- **Entity** - When a person or system authenticates to AWS, it will provide credentials that identify it as an entity (user or role)
- **Principal** - A person or system that authenticates to AWS.

These terms can be a little confusing, so I'll try to explain it with an example:

I (the writer of this post) am a `principal`. I have an AWS account that I created and in that account I created a `user` named `myself`. Because I have multiple users in that account, I created a `group` and named it `admins`. I attached a `policy` to this group that allows managing any kind of `resource` in my account.

I have a service that creates S3 buckets (S3 buckets are `resources`) in my account. I created a `role` for this service and assigned a `policy` that allows it to create buckets. In order for the service to authenticate to AWS it needs some credentials. I create a `user` for my service and I allow it to assume the `role` I just created. When the service starts it will claim to be the service `entity` and try try to assume to correct `role`. Since the credentials are valid, it will be given temporary credentials that it can use to create the `resources` it needs.

Hopefully, that makes it a little clearer.

## Policies

https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html
https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_understand.html


## IAM with AWS CLI

Often when working with AWS CLI, I want to know which identity (user or role) is being used by the CLI. We can use this command to find out:

```sh
aws sts get-caller-identity
```

To list all the users in your account:

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

The policy file I used for this policy is the following:

```js
{
  "Version": "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Action" : [
        "codecommit:AssociateApprovalRuleTemplateWithRepository",
        "codecommit:BatchAssociateApprovalRuleTemplateWithRepositories",
        "codecommit:BatchDisassociateApprovalRuleTemplateFromRepositories",
        "codecommit:BatchGet*",
        "codecommit:BatchDescribe*",
        "codecommit:Get*",
        "codecommit:List*",
        "codecommit:Create*",
        "codecommit:DeleteBranch",
        "codecommit:DeleteFile",
        "codecommit:Describe*",
        "codecommit:DisassociateApprovalRuleTemplateFromRepository",
        "codecommit:EvaluatePullRequestApprovalRules",
        "codecommit:OverridePullRequestApprovalRules",
        "codecommit:Put*",
        "codecommit:Post*",
        "codecommit:Merge*",
        "codecommit:TagResource",
        "codecommit:Test*",
        "codecommit:UntagResource",
        "codecommit:Update*",
        "codecommit:GitPull",
        "codecommit:GitPush"
      ],
      "Resource" : [
        "arn:aws:codecommit:*"
      ]
    }
  ]
}
```

##################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I'm not going to go in detail into the policy, but it allows us to specify what actions to allow or deny in which resources.

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

You might have noticed that I didn't mentioned how to create a role using AWS CLI. The reason for this is that `roles` work a little different to `users` and `groups`.

The main difference between a `user` and a `role` is that there are no long living credentials for roles. If we need to use the permissions of a `role`, we need to `assume` that role and we will be given temporary credentials that we can use.

Roles are necessary for some advanced use cases:

- **Delegation** - Allow a user in one AWS account to manage resources on a different AWS account.
- **Fedration** - Allow users that already have credentials in other directories (LDAP, OpenID, etc,) to manage resources in an AWS account, whithout having to create a user for it.

I'm not going to cover those scenarios in this post. Instead, I'm just going to show how to create and assume a role within the same account.

### Assume role policy

Before we can create a role, we need to define an assume role policy, which defines who can assume this role.

Roles also allow you to do certain things that 

```sh
aws iam create-role --role-name creator-role --assume-role-policy-document file://assume-policy.json
```

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user.html











#################### Describe the different files used



https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html
https://docs.aws.amazon.com/IAM/latest/UserGuide/intro-structure.html
