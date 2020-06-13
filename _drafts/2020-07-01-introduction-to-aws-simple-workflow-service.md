---
title: Introduction to Simple Workflow Service (SWF)
author: adrian.ancona
layout: post
date: 2020-07-01
permalink: /2020/07/introduction-to-aws-simple-workflow-service/
tags:
  - architecture
  - automation
  - aws
  - productivity
---

In this post I'm going to explore Simple Workflow Service (SWF) available in AWS.

To understand what SWF is good for, we need to first understand what a workflow is. [Wikipedia defines it](https://en.wikipedia.org/wiki/Workflow) as follows:

> A workflow consists of an orchestrated and repeatable pattern of activity, enabled by the systematic organization of resources into processes that transform materials, provide services, or process information. It can be depicted as a sequence of operations, the work of a person or group, the work of an organization of staff, or one or more simple or complex mechanisms.

In computer systems we care about the part about processing information. Some things that could be modeled as workflows:

- **Deployment pipeline**: We could receive some code as input and then build it in a worker machine. We can run tests in parallel in different machines. If all tests pass we can deploy the binaries to another set of machines.
- **Coordinate shipments**: A user buys a product on an online store and the order is placed on a system. A human monitors this system and takes care of finding the products in a warehouse and shipping them to the correct address. When the shipment is made, the information is entered in a system. The workflow notices this information an e-mails the user the shipping details.
- **Asynchronous image processing**: A system uploads files to a system for processing (let's say, create thumbnails). A workflow uses multiple workers to execute the task. If any of the machines fails while processing a set of files, they same work can be taken over by another worker.

<!--more-->

Those are some high level examples. In this post I'm going to go over one example in more detail.

## Components

Before we start building a workflow, let's learn a little about the components of an SWF:

- **Workflow**: A set of activities, and some logic that defines how these work together to achieve some objective
- **Domain**: A workflow lives in a domain. A Domain can contain multiple workflows. Workflows in different domains can't interact.
- **Execution**: An instance of the workflow with its associated state
- **Event**: Represents a change on the state of an execution
- **Starter**: A program, or person that starts and execution
- **Activity**: A type of task that needs to be performed, such as: resizing images, running tests, etc
- **Task**: An invocation of an activity
- **Worker**: Program that performs tasks
- **Decider**: Program that defines the logic for the workflow

## Machine repair workflow

To help us get familiar with SWF, we are going to create a workflow to model the process for fixing a broken machine in a fleet. It will look something like this:

{% graphviz %}
digraph MyGraph {
  maintenance [label="Change machine status to maintenance",shape=box]
  drain [label="Drain services",shape=box]
  fix [label="Human fixes the machine",shape=box]
  reimage [label="Reimage the machine",shape=box]
  available [label="Change machine status to available",shape=box]
  finish [label="Finish",shape=box]

  maintenance -> drain
  drain -> fix
  drain -> reimage
  fix -> available
  reimage -> available
  available -> finish
  maintenance -> finish
}
{% endgraphviz %}


This workflow can be used in a datacenter that runs a lot of machines. We can have the workflow probe machines to see if they are working well. If it notices something wrong, it sets the machine state as `maintenance` in a database. If it doesn't find anything wrong, it finishes the execution.

Once a machine is drained we'll do two things. We'll have a person take a look at the machine and fix it and we'll take the oportunity to reimage the machine so we have clean machine when it comes back.

Once the repair and the reimage are done, we can set the state back to `available` and finish the execution.

## Getting ready

For our activities and the decider, we are going to need the AWS SDK. In this section I'm going to show how to get it ready.

We'll use Ruby for our examples, since it's easy to run and it's very well supported. The latest version of the Ruby SDK at the time of this writing is version 3. We'll create a `Gemfile` with dependencies:

```ruby
source 'https://rubygems.org'

gem 'aws-sdk-swf', '~> 1'
```

We can then install them using:

```sh
bundle install
```

The AWS SDK will need to communicate with AWS, so we'll need some credentials, these credentials can be set in environment variables like this:

```sh
export AWS_ACCESS_KEY_ID=<your key id>
export AWS_SECRET_ACCESS_KEY=<your secret>
```

## Activities

Each of the boxes in the diagram above is an `activity`. Activities can be pretty self contained, so we'll start building those.

An activity works by polling the workflow for pending tasks. If it finds that there is a task it can perform, it does so, and returns a result back. Polling then continues until there is more work to do.

Our activities will share some code with the decider, so let's create a base class that will be shared between them (`workflow_base.rb`):

```ruby
require 'aws-sdk-swf'

class WorkflowBase
  DOMAIN_NAME = 'datacenter-domain'
  REGION = 'ap-southeast-2'
  TASK_LIST_NAME = 'repairs-workflow-task-list'
  VERSION = '14'

  def initialize
    @swf = Aws::SWF::Client.new(region: REGION)
    register_domain(REGION, DOMAIN_NAME)
  end

  # Register a domain for our workflow (if it doesn't already exist)
  def register_domain(region, domain_name)
    swf = Aws::SWF::Client.new(region: region)
    begin
      swf.register_domain({
        name: domain_name,
        workflow_execution_retention_period_in_days: '3'
      })
      puts "Domain #{domain_name} registered"
    rescue Aws::SWF::Errors::DomainAlreadyExistsFault
      puts "Domain #{domain_name} already exists"
    end
  end
end
```

This class defines some constants that are shared between the decider and activities. It also initializes the SWF client and register the domain if it doesn't yet exist.

Because of the way SWF works, it is best if the code for all our activities is handled by a single program. This program will poll for any new tasks in the domain. Every time it sees a task it will execute it and send the result back to SWF. Because each task is blocking, we could spin many copies of this program to allow tasks to be executed in parallel if we wanted to.

The activities handler (`activities.rb`):

```ruby
require 'aws-sdk-swf'
require_relative 'workflow_base.rb'

class Activities < WorkflowBase
  ACTIVITIES = [
    'probe_machines',
    'drain_machine',
    'fix_machine',
    'reimage_machine',
    'enable_machine'
  ]

  def initialize
    super()
    register_activities
    poll
  end

  # Register the activities with the domain
  def register_activities()
    ACTIVITIES.each do |activity|
      begin
        @swf.register_activity_type({
          domain: DOMAIN_NAME,
          name: activity,
          version: VERSION,
          # Maximum time it can take to process an activity
          default_task_start_to_close_timeout: '60'
        })
        puts "Activity #{activity} registered"
      rescue Aws::SWF::Errors::TypeAlreadyExistsFault
        puts "Activity #{activity} already exists"
      end
    end
  end

  # Poll the domain for tasks for this activity
  def poll
    while true
      options = {
        domain: DOMAIN_NAME,
        task_list: {
          name: TASK_LIST_NAME
        }
      }
      task = @swf.poll_for_activity_task(options)

      if task.task_token == nil
        puts 'Polling expired for activities expired. Trying again'
        next
      end

      if !ACTIVITIES.include?(task.activity_id)
        raise "Activity #{task.activity_id} unknown"
      end

      # If execute is successfull, it will return the result, otherwise ti will
      # throw
      puts "Executing #{task.activity_id}"
      begin
        # Call the method for the activity
        result = send(task.activity_id, task, task.input)

        puts "Completing #{task.activity_id}"
        @swf.respond_activity_task_completed({
          task_token: task.task_token,
          # SWF doesn't provide a way to know which activity this result
          # belongs to, so we'll prepend the result with it
          result: "#{task.activity_id}:#{result}"
        })
      rescue => e
        puts e
        puts "Failing #{task.activity_id}"
        @swf.respond_activity_task_failed({
          task_token: task.task_token,
          reason: @failure
        })
      end
    end
  end

  def probe_machines(task, input)
    # Because this is just an example and I don't actually have machines to test,
    # I'm going to use some mock data
    machines = [
      'machine-A459Z',
      'machine-M3992',
      'machine-A873R'
    ]

    machines.each do | machine |
      # A machine is bad, set it to maintenance
      if check_machine(machine) == 'FAIL'
        # In a real scenario we would update the database with the new state
        puts "Set machine #{machine} to maintenance"
        return machine
      end
    end

    puts 'No bad machines found'
    return ''
  end

  # Randomly decide if it's drained. In a real scenario we would communicate with
  # the machine, or check a database
  def drain_machine(task, input)
    puts "Draining machine #{input}"
    random_number = rand(5)
    if random_number == 4
      puts 'Machine is drained'
      return
    end

    raise "#{input} is not drained"
  end

  # In real life we would check if a human has marked the task as fixed. In this
  # case, we'll just sleep and use a random number
  def fix_machine(task, input)
    puts "Check if machine #{input} is fixed"
    sleep(1)
    random_number = rand(2)
    if random_number == 1
      puts "Machine #{input} has been fixed"
      return
    end

    raise "#{input} is not fixed yet"
  end

  # In real life we would use something like chef to re-image the machine here
  # we'll just sleep and use a random number
  def reimage_machine(task, input)
    puts "Reimaging #{input}"
    sleep(1)
    random_number = rand(2)
    if random_number == 1
      puts "Machine has been reimaged"
      return
    end

    raise "#{input} reimage still in progress"
  end

  # Pretend we re-enabled the machine
  def enable_machine(task, input)
    puts "Marking #{input} as available"
  end

  # Returns a random state for a machine
  def check_machine(machine)
    random_number = rand(5)
    if random_number == 4
      return 'FAIL'
    end

    return 'SUCCESS'
  end
end

Activities.new
```

The most important part of the code above is the polling loop. The `poll_for_activity_task` method, will initiate a connection with SWF and will return an activity to execute if there is one available. If there are no activities to execute for 60 seconds, it will return an empty `task_token`. If that happens we just continue polling again.

The code to handle each of the activities is just dummy code to pretend we are doing some work.

## Decider

The decider is the most complex part of the workflow. It takes care of making decisions on what needs to be done next. Because of the way we get data form SWF, making these decisions requires some grunt work over all the available events for the execution.

Let's look at the code (`repairs_workflow.rb`):

```rb
require 'aws-sdk-swf'
require_relative 'workflow_base.rb'

class RepairsWorkflow < WorkflowBase
  WORKFLOW_NAME = 'repairs-workflow'

  def initialize
    super
    register_workflow
    poll
  end

  def register_workflow
    begin
      @swf.register_workflow_type({
        domain: DOMAIN_NAME,
        name: WORKFLOW_NAME,
        version: VERSION,
        # Maximum time the decider can take to make a decision about this task
        default_task_start_to_close_timeout: '15'
      })
      puts "Workflow #{WORKFLOW_NAME} registered"
    rescue Aws::SWF::Errors::TypeAlreadyExistsFault
      puts "Workflow #{WORKFLOW_NAME} already exists"
    end
  end

  def poll
    while true
      options = {
        domain: DOMAIN_NAME,
        task_list: {
          name: TASK_LIST_NAME
        }
      }
      task = @swf.poll_for_decision_task(options)

      if task.task_token == nil
        puts "Polling expired for decision task. Trying again"
        next
      end

      process_events(task.workflow_execution.workflow_id, task.task_token, task.events)
    end
  end

  def process_events(workflow_id, token, events)
    # events contains all the event history for this workflow execution.
    # The lowest indexes [0] contains the oldest events. The first event is
    # always WorkflowExecutionStarted.
    # `events` can span multiple pages, in which case we would need to make
    # extra requests to get the other pages. We are not taking care of that
    # scenario in this example
    pending = 0
    in_progress = 0
    completed = 0
    results = {}
    events.each do | event |
      case event.event_type
        # This means at some point an activity was scheduled. It will either fail
        # or be grabbed by a worker
        when 'ActivityTaskScheduled'
          pending += 1
        # Activity couldn't be scheduled. This means something is wrong in the
        # workflow
        when 'ScheduleActivityTaskFailed'
          puts "There was a failure scheduling an activity"
        # A worker grabbed the task
        when 'ActivityTaskStarted'
          pending -= 1
          in_progress += 1
        # A task finished unsuccessfully
        when 'ActivityTaskFailed', 'ActivityTaskTimedOut'
          in_progress -= 1
        # A task completed successfully
        when 'ActivityTaskCompleted'
          if event.activity_task_completed_event_attributes
            parts = event.activity_task_completed_event_attributes.result.split(':')
            results[parts[0]] = parts[1]
          end
          completed += 1
          in_progress -= 1
      end
    end

    decide_task(workflow_id, token, completed, pending, in_progress, results)
  end

  # - If there are no `pending`, `in_progress` or `completed` activities, we
  #   need to schedule 'probe_machines'
  # - If 1 task has completed and the result includes a machine, we need to
  #   schedule 'drain_machine'. If there is no machine in the result, we can
  #   finish the workflow
  # - If 2 tasks have completed we need to schedule both 'fix_machine' and
  #   'reimage_machine'
  # - If 3 tasks have completed, it means that one of our parallel tasks has
  #   completed, but not the other. If it's still in progress, or pending we
  #   don't need to do anything. If that's not the case, we need to reschedule
  #   the missing task
  # - If 4 tasks have completed we need to schedule 'enable_machine'
  # - If 5 tasks have completed we need to can finish the workflow
  def decide_task(workflow_id, token, completed, pending, in_progress, results)
    puts "Completed: #{completed} Pending: #{pending} In progress: #{in_progress}"
    if completed == 0 && pending == 0 && in_progress == 0
      schedule_tasks(token, ['probe_machines'])
      return
    end

    if completed == 1 && pending == 0 && in_progress == 0
      if !results['probe_machines']
        # If there are no results, we can terminate the workflow
        end_execution(workflow_id)
      else
        schedule_tasks(token, ['drain_machine'], results['probe_machines'])
      end
      return
    end

    if completed == 2 && pending == 0 && in_progress == 0
      schedule_tasks(token, ['reimage_machine', 'fix_machine'], results['probe_machines'])
      return
    end

    if completed == 3 && pending == 0 && in_progress == 0
      # Figure out which one completed and schedule the other one
      if results.has_key?('fix_machine')
        schedule_tasks(token, ['reimage_machine'], results['probe_machines'])
      else
        schedule_tasks(token, ['fix_machine'], results['probe_machines'])
      end
      return
    end

    if completed == 4 && pending == 0 && in_progress == 0
      schedule_tasks(token, ['enable_machine'], results['probe_machines'])
      return
    end

    if completed == 5
      end_execution(workflow_id)
    end
  end

  def schedule_tasks(token, activities, input = nil)
    puts "Scheduling #{activities.join(',')}"
    decisions = []
    activities.each do |activity|
      decisions.push({
        decision_type: 'ScheduleActivityTask',
        schedule_activity_task_decision_attributes: {
          activity_type: {
            name: activity,
            version: VERSION
          },
          task_list: {
            name: TASK_LIST_NAME
          },
          input: input,
          activity_id: activity,
          # Time the workflow will wait for this task to be assigned to a worker
          schedule_to_start_timeout: '600',
          # Time the workflow will wait for this task to complete
          schedule_to_close_timeout: '3600',
          # Used for heartbeats. This example doesn't use them, so just setting
          # to the same value as schedule_to_close_timeout
          heartbeat_timeout: '3600'
        }
      })
    end
    @swf.respond_decision_task_completed({
      task_token: token,
      decisions: decisions
    })
  end

  def end_execution(id)
    puts "Terminating workflow"
    @swf.terminate_workflow_execution({
      domain: DOMAIN_NAME,
      workflow_id: id
    })
  end
end

RepairsWorkflow.new
```

I added comments explaining how we process the events and how we decide which activity needs to be executed next. `process_events` Looks through and figures out how many events have been completed and how many are in progress. `decide_task` schedules the next task based on the data from `process_events`.

## Starter

The last thing we need for our workflow is the something to trigger an execution. We'll have a little program do this (`execution_starter.rb`):

```ruby
require_relative 'workflow_base.rb'

class ExecutionStarter < WorkflowBase
  WORKFLOW_NAME = 'repairs-workflow'

  def initialize
    super
    @swf.start_workflow_execution({
      domain: DOMAIN_NAME,
      workflow_id: SecureRandom.uuid,
      workflow_type: {
        name: WORKFLOW_NAME,
        version: VERSION
      },
      task_list: {
        name: TASK_LIST_NAME
      },
      execution_start_to_close_timeout: '36000',
      child_policy: 'TERMINATE'
    })
  end
end

ExecutionStarter.new
```

## Testing the workflow

Now that we have the pieces ready, we need to open a terminal window with the activities:

```sh
ruby activities.rb
```

Another window with the decider:

```sh
ruby repairs_workflow.rb
```

Then, we can start our workflow:

```sh
ruby execution_started.rb
```

## Conclusion

Using SWF turned out to be a lot more complicated than I expected. Having to parse all to events to figure out which activity goes next, seems error prone and makes the code confusing. The documentation is also not very clear on how this should be done, so hopefully this example help people interested.


