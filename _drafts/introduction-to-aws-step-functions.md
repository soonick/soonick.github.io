---
title: Introduction to AWS step functions
author: adrian.ancona
layout: post
# date: 2020-07-08
# permalink: /2020/07/introduction-to-aws-step-functions/
tags:
  - architecture
  - automation
  - aws
---

In a previous post I showed [how to create workflows using SWF](/2020/07/introduction-to-aws-simple-workflow-service/). In this post I'm going to show how to create workflows using step functions and try to explain some of the differences between the two approaches.

## State machines

Step functions model workflows using state machines. We can define our state machines using [Amazon States Language](https://docs.aws.amazon.com/step-functions/latest/dg/concepts-amazon-states-language.html). A simple state machines looks like this:

```json
{
  "Comment": "My sample state machine",
  "StartAt": "InitialState",
  "States": {
    "InitialState": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-west-2:111111111111:function:myFunction",
      "Comment": "Calls my little function",
      "End": true
    }
  }
}
```

There are a few things we can see here:

- `StartAt`: Defines the initial state for the state machine
- `States`: Contains all our states
- `End`: Can be used to mark a state as a terminal
- `Type`: There are different kinds of states. In the example above, the state will call a lambda function







httpe://docs.aws.amazon.com/step-functions/latest/dg/welcome.html

