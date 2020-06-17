---
title: Introduction to CloudFormation
author: adrian.ancona
layout: post
date: 2020-06-17
permalink: /2020/06/introduction-to-cloudformation/
tags:
  - architecture
  - automation
  - aws
  - productivity
---

CloudFormation is AWS' offering for modeling infrastructure as code. Its purpose is similar to that of [Salt](/2015/06/introduction-to-salt/) or [Terraform](/2018/05/terraform/).

## Getting started

CloudFormation allows us to define our infrastructure on `template` files written in JSON or YAML. The following examples show a template to create an EC2 instance:

```json
{
  "Description": "Create a single EC2 instance",
  "Resources": {
    "Host1": {
      "Type" : "AWS::EC2::Instance",
      "Properties": {
        "InstanceType": "t2.micro",
        "ImageId": "ami-003634241a8fcdec0"
      }
    }
  }
}
```

<!--more-->

The same template can be written using YAML, which results in a more compact file:

```yaml
Description: Create a single EC2 instance
Resources:
  Host1:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t2.micro
      ImageId: ami-003634241a8fcdec0
```

To actually create the resources defined in the template in an AWS account we need to create a stack:

```sh
aws cloudformation create-stack --stack-name my-first-stack --template-body file://template.yaml
{
    "StackId": "arn:aws:cloudformation:us-west-2:758883867384:stack/my-first-stack/2853bb60-9a87-11ea-91bd-0a7df06cf190"
}
```

When we issue a `create-stack` request, AWS validates the request and if it deems it valid, it returns a stack id to track the progress. The actual resources defined in the stack are created asynchronously. If we get the status of a stack right after creating it, we'll probably see it in `CREATE_IN_PROGRESS` status.

```bash
aws cloudformation describe-stacks --stack-name my-first-stack
{
    "Stacks": [
        {
            "StackId": "arn:aws:cloudformation:us-west-2:758883867384:stack/my-first-stack/eae85dc0-9b4f-11ea-bf8d-06e1bfa6e222",
            "StackName": "my-first-stack",
            "Description": "Create a single EC2 instance",
            "CreationTime": "2020-05-21T10:43:33.438Z",
            "RollbackConfiguration": {},
            "StackStatus": "CREATE_IN_PROGRESS",
            "DisableRollback": false,
            "NotificationARNs": [],
            "Tags": [],
            "EnableTerminationProtection": false
        }
    ]
}
```

If everything goes well, it will soon transition to `CREATE_COMPLETE`. An explanation of [all possible statuses](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html) can be found in the documentation.

## Debugging failures

There are a few things that can go wrong while creating a stack. A common but easy to fix problem is a syntax error. Let's see what happens when we introduce one in our template (Removed the semicolon after `Type`):

```yaml
Description: Create a single EC2 instance
Resources:
  Host1:
    Type AWS::EC2::Instance
    Properties:
      InstanceType: t2.micro
      ImageId: ami-003634241a8fcdec0
```

If we try to create a stack based on this template, we'll get a validation error:

```bash
aws cloudformation create-stack --stack-name my-first-stack --template-body file://template.yaml

An error occurred (ValidationError) when calling the CreateStack operation: Template format error: YAML not well-formed. (line 5, column 15)
```

A template can be used to create multiple stacks, but all of them need to have a different name. We would also see an error if we try to create a stack with a name that is already taken:

```bash
aws cloudformation create-stack --stack-name my-first-stack --template-body file://template.yaml

An error occurred (AlreadyExistsException) when calling the CreateStack operation: Stack [my-first-stack] already exists
```

The issues mentioned above are very easy to notice and fix, but there are other types of issues that happen asynchronously. That's the case of a missing property that is necessary to create a resource. Let's see what happens if we try to create an EC2 instance without specifying an `ImageId`:

```yaml
Description: Create a single EC2 instance
Resources:
  Host1:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t2.micro
```

The request is successful:

```bash
aws cloudformation create-stack --stack-name my-first-stack --template-body file://template.yaml
{
    "StackId": "arn:aws:cloudformation:us-west-2:758883867384:stack/my-first-stack/38a9ff30-9b52-11ea-a515-0af6392a9a8a"
}
```

