---
title: Introduction to AWS networking
author: adrian.ancona
layout: post
# date: 2020-05-06
# permalink: /2020/05/aws-code-pipeline/
tags:
  - aws
  - networking
  - architecture
---

A few months ago, I wrote an [introduction to networking for Google Cloud](/2018/06/introduction-to-networking-in-google-cloud/). Today I find myself working with AWS, so I'll write a similar post, but for AWS platform.

I'm going to be using [AWS CLI](/2020/03/introduction-to-aws-cli/) for my examples on this post.

## Concepts

- Virtual Private Cloud (VPC) - Refers to a network that is logically isolated from the rest of the world. The valid IPs in a VPC is represented by a CIDR (e.g. 10.0.0.0/16). A VPC is a regional resource (It can span a full region, but not accross regions)
- Subnet - A section of a VPC. Subnets exist in a single Availability Zone (AZ)
- Internet Gateway (IGW) - Component that allows traffic from the Internet to be routed to a VPC
- NAT (Network Address Translation) Gateway - Can be used to allow a Subnet to route traffic to the Internet, preventing the Internet from initiating inbound connections
- Elastic IP (EIP) - An IP address assigned to an AWS account. The IP address can be assigned to a resource, and moved to a different one in the future if necessary
- Route Table - Rules that determine how traffic will be routed. A Route Table is associated to a Subnet (A Subnet must have one (only one) associated Route Table, but a Route Table can be associated to multiple Subnets)
- Security Group (SG) - A virtual Firewall. Any EC2 instance must be attached to at least one SG. By default SG allow all outbound traffic and disallow all inbound traffic

## Our network

To aid our learning of networking on AWS, we are going to create a project with these characteristics:

- One VPC on us-west-2 (10.0.0.0/16)
  - One Subnet on us-west-2a (10.0.1.0/24)
      - One web server in this Subnet
  - One Subnet on us-west-2b (10.0.2.0/24)
    - One database server in us-west-2b
  - One IGW to allow the web server to receive requests from the Internet
    - An EIP will be assigned to this IGW
  - One NAT Gateway to allow the database to talk to the Internet (to get software updates)

## The VPC

The only thing we need to create a VPC is a CIDR:

```sh
aws --region us-west-2 ec2 create-vpc --cidr-block 10.0.0.0/16

{
    "Vpc": {
        "CidrBlock": "10.0.0.0/16",
        "DhcpOptionsId": "dopt-01f8da26b45386f24",
        "State": "pending",
        "VpcId": "vpc-031135882ad34a29b",
        "InstanceTenancy": "default",
        "Ipv6CidrBlockAssociationSet": [],
        "CidrBlockAssociationSet": [
            {
                "AssociationId": "vpc-cidr-assoc-007469b7e450dbac9",
                "CidrBlock": "10.0.0.0/16",
                "CidrBlockState": {
                    "State": "associated"
                }
            }
        ],
        "IsDefault": false,
        "Tags": []
    }
}
```

Let's add a name to the VPC, so it's easy to find:

```sh
aws --region us-west-2 ec2 create-tags \
    --resources vpc-031135882ad34a29b \
    --tags Key=Name,Value=OurNetworkVpc
```

## The Subnets

A Subnet must own a CIDR block that is a subset of the VPC it belongs to. To create our Subnets:

```sh
aws --region us-west-2 ec2 create-subnet \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-west-2a \
    --vpc vpc-031135882ad34a29b

{
    "Subnet": {
        "AvailabilityZone": "us-west-2a",
        "AvailableIpAddressCount": 251,
        "CidrBlock": "10.0.1.0/24",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false,
        "State": "pending",
        "SubnetId": "subnet-02c1474fc82961213",
        "VpcId": "vpc-031135882ad34a29b",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": []
    }
}

aws --region us-west-2 ec2 create-subnet \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-west-2b \
    --vpc vpc-031135882ad34a29b

{
    "Subnet": {
        "AvailabilityZone": "us-west-2b",
        "AvailableIpAddressCount": 251,
        "CidrBlock": "10.0.2.0/24",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false,
        "State": "pending",
        "SubnetId": "subnet-00b394a5337406759",
        "VpcId": "vpc-031135882ad34a29b",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": []
    }
}
```

Let's assign them some names:

```sh
aws --region us-west-2 ec2 create-tags \
    --resources subnet-02c1474fc82961213 \
    --tags Key=Name,Value=OurNetworkPublicSubnet

aws --region us-west-2 ec2 create-tags \
    --resources subnet-00b394a5337406759 \
    --tags Key=Name,Value=OurNetworkPrivateSubnet
```

## The IGW

To create an IGW:

```sh
aws --region us-west-2 ec2 create-internet-gateway
{
    "InternetGateway": {
        "Attachments": [],
        "InternetGatewayId": "igw-0bced9e2516da0233",
        "Tags": []
    }
}
```

Let's give it a name:

```sh
aws --region us-west-2 ec2 create-tags \
    --resources igw-0bced9e2516da0233 \
    --tags Key=Name,Value=OurNetworkIgw
```

