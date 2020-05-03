---
title: Introduction to AWS VPC Gateway endpoints
author: adrian.ancona
layout: post
date: 2020-06-03
permalink: /2020/06/introduction-to-aws-vpc-gateway-endpoints/
tags:
  - architecture
  - aws
  - networking
  - security
---

In my path to learning about networking on AWS I have written a few articles:

- [Introduction to AWS networking](/2020/05/introduction-to-aws-networking/)
- [Setting up a bastion host on AWS](/2020/05/setting-up-a-bastion-host-on-aws/)
- [Introduction to AWS NAT Gateway](/2020/05/introduction-to-aws-nat-gateway/)

This time I'm going to write about a way to allow a private EC2 instance to communicate with an AWS service without having to go through the public Internet. At the time of this writing, there are two services that provide VPC Gateway endpoints: S3 and DynamoDB.

We might want to use a VPC Gateway endpoint to improve security and decrease latency when a service we own needs to use S3 or DynamoDB. Without VPC Gateway endpoints, we would have our private instance use a NAT Gateway to reach the Internet (Including any AWS service). With a VPC Gateway endpoint the traffic stays inside AWS network, making it faster and safer.

<!--more-->

## Prerequisites

Before we create our VPC Gateway endpoint, we need to do some setup. We are going to create the following resources:

- VPC - All our resources will be created here
- Internet Gateway - Will allow our public Subnet to be accessed from the Internet
- Public Subnet - We will create a Bastion so we can access the private instance
- Bastion host - Entry point for our network
- Private Subnet - For the private instance
- Private host - Host that is not accessible from the Internet

```sh
# Create the VPC
aws --region us-west-2 ec2 create-vpc --cidr-block 10.0.0.0/16

{
    "Vpc": {
        "CidrBlock": "10.0.0.0/16",
        "DhcpOptionsId": "dopt-0ad0217dccc81cf52",
        "State": "pending",
        "VpcId": "vpc-08131cb1198aa69c0",
        "InstanceTenancy": "default",
        "Ipv6CidrBlockAssociationSet": [],
        "CidrBlockAssociationSet": [
            {
                "AssociationId": "vpc-cidr-assoc-0d7a234041ce01b90",
                "CidrBlock": "10.0.0.0/16",
                "CidrBlockState": {
                    "State": "associated"
                }
            }
        ],
        "IsDefault": false
    }
}

# The public Subnet
aws --region us-west-2 ec2 create-subnet \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-west-2a \
    --vpc vpc-08131cb1198aa69c0

{
    "Subnet": {
        "AvailabilityZone": "us-west-2a",
        "AvailableIpAddressCount": 251,
        "CidrBlock": "10.0.1.0/24",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false,
        "State": "pending",
        "SubnetId": "subnet-08eaa5bd38c07ae76",
        "VpcId": "vpc-08131cb1198aa69c0",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": []
    }
}

# The Internet Gateway
aws --region us-west-2 ec2 create-internet-gateway
{
    "InternetGateway": {
        "Attachments": [],
        "InternetGatewayId": "igw-04be7d038952e4472",
        "Tags": []
    }
}

# Attach IGW to VPC
aws --region us-west-2 ec2 attach-internet-gateway \
    --internet-gateway-id igw-04be7d038952e4472 \
    --vpc-id vpc-08131cb1198aa69c0

# Route table to allow Subnet access to the Internet
aws --region us-west-2 ec2 create-route-table \
    --vpc-id vpc-08131cb1198aa69c0

{
    "RouteTable": {
        "Associations": [],
        "PropagatingVgws": [],
        "RouteTableId": "rtb-00d099bc43b198ca3",
        "Routes": [
            {
                "DestinationCidrBlock": "10.0.0.0/16",
                "GatewayId": "local",
                "Origin": "CreateRouteTable",
                "State": "active"
            }
        ],
        "Tags": [],
        "VpcId": "vpc-08131cb1198aa69c0"
    }
}

# Add a route to the Internet
aws --region us-west-2 ec2 create-route \
    --route-table-id rtb-00d099bc43b198ca3 \
    --gateway-id igw-04be7d038952e4472 \
    --destination-cidr-block 0.0.0.0/0

# Associate the route table to the public Subnet
aws --region us-west-2 ec2 associate-route-table \
    --route-table-id rtb-00d099bc43b198ca3 \
    --subnet-id subnet-08eaa5bd38c07ae76

# Security group for Bastion
aws --region us-west-2 ec2 create-security-group \
    --group-name bastion-sg \
    --description "Bastion SG" \
    --vpc vpc-08131cb1198aa69c0

{
    "GroupId": "sg-0e9bd12c5a6cbd79e"
}

# Allow incoming traffic on port 22 to Bastion
aws --region us-west-2 ec2 authorize-security-group-ingress \
    --group-id sg-0e9bd12c5a6cbd79e \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

# Key-pair for Bastion
aws --region us-west-2 ec2 create-key-pair \
    --key-name bastion-key \
    | jq -r ".KeyMaterial" > bastion-key.pem

# Bastion host
aws --region us-west-2 ec2 run-instances \
    --subnet-id subnet-08eaa5bd38c07ae76 \
    --security-group-ids sg-0e9bd12c5a6cbd79e \
    --image-id ami-003634241a8fcdec0 \
    --instance-type t2.micro \
    --associate-public-ip-address \
    --key-name bastion-key \
    --count 1

{
    "Groups": [],
    "Instances": [
        {
            ...
            "PrivateIpAddress": "10.0.1.175",
            ...
    ],
    ...
}

# The private Subnet
aws --region us-west-2 ec2 create-subnet \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-west-2b \
    --vpc vpc-08131cb1198aa69c0

{
    "Subnet": {
        "AvailabilityZone": "us-west-2b",
        "AvailableIpAddressCount": 251,
        "CidrBlock": "10.0.2.0/24",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false,
        "State": "pending",
        "SubnetId": "subnet-0693d03c424d9996f",
        "VpcId": "vpc-08131cb1198aa69c0",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": []
    }
}

# Key-pair for private host
aws --region us-west-2 ec2 create-key-pair \
    --key-name private-host-key \
    | jq -r ".KeyMaterial" > private-host-key.pem

# Security Group for private host
aws --region us-west-2 ec2 create-security-group \
    --group-name private-sg \
    --description "Private hosts" \
    --vpc vpc-08131cb1198aa69c0

{
    "GroupId": "sg-018b8bba3ad0ba79f"
}

# Allow SSH from Bastion
aws --region us-west-2 ec2 authorize-security-group-ingress \
    --group-id sg-018b8bba3ad0ba79f \
    --protocol tcp \
    --port 22 \
    --source-group sg-0e9bd12c5a6cbd79e

# Start Private EC2 instance. This instance will use AWS CLI, so we need to use
# an Amazon Linux image
aws --region us-west-2 ec2 run-instances \
    --subnet-id subnet-0693d03c424d9996f \
    --security-group-ids sg-018b8bba3ad0ba79f \
    --image-id ami-0d6621c01e8c2de2c \
    --instance-type t2.micro \
    --key-name private-host-key \
    --count 1

{
    "Groups": [],
    "Instances": [
        {
            ...
            "PrivateIpAddress": "10.0.2.139",
            ...
    ],
    ...
}
```