But if we describe the stack, we'll see that it was rolled back:

```bash
aws cloudformation describe-stacks --stack-name my-first-stack
{
    "Stacks": [
        {
            "StackId": "arn:aws:cloudformation:us-west-2:758883867384:stack/my-first-stack/38a9ff30-9b52-11ea-a515-0af6392a9a8a",
            "StackName": "my-first-stack",
            "Description": "Create a single EC2 instance",
            "CreationTime": "2020-05-21T11:00:02.895Z",
            "DeletionTime": "2020-05-21T11:00:07.610Z",
            "RollbackConfiguration": {},
            "StackStatus": "ROLLBACK_COMPLETE",
            "DisableRollback": false,
            "NotificationARNs": [],
            "Tags": [],
            "EnableTerminationProtection": false
        }
    ]
}
```

In cases like this, we would want to know more about what happened. To do that, we can look at the stack events:

```bash
aws cloudformation describe-stack-events --stack-name my-first-stack
{
    "StackEvents": [
        ...
        {
            "StackId": "arn:aws:cloudformation:us-west-2:758883867384:stack/my-first-stack/38a9ff30-9b52-11ea-a515-0af6392a9a8a",
            "EventId": "Host1-CREATE_FAILED-2020-05-21T11:00:06.880Z",
            "StackName": "my-first-stack",
            "LogicalResourceId": "Host1",
            "PhysicalResourceId": "",
            "ResourceType": "AWS::EC2::Instance",
            "Timestamp": "2020-05-21T11:00:06.880Z",
            "ResourceStatus": "CREATE_FAILED",
            "ResourceStatusReason": "Property ImageId cannot be empty."
        },
        ...
    ]
}
```

The events show the steps AWS took as part of the stack creation. We can see that one of them tells us that `ImageId` can't be empty.

## Working with stacks

We have already seen how we can create a stack and describe it. Other common operations are deleting a stack:

```bash
aws cloudformation delete-stack --stack-name my-first-stack
```

And listing all the stacks:

```bash
aws cloudformation list-stacks
{
    "StackSummaries": [
        {
            "StackId": "arn:aws:cloudformation:us-west-2:758883867384:stack/my-first-stack/38a9ff30-9b52-11ea-a515-0af6392a9a8a",
            "StackName": "my-first-stack",
            "TemplateDescription": "Create a single EC2 instance",
            "CreationTime": "2020-05-21T11:00:02.895Z",
            "DeletionTime": "2020-05-21T11:00:07.610Z",
            "StackStatus": "ROLLBACK_COMPLETE"
        },
        {
            "StackId": "arn:aws:cloudformation:us-west-2:758883867384:stack/my-first-stack/4892d4e0-9b51-11ea-a987-06c2f8177814",
            "StackName": "my-first-stack",
            "TemplateDescription": "Create a single EC2 instance",
            "CreationTime": "2020-05-21T10:56:33.399Z",
            "DeletionTime": "2020-05-21T10:59:07.622Z",
            "StackStatus": "DELETE_COMPLETE"
        },
        ...
    ]
}
```

Notice that even deleted stacks are listed. If we care only about some statuses, we can show only those:

```bash
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE
```

## Parameters

Templates can accept parameters that can be used to create similar configurable stacks. Let's see how we can incorporate a parameter to a stack:

```yaml
Description: Create a single EC2 instance

Parameters:
  Host1InstanceType:
    Type: String
    Default: t2.micro

Resources:
  Host1:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref Host1InstanceType
      ImageId: ami-003634241a8fcdec0
```

There are a few things to point out. First of all, we define our parameters in a `Parameters` section. Then we declare a name for the parameter. In this case `Host1IntanceType`. For each parameter, we need to define a `Type`. I'll show a few examples of some available types, but you can find all in the [types reference](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html#parameters-section-structure-properties-type). In the example above, we also specified a default value for the parameter.

We can also see, how the parameter is referenced:

```yaml
InstanceType: !Ref Host1InstanceType
```

Since the only parameter on this template has a default value, we can start a stack with the command we used before:

```bash
aws cloudformation create-stack --stack-name stack-with-params --template-body file://template.yaml
```

If we want to use a different value for the instance type, we can specify it when we start the stack:

