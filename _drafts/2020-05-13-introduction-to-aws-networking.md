---
title: Introduction to AWS networking
author: adrian.ancona
layout: post
date: 2020-05-13
permalink: /2020/05/introduction-to-aws-networking/
tags:
  - architecture
  - aws
  - networking
  - security
---

A few months ago, I wrote an [introduction to networking for Google Cloud](/2018/06/introduction-to-networking-in-google-cloud/). Today I find myself working with AWS, so I'm going to explore networking on the AWS platform.

I'm going to be using [AWS CLI](/2020/03/introduction-to-aws-cli/) for my examples, so I recommend you install it and configure it before proceeding.

## Virtual Private Clouds (VPC), Subnets and Security Groups (SG)

To get started we need to get familiar with these 3 fundamental concepts:

- **Virtual Private Cloud (VPC)** - Refers to a network that is logically isolated from the rest of the world. A VPC is a regional resource (It can span a full region, but not accross regions)
- **Subnet** - A section of a VPC. Subnets exist in a single Availability Zone (AZ)
- **Security Group (SG)** - A virtual Firewall. Any EC2 instance must be attached to at least one Security Group. By default a Security Group allows all outbound traffic and disallow all inbound traffic

<!--more-->

An EC2 instance will always be part of a Subnet and have at least 1 (And up to 5) Security Group associated to it. Since there is not way to get around this, it's good to start by getting familiar with these first.

To see how these components work together in practice, we are going to run a web server in an EC2 instance.

From a Network perspective, we need a few things from our EC2 instance:
- A public IP address so we know where to find it
- Access to port 80, so we can connect to the web server
- Access to port 22, so we can SSH to the host

Let's start by creating the VPC. To do this we need to decide in which region we want to create the VPC, as well as a block of IPs that will be part of the VPC (in CIDR format). For this example I'm going to use `us-west-2` and `10.0.0.0/16`:

```sh
aws --region us-west-2 ec2 create-vpc --cidr-block 10.0.0.0/16

{
    "Vpc": {
        "CidrBlock": "10.0.0.0/16",
        "DhcpOptionsId": "dopt-0ad0217dccc81cf52",
        "State": "pending",
        "VpcId": "vpc-02f80e3f64618ce87",
        "InstanceTenancy": "default",
        "Ipv6CidrBlockAssociationSet": [],
        "CidrBlockAssociationSet": [
            {
                "AssociationId": "vpc-cidr-assoc-09f8967d3606aec68",
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

Let's add a name to the VPC, so it's easy to find in the future:

```sh
aws --region us-west-2 ec2 create-tags \
    --resources vpc-02f80e3f64618ce87 \
    --tags Key=Name,Value=OurNetworkVpc
```

Now, we can create a Subnet in our new VPC. If we don't specify an Availability Zone, one from the same region as the VPC will be randomly assigned. For my example, I'm going to use `us-west-2a`. We need to also define the block of IP addresses that will be part of the subnet (using CIDR):

```sh
aws --region us-west-2 ec2 create-subnet \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-west-2a \
    --vpc vpc-02f80e3f64618ce87

{
    "Subnet": {
        "AvailabilityZone": "us-west-2a",
        "AvailableIpAddressCount": 251,
        "CidrBlock": "10.0.1.0/24",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false,
        "State": "pending",
        "SubnetId": "subnet-0810371619b72f212",
        "VpcId": "vpc-02f80e3f64618ce87",
        "AssignIpv6AddressOnCreation": false,
        "Ipv6CidrBlockAssociationSet": []
    }
}
```

Let's give it a name:

```sh
aws --region us-west-2 ec2 create-tags \
    --resources subnet-0810371619b72f212 \
    --tags Key=Name,Value=OurNetworkPublicSubnet
```

Before we can create an EC2 instance, we need to create a Security Group:

```sh
aws --region us-west-2 ec2 create-security-group \
    --group-name web-server-sg \
    --description "Used by web servers" \
    --vpc-id vpc-02f80e3f64618ce87

{
    "GroupId": "sg-0c7648d368c273f03"
}
```

We could create our EC2 instance now, but since we will need to SSH to it at some point, we need to first create a key pair. In order to create the pem file, we are going to use `jq` to parse the JSON response. Make sure it is installed, then run this command:

```sh
aws --region us-west-2 ec2 create-key-pair \
    --key-name web-ssh \
    | jq -r ".KeyMaterial" > web-ssh.pem

chmod 400 web-ssh.pem
```

Let's now create our EC2 instance:

```sh
aws --region us-west-2 ec2 run-instances \
    --subnet-id subnet-0810371619b72f212 \
    --security-group-ids sg-0c7648d368c273f03 \
    --image-id ami-003634241a8fcdec0 \
    --instance-type t2.micro \
    --associate-public-ip-address \
    --key-name web-ssh \
    --count 1

