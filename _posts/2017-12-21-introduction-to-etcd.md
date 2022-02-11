---
id: 4604
title: Introduction to etcd
date: 2017-12-21T03:49:44+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4604
permalink: /2017/12/introduction-to-etcd/
tags:
  - linux
  - networking
  - architecture
---
In previous posts I wrote a little about [distributed systems](http://ncona.com/2017/12/distributed-systems/) and the [Raft algorithm](http://ncona.com/2017/12/raft-for-reaching-consensus/). Today I&#8217;m going to look at one distributed key-value store that uses the Raft algorithm to achieve consistency and high availability.

From a client&#8217;s perspective, etcd will behave like any other key value store out there. It&#8217;s use of Raft underneath will make sure that there is only one leader at a given time and that the log is replicated to all nodes.

## Getting ready

For this exercise I&#8217;m going to create a 5-node cluster, but before we start there are a few things we need to decide.

By default each etcd nodes uses port 2380 for communicating with clients and port 2379 for server to server communication. We will keep this default behavior.

Each node in the cluster needs to be able to communicate with the rest of the nodes in the cluster. The number of nodes in the cluster and their location needs to be configured for the cluster to be able to do some work.

In normal conditions we would have each node in a different host with a different IP Address. This would allow us to say something like: You can find node A at 10.10.10.2.

Running the cluster in a single machine makes things challenging because they would all be sharing the same IP address. To walk around this issue, we will create our own docker network and work within this network.

<!--more-->

```
docker network create --subnet=10.10.10.0/24 etcdnet
```

From now on, when running a container we will attach it to this newly created network and we can specify which IP address we want to use. That fixes the problem about nodes finding each other.

One last thing to decide is where our nodes will store the data they manage. Storing information inside a container is generally not a good idea, so we will create a folder /etcd-data with a folder for each node.

We will be working with the following nodes:

| Name   | IP address  | Data folder       |
| ------ | ----------- | ----------------- |
| node-a | 10.10.10.11 | /etcd-data/node-a |
| node-b | 10.10.10.12 | /etcd-data/node-b |
| node-c | 10.10.10.13 | /etcd-data/node-c |
| node-d | 10.10.10.14 | /etcd-data/node-d |
| node-e | 10.10.10.15 | /etcd-data/node-e |

## Creating the cluster

We have decided what we want to build, now it&#8217;s time to start building it. Lets start our first node:

```bash
docker run \
  --volume=/etcd-data/node-a:/etcd-data \
  --net etcdnet \
  --ip 10.10.10.11 \
  --name node-a gcr.io/etcd-development/etcd:latest \
  /usr/local/bin/etcd \
  --data-dir=/etcd-data --name node-a \
  --initial-advertise-peer-urls http://10.10.10.11:2380 --listen-peer-urls http://0.0.0.0:2380 \
  --advertise-client-urls http://10.10.10.11:2379 --listen-client-urls http://0.0.0.0:2379 \
  --initial-cluster node-a=http://10.10.10.11:2380
```

We currently have a cluster with a single node running. Lets test it.

First we need a terminal to our container (so we can use etcdctl):

```
docker exec -it node-a sh
```

Then we can issue a few commands:

```bash
/ # etcdctl cluster-health
member 57641140d8f810cc is healthy: got healthy result from http://10.10.10.11:2379
cluster is healthy
/ # etcdctl set one uno
uno
/ # etcdctl get one
uno
/ # etcdctl get two
Error:  100: Key not found (/two) [4]
/ # etcdctl set two dos
dos
/ # etcdctl get two
dos
```

We have verified that it can actually receive requests and store information. Now lets add the rest of the nodes to achieve high availability. First we need to tell our current cluster that we will be adding nodes. We do this using etcdctl inside the container:

```
etcdctl member add node-b http://10.10.10.12:2380
```

This will spit some information out:

```
Added member named node-b with ID 8841b02a3b709613 to cluster

ETCD_NAME="node-b"
ETCD_INITIAL_CLUSTER="node-a=http://10.10.10.11:2380,node-b=http://10.10.10.12:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"
```

One thing to note is that at this point our cluster is down because the majority of the nodes are down (a two node cluster can&#8217;t take any failures).

```bash
# etcdctl cluster-health
member 57641140d8f810cc is unhealthy: got unhealthy result from http://10.10.10.11:2379
member 8841b02a3b709613 is unreachable: no available published client urls
cluster is unhealthy
```

Lets start the new node with the information we got from etcdctl:

```bash
docker run \
  --volume=/etcd-data/node-b:/etcd-data \
  --net etcdnet \
  --ip 10.10.10.12 \
  --name node-b gcr.io/etcd-development/etcd:latest \
  /usr/local/bin/etcd \
  --data-dir=/etcd-data --name node-b \
  --initial-advertise-peer-urls http://10.10.10.12:2380 --listen-peer-urls http://0.0.0.0:2380 \
  --advertise-client-urls http://10.10.10.12:2379 --listen-client-urls http://0.0.0.0:2379 \
  --initial-cluster node-a=http://10.10.10.11:2380,node-b=http://10.10.10.12:2380 \
  --initial-cluster-state existing
```

Our cluster is healthy again:

```bash
# etcdctl cluster-health
member 57641140d8f810cc is healthy: got healthy result from http://10.10.10.12:2379
member 8841b02a3b709613 is healthy: got healthy result from http://10.10.10.11:2379
cluster is healthy
```

We can repeat the process for the rest of the nodes, and we got ourselves a 5 node etcdcluster.

```bash
# etcdctl cluster-health
member 195eceb12cab7005 is healthy: got healthy result from http://10.10.10.15:2379
member 2a68cac58263240c is healthy: got healthy result from http://10.10.10.12:2379
member 8fe3d4161724a303 is healthy: got healthy result from http://10.10.10.14:2379
member 9af45209733fa31f is healthy: got healthy result from http://10.10.10.13:2379
member ffcf00e267752181 is healthy: got healthy result from http://10.10.10.11:2379
cluster is healthy
```

At this point, we can destroy any two nodes and the cluster will still be able to function normally. As nodes go down and come back up they will be synchronized using the rules of the raft algorithm.