```bash
aws cloudformation create-stack --stack-name stack-with-params \
    --template-body file://template.yaml \
    --parameters ParameterKey=Host1InstanceType,ParameterValue=t2.nano
```

## Referencing resources

It's common to have a template create multiple resources and have connections between them. For example, we might want to create a security group and have an instance be part of this security group. Let' look at how we can do this:

```yaml
Description: Create a single EC2 instance

Parameters:
  Host1InstanceType:
    Type: String
    Default: t2.micro

Resources:
  SecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Allows incoming traffic on port 8080
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 8080
          ToPort: 8080
          CidrIp: 0.0.0.0/0

  Host1:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref Host1InstanceType
      ImageId: ami-003634241a8fcdec0
      SecurityGroups: [!Ref SecurityGroup]
```

There are a few things to unwrap here. First of all, we can see that we reference another resource the same way we reference parameters (using `Ref`):

```yaml
SecurityGroups: [!Ref SecurityGroup]
```

The square brackets (`[]`) indicate that `SecurityGroups` expects a list of security groups. If we were to add more security groups we could separate them with a comma (`,`):

```yaml
SecurityGroups: [!Ref SecurityGroup, !Ref AnotherSecurityGroup]
```

The template also show the long format for specifying a list of items. Currently `SecurityGroupIngress` receives a list of a single ingress rule, but we could add more than one. Each rule should be preceeded with a dash (`-`):

```yaml
SecurityGroupIngress:
  - IpProtocol: tcp
    FromPort: 8080
    ToPort: 8080
    CidrIp: 0.0.0.0/0
  - IpProtocol: tcp
    FromPort: 22
    ToPort: 22
    CidrIp: 0.0.0.0/0
```

## More about parameters

Let's look at an example template using different parameters:

```yaml
Description: Create demo infrastructure

Parameters:
  Host1InstanceType:
    Type: String
    Default: t2.micro
    AllowedValues:
      - t2.micro
      - t2.nano
    Description: Currently only t2.nano and t2.micro are supported
  IncomingPort:
    Type: Number
    MinValue: 1200
    MaxValue: 1300
    Description: Port that will be allowed incoming traffic
  IngressCidr:
    Type: String
    AllowedPattern: '((\d{1,3})\.){3}\d{1,3}/\d{1,2}'
    ConstraintDescription: A CIDR, for example, 10.0.0.0/24
    Description: CIDR that will be allowed to talk to the host
  AllowedAccounts:
    Type: List<Number>
    Description: Accounts that will be allowed to assume role
  AvailabilityZones:
    Type: CommaDelimitedList
    Description: AvailabilityZones to use for Auto Scaling Group
  BucketName:
    Type: String
    MinLength: 20
    MaxLength: 60
    Description: Name of bucket where files will be stored

Resources:
  SecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Allows incoming traffic on port 8080
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: !Ref IncomingPort
          ToPort: !Ref IncomingPort
          CidrIp: !Ref IngressCidr

  Host1:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref Host1InstanceType
      ImageId: ami-003634241a8fcdec0

  ExternalRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: 2012-10-17
        Statement:
          - Effect: Allow
            Action: sts:AssumeRole
            Principal:
              AWS: { Ref: AllowedAccounts }

  LaunchConfiguration:
    Type: AWS::AutoScaling::LaunchConfiguration
    Properties:
      ImageId: ami-003634241a8fcdec0
      InstanceType: t2.micro

  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      MaxSize: 1
      AvailabilityZones: !Ref AvailabilityZones
      MinSize: 0
      DesiredCapacity: 0
      LaunchConfigurationName: !Ref LaunchConfiguration

  Bucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Ref BucketName
```

The example above shows the use of some types that we haven't used before:

- `Number` - It can be a integer or a float (number with decimal point)
- `List<Number>` - A list of numbers
- `CommaDelimitedList` - A comma delimited list of strings

We also used some other features available to define parameters:

- `AllowedValues` - Defines a list of values that can be assigned to the parameter
- `MinValue` - Minumum valid value for a number
- `MaxValue` - Maximum valid value for a number
- `MinLength` - Minimum number of characters for a valid string
- `MaxLength` - Maximum number of characters for a valid string
- `AllowedPattern` - A regular expression that will be used to validate the value
- `ConstraintDescription` - A description to explain a regular expression defined with `AllowedPattern`. It is not mandatory, but it will give a clearer error message to users of the template