If you don't understand what we did above, I recommend you look into the articles I mentioned at the beginning of this post.

If everything went well, we'll be able to SSH to our private host using the bastion. From there we can try to access S3 and the Internet and see it fail:

```sh
# This fails
ping ncona.com

# This fails too
aws --region us-west-2 s3 ls
```

## Creating a VPC Gateway endpoint

As I mentioned before, Gateway endpoints are available only for S3 and DynamoDB. In this example, I'm going to show how to create an endpoint to S3.

Currently there is no way easy way to list all gateway endpoints, but since we are creating one for S3, we can use this command to get the endpoint:

```sh
aws --region us-west-2 ec2 describe-vpc-endpoint-services \
    --filters "Name=service-name,Values=*s3*"

{
    "ServiceNames": [
        "com.amazonaws.us-west-2.s3"
    ],
    "ServiceDetails": [
        {
            "ServiceName": "com.amazonaws.us-west-2.s3",
            "ServiceType": [
                {
                    "ServiceType": "Gateway"
                }
            ],
            ...
        }
    ]
}
```

We will need the endpoint name when we create the VPC endpoint.

When we create a gateway endpoint, we can specify which route table we want to attach it to. We haven't created a route table for our private Subnet. Let's do it now:

```sh
aws --region us-west-2 ec2 create-route-table \
    --vpc-id vpc-08131cb1198aa69c0

{
    "RouteTable": {
        "Associations": [],
        "PropagatingVgws": [],
        "RouteTableId": "rtb-089bbe033ac851c74",
        "Routes": [
            {
                "DestinationCidrBlock": "10.0.0.0/16",
                "GatewayId": "local",
                "Origin": "CreateRouteTable",
                "State": "active"
            }
        ],
        "Tags": [],
        "VpcId": "vpc-08131cb1198aa69c0"
    }
}

aws --region us-west-2 ec2 associate-route-table \
    --route-table-id rtb-089bbe033ac851c74 \
    --subnet-id subnet-0693d03c424d9996f
```

We can now create our gateway endpoint:

```sh
aws --region us-west-2 ec2 create-vpc-endpoint \
    --vpc-id vpc-08131cb1198aa69c0 \
    --service-name com.amazonaws.us-west-2.s3 \
    --route-table-ids rtb-089bbe033ac851c74

{
    "VpcEndpoint": {
        "VpcEndpointId": "vpce-006e0130682efa1e9",
        "VpcEndpointType": "Gateway",
        "VpcId": "vpc-08131cb1198aa69c0",
        "ServiceName": "com.amazonaws.us-west-2.s3",
        "State": "available",
        "PolicyDocument": "{\"Version\":\"2008-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"*\",\"Resource\":\"*\"}]}",
        "RouteTableIds": [
            "rtb-089bbe033ac851c74"
        ],
        "SubnetIds": [],
        "Groups": [],
        "PrivateDnsEnabled": false,
        "NetworkInterfaceIds": [],
        "DnsEntries": [],
        "CreationTimestamp": "2020-05-03T00:15:50.000Z"
    }
}
```

Since we didn't specify a policy, the default is being used. This policy allows this endpoint to access all resources by anybody. If we wanted to limit who can use this endpoint and which resources they can access, we can modify this policy.

With the VPC Gateway endpoint attached to our private Subnet, we can now reach S3, without allowing access to the public Internet:

```sh
# This fails
ping ncona.com

# This works
aws --region us-west-2 s3 ls
```

## Conclusion

VPC Gateway endpoints are an easy way to allow your private services to use S3 and DynamoDB without giving them access to the Internet.
