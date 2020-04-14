---
title: AWS CodePipeline
author: adrian.ancona
layout: post
date: 2020-05-06
permalink: /2020/05/aws-code-pipeline
tags:
  - automation
  - aws
  - productivity
---

In a previous post I wrote about [AWS CodeBuild](/2020/04/aws-codebuild), which allows us to run our builds using AWS infrastructure. In this post we are going one step further and explore CodePipeline; AWS' solution for continuos delivery.

Some of Pipelines' features:
- Detect code changes and start Pipeline automatically
- Split releases into stages (One per environment, for example)
- Pause the releases if a step fails
- Allow steps to only proceed after manual approval

<!--more-->

## Concepts

Before we start creating our own Pipelines, we need to get familiar with a few concepts.

- **Pipeline** - A workflow that defines the different stages a code change needs to go through
- **Stage** - A Pipeline is divided into stages. Each stage starts in a new clean environment and can perform different actions depending on what it was configured to do
- **Action** - A specific set of operations to be executed (for example; build and run tests)

The concepts will make more sense once we start creating a Pipeline. For now, the important thing to know is that a stage can have multiple actions and a Pipeline can have multiple stages.

## Excutions

Every time a change needs to run through a Pipeline, an `Execution` is created. There are a few useful things to know about executions:

- Each execution has a unique ID
- Valid execution statuses are: InProgress, Stopping, Stopped, Succeeded, Superseded, and Failed
- A stage can only run one execution at a given time
- If an execution reaches a stage that is already processing another change, the execution will wait for the stage to free before continuing
- If there is more than one execution waiting for a stage, the older executions will be **superseded** by the newest one. This means the older executions will be marked as **Superseded** and will not continue through the Pipeline. Only the newest execution will continue

## Creating Pipelines

Most examples out there show how to manage Pipelines from AWS console. I think this is fine for experimentation, but when you work on a larger project, you probably want your infrastructure to be source controlled so changes are easily traceable. For this reason, I'm going to focus solely on using AWS CLI to manage the Pipeline (If you are not familiar with AWS CLI, you can look at my [Introduction to AWS CLI](/2020/03/introduction-to-aws-cli/)).

Let's start by listing all the Pipelines in a given region:

```sh
aws codepipeline list-pipelines --region us-east-1
```

Sadly, AWS CLI doesn't allow us to list Pipelines in all regions with a single command, so we have to do one call per region we are interested in.

Since I haven't created any Pipeline, I got an empty result.

## CodePipeline JSON structure

AWS allows us to define Pipelines using a JSON file. The most basic Pipeline we can create looks something like this:

```js
{
  "name": "TestingPipeline",
  "roleArn": "arn:aws:iam::1234567890:role/PipelineRole",
  "stages": [
    {
      "name": "GetCode",
      "actions": [
        {
          "name": "GetCode",
          "actionTypeId": {
            "category": "Source",
            "owner": "AWS",
            "provider": "S3",
            "version": "1"
          },
          "configuration": {
            "S3Bucket": "code-bucket-01",
            "S3ObjectKey": "TheCode.zip"
          },
          "outputArtifacts": [
            {
              "name": "NewestCode.zip"
            }
          ]
        }
      ]
    },
    {
      "name": "BuildCode",
      "actions": [
        {
          "name": "BuildCode",
          "actionTypeId": {
            "category": "Build",
            "owner": "AWS",
            "provider": "CodeBuild",
            "version": "1"
          },
          "configuration": {
            "ProjectName": "PipelineProject"
          },
          "inputArtifacts": [
            {
              "name": "TheCode"
            }
          ]
        }
      ]
    }
  ],
  "artifactStore": {
      "type": "S3",
      "location": "pipeline-bucket-01"
  }
}
```

This Pipeline is divided in two stages:
- **GetCode** - Retrieves a zip file with code from S3
- **BuildCode** - Builds the code using CodeBuild

There are a few characteristics a Pipeline needs to have to be valid:

- Must contain at least two stages
- The first stage must contain at least one source action
- Only the first stage can contain source actions
- All stage names must be unique

The Pipeline can be created using this command (The artifacts bucket needs to exist before we can create the Pipeline):

```sh
aws codepipeline create-pipeline --pipeline file://pipeline.json
```

We can see that the Pipeline was created successfully:

```sh
aws codepipeline list-pipelines
```

If we get the state of the Pipeline:

```
aws codepipeline get-pipeline-state --name TestingPipeline
```

We might see that it's complaining because `code-bucket-01` doesn't exist:

```
...
  "latestExecution": {
      "status": "Failed",
      "lastStatusChange": 1586859291.349,
      "errorDetails": {
          "code": "ConfigurationError",
          "message": "No bucket with the name code-bucket-01 was found"
      }
  },
...
```

This issue can be fixed by creating the S3 bucket (code-bucket-01) and object (TheCode.zip) needed by the source stage (Using S3 as the code source requires `versioning` to be enabled for the bucket).

If we get the status again, we will discover that we require the CodeBuild project to exist too:

```
...
  "latestExecution": {
      "status": "Failed",
      "lastStatusChange": 1586861940.71,
      "errorDetails": {
          "code": "JobFailed",
          "message": "Error calling startBuild: Project cannot be found: arn:aws:codebuild:us-east-1:1234567890:project/PipelineProject (Service: AWSCodeBuild; Status Code: 400; Error Code: ResourceNotFoundException; Request ID: 5376d923-44ff-47ff-9d54-02f4d47b7b30)"
      }
  },
...
```

I'm not going to go into detail into how to configure the CodeBuild project because I have [an article](/2020/04/aws-codebuild) explaining how to do that. The only thing we need to know is that the project needs to be configured so it can get the code from the artifacts bucket (`pipeline-bucket-01`), at `NewestCode.zip`.

Once the hiccups are fixed, the Pipeline will execute automatically every time a new version of the source is uploaded.

## Conclusion

CodePipeline has a lot of features that I might explore in other posts. Here I show a minimal example of how to create a CodePipeline using AWS CLI.

Stages and actions can be added to the Pipeline by modifying the JSON file above and updating the Pipeline.

