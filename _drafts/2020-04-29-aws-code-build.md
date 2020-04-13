---
title: AWS CodeBuild
author: adrian.ancona
layout: post
date: 2020-04-29
permalink: /2020/04/aws-codebuild
tags:
  - automation
  - aws
  - productivity
---

CodeBuild is AWS' offering for running builds in the cloud. We can think of it as an alternative to TravisCI or CircleCI.

## Concepts

There are 4 things we need to configure as part of a CodeBuild project:

- **Source** - Get the code we want to build. At the time of this writing, we can retrieve code from S3, GitHub, Bitbucket or CodeCommit (AWS' code hosting offering)
- **Environment** - Type of machine to use for the builds
- **Buildspec** - Commands to run as part of the build
- **Artifacts** - Artifacts to publish to S3 (Optional)

<!--more-->

### Source

There are a few options for getting the source code we want to build, but the process is the same for all of them. The machine that will run the build needs to be able to retrieve the code, so it has to be given the correct permissions or credentials to do it.

We are going to get our code from a Github repo, so we will need to provide a key that allows the build machine to retrieve it.

### Environment

For the environment stage, we can use one of the standard CodeBuild images, or we can choose to use a custom Docker image.

We are going to use a standard image since we don't need anything fancy for this example.

This stage also allows us to specify an IAM role for the build machine. This role will be used to retrieve code from CodeCommit, push artifacts to S3 or publish logs to CloudWatch.

### Buildspec

By default, `CodeBuild` will look for a file named `buildspec.yml` in the repo we are building. This file contains instructions for the build.

I'm not going to explain all the options since they are documented in the [build spec reference](https://docs.aws.amazon.com/codebuild/latest/userguide/build-spec-ref.html).

For our example, we will use the following:

```yaml
version: 0.2

phases:
  build:
    commands:
      - g++ hello-world.cpp -o output

artifacts:
  files:
    - output
  name: artifacts
```

Version 0.2 is the latest as the time of this writing.

For this example, we are just going to build a simple `hello world` program. We are defining a single command for the `build` phase. We could have specified more than one command and they would be run one at a time in the specified order. It's also possible to specify other phases. The available phases are: `install`, `pre_build`, `build`, `post_build`.

The `artifacts` section allows us to publish the result from our build to S3. In this case, we are publishing a single file called `output`.

### Artifacts

If a build generates artifacts (e.g. An executable or a package file), they can be published to S3 using this section.

One build can generate multiple artifacts, but they will all be published to the same bucket. The buildspec example above shows how output artifacts are configured.

## Creating a project using AWS CLI

Now that we are familiar with CodeBuild, we can proceed to create a project. This can be done from AWS Console (Web UI), but I prefer to use the CLI. The general form of the CLI command is:

```sh
aws codebuild create-project \
  --name <some name> \
  --service-role <role name> \
  --source <source definition> \
  --environment <environment definition> \
  --artifacts <artifacts definition>
```

The `name` can be any string to identify this project. The `service-role` is the ARN of the role that will be used by CodeBuild when trying to retrieve code or publish artifacts.

For the `source` parameter we need to specify a few fields:

- **type** - \"CODECOMMIT\" \| \"CODEPIPELINE\" \| \"GITHUB\" \| \"S3\" \| \"BITBUCKET\" \| \"GITHUB_ENTERPRISE\" \| \"NO_SOURCE\"
- **location** - URL of the repo
- **auth** - Credentials that will be used to retrieve the code repo

In order to allow CodeBuild to access a private Github repo, we need to first create a token. To create a token, go to [Personal access tokens](https://github.com/settings/tokens) in Github, and `Generate new token`. The token must have `repo` permissions (Full control of private repositories).

Create a json file (name it `creds.json`):

```js
{
  "serverType": "GITHUB",
  "authType": "PERSONAL_ACCESS_TOKEN",
  "token": "<generated token>"
}
```

And add the credentials to CodeBuild:

```sh
aws codebuild import-source-credentials --cli-input-json file://creds.json
```

This command will return an ARN that will be needed to create the project.

For the `environment` parameter:

- **type** - \"WINDOWS_CONTAINER\" \| \"LINUX_CONTAINER\" \| \"LINUX_GPU_CONTAINER\" \| \"ARM_CONTAINER\"
- **computeType** - \"BUILD_GENERAL1_SMALL\" \| \"BUILD_GENERAL1_MEDIUM\" \| \"BUILD_GENERAL1_LARGE\" \| \"BUILD_GENERAL1_2XLARGE\"
- **image** - The name of the image to use. To list the available images we can use this command: `aws codebuild list-curated-environment-images`

For `artifacts`:

- **type** - "CODEPIPELINE" \| "S3" \| "NO_ARTIFACTS"
- **location** - If `S3` type, this must be the name of the bucket where artifacts will be published

If we put everything together, we get this command:

```sh
aws codebuild create-project \
  --name HelloWorldProject \
  --service-role HelloWorldProjectRole \
  --source type=GITHUB,location=https://github.com/user/CodeBuildTest,auth=\{type=OAUTH,resource=<source credentials ARN>\} \
  --environment type=LINUX_CONTAINER,computeType=BUILD_GENERAL1_SMALL,image=aws/codebuild/standard:1.0 \
  --artifacts type=S3,location=hello-world-output
```

Once the project is created, we can start a build:

```sh
aws codebuild start-build --project-name HelloWorldProject
```

We can then check the status of the build with this command:

```sh
aws codebuild batch-get-builds --ids <build id>
```

## Troubleshooting

### CodeBuild is not authorized to perform: sts:AssumeRole

This message means that the `service-role` selected for the project wasn't configured correctly. To fix it, make sure the trust policy allows `codebuild.amazonaws.com` to assume the role. Looks something like this:

```js
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### User: &lt;user ARN> is not authorized to perform: logs:CreateLogStream on resource: &lt;resource ARN>

This message is shown when CodeBuild tries to write logs to CloudWatch, but it doesn't have permission to do so. The role needs to have permissions to create log streams. Create a policy similar to this one and attach it to the role:

```js
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:1234567890:log-group:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:1234567890:log-group:/aws/codebuild/HelloWorldProject:log-stream:*"
            ]
        }
    ]
}
```

### CLIENT_ERROR: authentication required for primary source

This message means that CodeBuild wasn't able to download the source code from the specified repo. Review the instructions for adding a personal access token for Github.

### CLIENT_ERROR: Error in UPLOAD_ARTIFACTS phase: AccessDenied

This most likely means that CodeBuild doesn't have permissions to upload to the selected S3 bucket. We can add a policy similar to the following to CodeBuild's role:

```js
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::hello-world-output/*"
            ]
        }
    ]
}
```

### User: &lt;user ARN> is not authorized to perform: logs:PutLogEvents on resource: &lt;resource ARN>

This means the build logs weren't uploaded to CloudWatch, to fix this we need to allow CloudBuild's role to create logs with a policy similar to the following:

```js
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:1234567890:log-group:/aws/codebuild/HelloWorldProject:log-stream:*"
            ]
        }
    ]
}
```

## Conclusion

Getting a build to run with CodeBuild turned out to be considerably harder than doing the same in Travis, CircleCI or Gitlab.

Most of the issues I stumbled into were related to permissions. Assigning the correct policy to a role with IAM required some investigation.

Another issue was configuring the logs in CloudWatch. This step doesn't exist in other offerings, since the logs are usually available automatically.
