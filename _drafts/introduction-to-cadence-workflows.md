---
title: Introduction to Cadence Workflows
author: adrian.ancona
layout: post
# date: 2021-01-13
# permalink: /2021/01/introduction-to-cadence-workflows
tags:
  - architecture
  - automation
  - java
  - programming
---

I previously wrote an [article about Amazon's SWF](https://ncona.com/2020/07/introduction-to-aws-simple-workflow-service/). Cadence is an open source alternative to SWF.

[Cadence](https://cadenceworkflow.io/) advertises itself as a Fault-Tolerant Stateful Code Platform, which is a little hard to understand. 

My translation in simple words would be that it is a robust way of running automated processes that need to be executed in order.

## Running Cadence

It's useful to see a small example before we look at the concepts in more detail, so let's start by getting Cadence running in our machine.

We just need to get their docker-compose file:

```bash
curl -O https://raw.githubusercontent.com/uber/cadence/master/docker/docker-compose.yml \
    && curl -O https://raw.githubusercontent.com/uber/cadence/master/docker/prometheus_config.yml
```

And start the service:

```bash
docker-compose up
```

## Creating a domain

All workflows need to belong to a domain. This is just a way to organize them so they are easier to find. Since this is a requirement, we need to create a domain before we can create workflows. We can use this command to create a domain in our server:

```bash
docker run --network=host --rm ubercadence/cli:master --do test-domain domain register -rd 1
```

The response should contains this message:

```bash
Domain test-domain successfully registered.
```

## Hello world workflow

I think the easiest way to understand how workflows work is by creating one. Here is very simple workflow with comments explaining what each part does:

```java
package cadence.helloworld;

import com.uber.cadence.client.WorkflowClient;
import com.uber.cadence.client.WorkflowClientOptions;
import com.uber.cadence.serviceclient.ClientOptions;
import com.uber.cadence.serviceclient.IWorkflowService;
import com.uber.cadence.serviceclient.WorkflowServiceTChannel;
import com.uber.cadence.worker.Worker;
import com.uber.cadence.worker.WorkerFactory;
import com.uber.cadence.workflow.Workflow;
import com.uber.cadence.workflow.WorkflowMethod;
import org.slf4j.Logger;

public class GettingStarted {
  private static final String DOMAIN = "test-domain";
  private static final String TASK_LIST = "HelloWorldList";

  private static Logger logger = Workflow.getLogger(GettingStarted.class);

  // This is called a workflow interface because it contains a method annotated with
  // @WorkflowMethod. This method is executed when a workflow is started. When the
  // method returns, the workflow is considered completed
  public interface HelloWorld {
    @WorkflowMethod
    void sayHello(String name);
  }

  public static class HelloWorldImpl implements HelloWorld {
    // Workflows can be passed arguments when they are started. This workflow
    // in particular accepts a string that will be logged as part of the greeting
    @Override
    public void sayHello(String name) {
      logger.info("Hello " + name + "!");
    }
  }


  public static void main(String[] args) {
    // ClientOptions.defaultInstance() creates a configuration to connect to a server
    // running on localhost:7933.
    // 7933 is the port that Cadence server exposes to communicate using the TChannel
    // protocol, so we use WorkflowServiceTChannel to create the service instance
    IWorkflowService workflowService =
        new WorkflowServiceTChannel(ClientOptions.defaultInstance());

    // Options for the client. Here we specify that we want to connect to DOMAIN
    WorkflowClientOptions options = WorkflowClientOptions.newBuilder()
        .setDomain(DOMAIN)
        .build();

    // Create a cadence client, the first argument is the cadence instance we want
    // to connect to. The second argument are options for the connection
    WorkflowClient workflowClient = WorkflowClient.newInstance(workflowService, options);

    // Create a worker that consumes work from the given TASK_LIST. We also register
    // HelloWorldImpl in the worker so it can handle that kind of work
    WorkerFactory factory = WorkerFactory.newInstance(workflowClient);
    Worker worker = factory.newWorker(TASK_LIST);
    worker.registerWorkflowImplementationTypes(HelloWorldImpl.class);

    // Start all the workers created by the worker factory
    factory.start();
  }
}
```

We can find the complete code at: https://github.com/soonick/ncona-code-samples/tree/master/introduction-to-cadence-workflows/hello-world

## Starting a workflow

Once we get the server and the worker started we need to trigger the workflow. One way we can do this is by using the cadence cli:

```bash
docker run --network=host --rm ubercadence/cli:master \
    --do test-domain \
    workflow start \
    --tasklist HelloWorldList \
    --workflow_type HelloWorld::sayHello \
    --execution_timeout 3600 \
    --input \"Jose\"
```

There are a few things to notice in this command. We use `--do test-domain` to set the domain where we want to start the workflow. We also specify the tasklist to use: `--tasklist HelloWorldList` (I'll explain more about task lists later in the article) and the workflow type, which is the interface name and method we want to execute: `--workflow_type HelloWorld::sayHello`. Lastly, we provide the input: `--input \"Jose\"`.

We will see the message `Hello Jose!` printed in the worker terminal.

We have executed our first workflow!

## Inspecting workflow history

Cadence server keeps track of all the information about the workflows that have been run. If we want to see all the workflows that have been run in a domain we can do:

```bash
docker run --network=host --rm ubercadence/cli:master --do test-domain workflow list
```

It will return something like this:

```bash
     WORKFLOW TYPE     |             WORKFLOW ID              |                RUN ID                |   TASK LIST    | IS CRON | START TIME | EXECUTION TIME | END TIME
  HelloWorld::sayHello | b978c542-6031-4317-ad80-e5dd78619cc9 | 6968b113-c029-4076-9694-cffa19bc0039 | HelloWorldList | false   | 23:24:25   | 23:24:25       | 23:24:25
  HelloWorld::sayHello | 3e6a4169-5cd1-42ba-b6ae-fc3aacb90a84 | 284b319c-d850-47f7-9b00-0e8c5bc9ed2c | HelloWorldList | false   | 23:15:26   | 23:15:26       | 23:15:26
  HelloWorld::sayHello | 71f0dc4e-4386-4a24-a621-c16a4534a328 | 48a5d95d-506b-42ad-ab76-7214936fb6c0 | HelloWorldList | false   | 21:24:42   | 21:24:42       | 21:24:43
  HelloWorld::sayHello | d5c423a4-296d-42a9-883a-2c60b2e8c61a | 794bb32e-102f-4775-8ae2-2384c298cbe0 | HelloWorldList | false   | 21:23:46   | 21:23:46       | 21:23:46
  HelloWorld::sayHello | ac0b1c9c-c287-45ee-9ce9-5de745ee91f8 | f05c4758-b4db-43cd-9adc-e564dc2a7160 | HelloWorldList | false   | 21:22:59   | 21:22:59       | 21:23:29
  HelloWorld::sayHello | 316a5c7b-a0b7-4622-bc15-d70a1a019ebc | b80e9f41-7046-4006-a877-d608c362b42b | HelloWorldList | false   | 21:22:33   | 21:22:33       | 21:22:33
```

To see more details about a specific workflow, we can use:

```
docker run --network=host --rm ubercadence/cli:master \
    --do test-domain \
    workflow show --workflow_id b978c542-6031-4317-ad80-e5dd78619cc9
```

This command will return something like this:

```
  1  WorkflowExecutionStarted    {WorkflowType:{Name:HelloWorld::sayHello},
                                  TaskList:{Name:HelloWorldList}, Input:["Jose"],
                                  ExecutionStartToCloseTimeoutSeconds:3600,
                                  TaskStartToCloseTimeoutSeconds:10,
                                  ContinuedFailureDetails:[], LastCompletionResult:[],
                                  OriginalExecutionRunID:6968b113-c029-4076-9694-cffa19bc0039,
                                  Identity:cadence-cli@colima,
                                  FirstExecutionRunID:6968b113-c029-4076-9694-cffa19bc0039,
                                  Attempt:0, FirstDecisionTaskBackoffSeconds:0}
  2  DecisionTaskScheduled       {TaskList:{Name:HelloWorldList},
                                  StartToCloseTimeoutSeconds:10,
                                  Attempt:0}
  3  DecisionTaskStarted         {ScheduledEventID:2,
                                  Identity:94637@MacBook-Pro-3.local,
                                  RequestID:49326583-5b63-4351-911c-d03a2484d514}
  4  DecisionTaskCompleted       {ExecutionContext:[],
                                  ScheduledEventID:2,
                                  StartedEventID:3,
                                  Identity:94637@MacBook-Pro-3.local}
  5  WorkflowExecutionCompleted  {Result:[],
                                  DecisionTaskCompletedEventID:4}
```

This gives us all the information that was used to trigger the workflow as well as all the steps the workflow took. A lot of the output might be hard to understand now, but they'll become clear later in the article.

## Workflow state