We can create a stack based on this template using this command:

```bash
aws cloudformation create-stack --stack-name stack-with-params \
    --template-body file://template.yaml \
    --parameters ParameterKey=IncomingPort,ParameterValue=1200  \
        ParameterKey=AllowedAccounts,ParameterValue=\"123456789012,987654321234\" \
        ParameterKey=AvailabilityZones,ParameterValue=\"us-west-2a,us-west-2b\" \
        ParameterKey=IngressCidr,ParameterValue=10.0.1.0/24 \
        ParameterKey=BucketName,ParameterValue=my-little-bucket-with-some-name \
    --capabilities CAPABILITY_IAM
```

Notice that for passing a list of numbers or a list of strings, we need to quote the list.

Another thing to notice is the use of `--capabilities`. I'm not going to cover capabilities in this article, but it's necessary to include the `CAPABILITY_IAM` if a template is going to create IAM resources.

## Functions

We have used `!Ref` to reference parameters in a template. `Ref` is one of CloudFormation's supported functions. All functions have a short form:

```yaml
InstanceType: !Ref Host1InstanceType
```

And a long form:

```yaml
InstanceType:
  Ref: Host1InstanceType
```

Functions provide some functionality that can be useful while creating more dynamic templates.

The [CloudFormation functions documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference.html) provides a reference of the available functions, so I'm just going to introduce some that are used often.

### Join

Joins values using the specified delimiter:

```yaml
!Join [",", [one, two, three]]
```

The results will be: `one,two,three`

### Split

Does the opposite to `Join`. Given a string it returns a list separated by the specified delimiter:

```yaml
!Split [",", "one,two,three"]
```

Returns `["one", "two", "three"]`

### GetAtt

Allows us to get an attribute from a resource. To see the list of attributes that can be retrieved, look at the documentation for the resource type:

```yaml
!GetAtt Host1.PrivateIp
```

Will return the private IP address that was assigned to the host.

### Select

Retrieve an element from a list of elements:

```yaml
!Select [2, [zero, one, two]]
```

Returns `two`.

### Sub

Provides a way to substitute parts of a template string with specified values.

```yaml
!Sub
  - "I like ${Food}, but I prefer ${Drink}
  - Food: Pizza
  - Drink: Beer
```

`Sub` will automatically replace parameters:

```yaml
!Sub "You chose instance type: ${Host1InstanceType}"
```

As well as [built in pseudo parameters](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html):

```yaml
!Sub "The region is: ${AWS::Region}"
```

### FindInMap

Given a map, it allows us to select a value.

To use this function we need to have a `Mappings` section in the template, for example:

```yaml
Mappings:
  NumbersMap:
    spanish:
      one: uno
      two: dos
    german:
      one: ein
      two: zwei
```

Let's say that we want to select the correct translation based on the language and number:

```yaml
!FindInMap
  - NumbersMap
  - spanish
  - two
```

This would return `dos`.

## Condition Functions

Condition functions allow us to conditionally create resources. This can be useful when we want to do things a little different based on the environment where the stack is being created (provided parameters, region, etc.)

Conditions can be declared in the `Conditions` section of a template:

```yaml
Conditions:
  CreateWebServer:
    !Equals [Ref: 'AWS::Region', us-east-1]
```

In the example above, `CreateWebServer` will be set to true, if the stack is being created in `us-east-1`.

A resource can then be created based on this condition:

```yaml
Host1:
  Type: AWS::EC2::Instance
  Condition: CreateWebServer
  Properties:
    InstanceType: t2.micro
    ImageId: ami-003634241a8fcdec0
```

In this case, the instance will only be created if `CreateWebServer` is true.

Conditions can be chained using `Or`, `And`, `If` and `Not`. [Conditions Functions documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-conditions.html) explains the syntax.

## Conclusion

This article covers some of the most fundamental topics related to CloudFormation. With this knowledge we will be able to understand most of the templates we find, write our own, and manipulate the stacks we create.
