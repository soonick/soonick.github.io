---
title: AWS Code Pipeline
author: adrian.ancona
layout: post
# date: 2020-04-22
# permalink: /2020/04/identity-and-access-management-with-aws-iam/
tags:
  - aws
  - other tags
---

Code Pipeline is AWS' solution for continuos delivery. Its goal is to help developers automate builds, tests, deployments, etc.

## Concepts

Before we start creating our own pipelines, we need to get familiar with a few concepts.

- **Pipeline** - A workflow that defines the different stages a code change needs to go through
- **Stage** - A pipeline is divided into stages. Each stage starts in a new clean environment and can perform different actions depending on what it was configured to do
- **Action** - A specific set of operations (commands) to be executing on a set of artifacts (for example; build and run tests)

The concepts will make more sense once we start creating a pipeline. For now, the important thing to know is that a stage can have multiple actions and a pipeline can have multiple stages.

## Excutions

Every time a change needs to run through a pipeline, an `Execution` is created. There are a few useful things to know about executions:

- Each execution has a unique ID
- Valid execution statuses are: InProgress, Stopping, Stopped, Succeeded, Superseded, and Failed
- A stage can only run one execution at a given time
- If an execution reaches a stage that is already processing another change, the execution will wait for the stage to free before continuing
- If there is more than one execution waiting for a stage, the older executions will be **superseded** by newest one. This means the older executions will be marked as **Superseded** and will not continue through the pipeline. Only the newest execution will continue





https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome-get-started.html
