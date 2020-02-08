---
title: Introduction to AWS CLI
author: adrian.ancona
layout: post
# date: 2020-02-26
# permalink: /2020/02/introduction-to-circleci/
tags:
  - authentication
  - automation
  - aws
  - productivity
---

I'm going to start working a lot with AWS, so I will need to get familiar with they're tools. One of the most important tools to get familiar with, is their CLI.

Although it is possible to do most things from AWS management console, learning how to use the CLI allows for scripting and automation, which can help increase productivity.

[<img src="/images/posts/aws-management-console.png" alt="AWS Management Console" />](/images/posts/aws-management-console.png)

## Installation

To install AWS CLI we need Python 3.4 or later. Use `--version` to verify it's installed:

```sh
python3 --version
```

We also need pip3. To install it:

```sh
sudo apt install python3-pip
```

To install AWS CLI:

```sh
pip3 install awscli --upgrade --user
```

Since we used the `--user` option, the binary is installed in `~/.local/bin/aws`, let's add this folder to our PATH:

```sh
echo "export PATH=\$HOME/.local/bin:\$PATH" >> ~/.bashrc
. ~/.bashrc
```

We can now use the `aws` command:

```sh
aws --version
aws-cli/1.17.9 Python/3.7.5 Linux/5.3.0-29-generic botocore/1.14.9
```

## Creating an admin user

When we open an AWS account, we are the root of that account. It is recomended to create a separate IAM (Identity and Access Management) admin user for the CLI.

To create our user, we need to go to the [IAM console](https://console.aws.amazon.com/iam/). Select `Users` on the left menu and then `Add user`.

[<img src="/images/posts/aws-aim-add-user.png" alt="AWS IAM add user" />](/images/posts/aws-iam-add-user.png)

The first step is to choose a user name and what kind of access we want for the user, I chose `awscli` as user name and only programmatic access:

[<img src="/images/posts/add-iam-user-step-1.png" alt="Add IAM user step 1" />](/images/posts/add-iam-user-step-1.png)

The next step is to choose the permissions for the user. I chose to add my user to a group, and created a new group. I named the group `Administrators`.

[<img src="/images/posts/add-iam-user-step-2.png" alt="Add IAM user step 2" />](/images/posts/add-iam-user-step-2.png)
[<img src="/images/posts/add-iam-user-step-2-create-group.png" alt="Add IAM user step 2. Create group" />](/images/posts/add-iam-user-step-2.png)

Next we are asked to add tags to the user. I didn't add any:

[<img src="/images/posts/add-iam-user-step-3.png" alt="Add IAM user step 3" />](/images/posts/add-iam-user-step-3.png)

We can then review the user:

[<img src="/images/posts/add-iam-user-step-4.png" alt="Add IAM user step 4" />](/images/posts/add-iam-user-step-4.png)

And we'll finally have our user created.

[<img src="/images/posts/add-iam-user-step-5.png" alt="Add IAM user step 5" />](/images/posts/add-iam-user-step-5.png)

This screen will show the `Access key ID` and `Secret access key` for the user. We will need this information to configure the CLI. This is the only time this information is given to us, so it's important to save it somewhere safe (a password vault) so we can get it in the future if we need it.

## Configuration

Now that we have our admin user, we can configure the CLI so it can create resources on our AWS account.

```sh
aws configure
```

We are prompted for the `Access key ID` and `Secret access key` from the previous step. In addition to that, we are prompted for a default region (Region where resources will be created if no region is specified) and output format (json, yaml, text or table) for the result of running a command.

The input is saved in `~/.aws/credentials` (The access key ID and secret access key) and in `~/.aws/config`.

It is possible to register multiple profiles (linked to different AWS accounts) in the same machine, but I'm not going to cover how to do that in this article. The keys we configured are going to be used by AWS CLI unless specified otherwise (with command line arguments or environment variables, for example).

## Command line completion

AWS CLI comes with a command line completion program that is installed along the `aws` command. To enable it for bash:

```sh
echo "complete -C 'aws_completer' aws" >> ~/.bashrc
. ~/.bashrc
```

Now we can use the `tab` key to autocomplete commands.

## Usage

AWS CLI can be used to manage most resources provided by AWS, so I won't be covering all the options available. We can find information about the multiple commands supported by the CLI:

```sh
aws help
```

This command will you the command line arguments that can be used with `aws`, as well as a list of the services that it can manage. To get information about a specific service:

```sh
aws rds help
```

A common task that we might want to do with AWS CLI is create a virtual machine (EC2 instance). Before we can create the virtual machine, we need to decide which image (operating system) we want to use. To see all the available images created by Amazon:

```sh
aws ec2 describe-images --owners amazon
```

This will return a huge list of images. To find the latest Ubuntu LTS image we can use this command (You might need to modify the commad to fit the name and version of the latest LTS):

```sh
aws ec2 describe-images --owners 099720109477 --filters 'Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-????????' 'Name=state,Values=available' --query 'reverse(sort_by(Images, &CreationDate))[:1]'
```

We will need the `ImageId`.