{
    "Groups": [],
    "Instances": [
        {
            ...
            "InstanceId": "i-05c303dd339f13fa9",
            ...
            "PrivateIpAddress": "10.0.1.197",
            ...
    ],
    ...
}
```

We selected the Security Group and Subnet to use, as well as `--associate-public-ip-address`, which assigns a public address to the instance. The image-id and instance-type, are not important for networking purposes.

To get the public IP address that was assigned to the instance, we need to describe it:

```sh
aws --region us-west-2 ec2 describe-instances \
    --instance-ids i-05c303dd339f13fa9

{
    "Reservations": [
        {
            "Groups": [],
            "Instances": [
                {
                    ...
                    "NetworkInterfaces": [
                        {
                            "Association": {
                                "IpOwnerId": "amazon",
                                "PublicDnsName": "",
                                "PublicIp": "54.212.194.253"
                            },
                            ...
                        }
                    ],
                    ...
                }
            ],
            ...
        }
    ]
}
```

So far, we have a network (`10.0.0.0/16`) that is completely isolated. We also have an EC2 instance that is part of this network, but also has a public IP that makes it part of the Internet.

We can try to SSH to our instance:

```sh
ssh -i "web-ssh.pem" ubuntu@54.212.194.25
```

But we will fail.

Even when the EC2 instance is part of the Internet, it is currently inaccessible because Security Groups don't allow any ingress traffic by default.

Let's modify our Security Group to allow ingress traffic to ports 80 and 22:

```sh
aws --region us-west-2 ec2 authorize-security-group-ingress \
    --group-id sg-0c7648d368c273f03 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws --region us-west-2 ec2 authorize-security-group-ingress \
    --group-id sg-0c7648d368c273f03 \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0
```

We just allowed the Security Group to receive requests, but there is one piece missing before we can actually access our instance from the Internet.

## Internet Gateway (IGW)

IGW allows traffic from the Internet to be routed to a VPC. Without an IGW, it is impossible for the VPC to access or be accessed by the Internet.

To create an IGW:

```sh
aws --region us-west-2 ec2 create-internet-gateway

{
    "InternetGateway": {
        "Attachments": [],
        "InternetGatewayId": "igw-003a64ece7949e849",
        "Tags": []
    }
}

```

Let's give it a name:

```sh
aws --region us-west-2 ec2 create-tags \
    --resources igw-003a64ece7949e849 \
    --tags Key=Name,Value=OurNetworkIgw
```

For an IGW to be useful, it needs to be attached to a VPC. Let's attach it to the VPC we created:

```sh
aws --region us-west-2 ec2 attach-internet-gateway \
    --internet-gateway-id igw-003a64ece7949e849 \
    --vpc-id vpc-02f80e3f64618ce87
```

The last thing we need to do is modify the Route Table for the VPC. A Route Table is a list of rules that defines how traffic will be routed.

To find the Route Table for our VPC, we can `describe-route-tables`:

```sh
aws --region us-west-2 ec2 describe-route-tables \
    --filters Name=vpc-id,Values=vpc-02f80e3f64618ce87

{
    "RouteTables": [
        {
            "Associations": [
                {
                    "Main": true,
                    "RouteTableAssociationId": "rtbassoc-0ade5f91b72a50d33",
                    "RouteTableId": "rtb-0bbdfecd58a0ac1b8"
                }
            ],
            "PropagatingVgws": [],
            "RouteTableId": "rtb-0bbdfecd58a0ac1b8",
            "Routes": [
                {
                    "DestinationCidrBlock": "10.0.0.0/16",
                    "GatewayId": "local",
                    "Origin": "CreateRouteTable",
                    "State": "active"
                }
            ],
            "Tags": [],
            "VpcId": "vpc-02f80e3f64618ce87"
        }
    ]
}
```

Currently there is a single route that allows traffic within the VPC. We are going to add one that allows traffic from the Internet:

```sh
aws --region us-west-2 ec2 create-route \
    --route-table-id rtb-0bbdfecd58a0ac1b8 \
    --gateway-id igw-003a64ece7949e849 \
    --destination-cidr-block 0.0.0.0/0

{
    "Return": true
}
```

## Testing our work

If we followed the steps correctly, we should finally be able to SSH to the instance:

```sh
ssh -i "web-ssh.pem" ubuntu@54.212.194.25
```

Since we also opened port 80, we can start a server on the instance:

```sh
sudo python -m SimpleHTTPServer 80
```

And access it from a browser (`http://54.212.194.25`).


## Conclusion

This post covered some fundamental concepts of networking on AWS, and how they can be used together to allow us to create a simple infrastructure. In a future posts I will expand this example to show other useful technologies and patterns.