To be able to use this IGW on our VPC, we need to attach it:

```sh
aws --region us-west-2 ec2 attach-internet-gateway \
    --internet-gateway-id igw-0bced9e2516da0233 \
    --vpc-id vpc-031135882ad34a29b
```

## The EIP

To allocate an EIP to our account:

```sh
aws --region us-west-2 ec2 allocate-address

{
    "PublicIp": "54.69.240.20",
    "AllocationId": "eipalloc-0983abb28decd1143",
    "Domain": "vpc"
}
```

## NAT Gateway 

To allow our private Subnet to talk to the Internet, we need to create a NAT Gateway in our public Subnet that will serve as the exit point for our database.

With our allocated EIP, we can create our NAT Gateway:

```sh
aws --region us-west-2 ec2 create-nat-gateway \
    --allocation-id eipalloc-0983abb28decd1143 \
    --subnet-id subnet-02c1474fc82961213

{
    "NatGateway": {
        "CreateTime": "2020-04-19T06:08:25.000Z",
        "NatGatewayAddresses": [
            {
                "AllocationId": "eipalloc-0983abb28decd1143"
            }
        ],
        "NatGatewayId": "nat-0a5d3194b64ea8950",
        "State": "pending",
        "SubnetId": "subnet-02c1474fc82961213",
        "VpcId": "vpc-031135882ad34a29b"
    }
}
```

## Route tables

At this point we have two Subnets, a NAT Gateway and one IGW. Now we need to configure our Subnets so:

- Public Subnet can be reached by the Internet
- Private Subnet can reach out to the Internet, but doesn't allow incomming connections

Let's start by creating the Route Table for the public Subnet:

```sh
aws --region us-west-2 ec2 create-route-table --vpc-id vpc-031135882ad34a29b

{
    "RouteTable": {
        "Associations": [],
        "PropagatingVgws": [],
        "RouteTableId": "rtb-00b9f349c67d99977",
        "Routes": [
            {
                "DestinationCidrBlock": "10.0.0.0/16",
                "GatewayId": "local",
                "Origin": "CreateRouteTable",
                "State": "active"
            }
        ],
        "Tags": [],
        "VpcId": "vpc-031135882ad34a29b"
    }
}
```

Let's give it a name:

```sh
aws --region us-west-2 ec2 create-tags \
    --resources rtb-00b9f349c67d99977 \
    --tags Key=Name,Value=OurNetworkPublicRt
```

And associate it to our public Subnet:

```sh
aws --region us-west-2 ec2 associate-route-table \
    --route-table-id rtb-00b9f349c67d99977 \
    --subnet-id subnet-02c1474fc82961213

{
    "AssociationId": "rtbassoc-0da67bc42d1cd9d07"
}
```

Now we need to configure the Route Table so traffic from the Subnet is routed to our IGW:

```sh
aws --region us-west-2 ec2 create-route \
    --route-table-id rtb-00b9f349c67d99977 \
    --gateway-id igw-0bced9e2516da0233 \
    --destination-cidr-block 0.0.0.0/0

{
    "Return": true
}
```

Our public Subnet Route Table is ready. Now, we need to configure our private Subnet.

Create the Route Table:

```sh
aws --region us-west-2 ec2 create-route-table --vpc-id vpc-031135882ad34a29b

{
    "RouteTable": {
        "Associations": [],
        "PropagatingVgws": [],
        "RouteTableId": "rtb-0bb038d47fdfdcf58",
        "Routes": [
            {
                "DestinationCidrBlock": "10.0.0.0/16",
                "GatewayId": "local",
                "Origin": "CreateRouteTable",
                "State": "active"
            }
        ],
        "Tags": [],
        "VpcId": "vpc-031135882ad34a29b"
    }
}
```

We give it a name:

```sh
aws --region us-west-2 ec2 create-tags \
    --resources rtb-0bb038d47fdfdcf58 \
    --tags Key=Name,Value=OurNetworkPrivateRt
```

And associate it to our private Subnet:

```sh
aws --region us-west-2 ec2 associate-route-table \
    --route-table-id rtb-0bb038d47fdfdcf58 \
    --subnet-id subnet-00b394a5337406759

{
    "AssociationId": "rtbassoc-037c9cb67125fa760"
}
```

This time, we want to point traffic to the internet to the NAT Gateway instead of the IGW:

```sh
aws --region us-west-2 ec2 create-route \
    --route-table-id rtb-0bb038d47fdfdcf58 \
    --nat-gateway-id nat-0a5d3194b64ea8950 \
    --destination-cidr-block 0.0.0.0/0

{
    "Return": true
}
```











## The Web Server

Now that our network is configured, we can proceed to create our Web Server instance.

```
aws --region us-west-2 ec2 run-instances \
    --subnet-id subnet-02c1474fc82961213 \
    --image-id ami-003634241a8fcdec0 \
    --instance-type t2.micro \
    --count 1
```
