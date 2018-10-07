---
id: 3991
title: Docker networking
date: 2016-11-23T09:21:33+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3991
permalink: /2016/11/docker-networking/
categories:
  - Linux
tags:
  - docker
  - linux
---
I was trying to do some tuning on my servers network, but while I was at that I realized I couldn&#8217;t do it because I didn&#8217;t know anything about how Docker does networking. Since I need to move forward with my network configuration, I&#8217;m writing this article in the hope of understanding it better.

There are three networks automatically created by the Docker daemon when it starts: bridge, host and none. In this article I&#8217;m going to cover the bridge network since it is the default and most flexible one. You can see the networks using **docker network ls**:

```
NETWORK ID          NAME                DRIVER
d8a90e633c4a        bridge              bridge
b342b31dab76        host                host
48ac37e62c31        none                null
```

You will also see the bridge network interface created by Docker when running **ifconfig**:

```
docker0   Link encap:Ethernet  HWaddr 05:42:37:b5:36:7a
          inet addr:172.17.0.1  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:47ff:feb5:867a/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:221192 errors:0 dropped:0 overruns:0 frame:0
          TX packets:199761 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:69251108 (69.2 MB)  TX bytes:205171116 (205.1 MB)
```

<!--more-->

Every time you run a container using **docker run** it will be added to this network (unless you specifically tell it to run in a different network). You can open a terminal to a container:

```
docker exec -it some-container bash
```

And see the network configuration for the container:

```
eth0      Link encap:Ethernet  HWaddr ab:42:ac:11:00:03
          inet addr:172.17.0.3  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::42:acff:fe11:3/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:227247 errors:0 dropped:0 overruns:0 frame:0
          TX packets:165682 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:207945262 (207.9 MB)  TX bytes:67591606 (67.5 MB)
```

You can see here that an IP address in the same subnet as the bridge has been assigned to the container.

This is basically how the default network works inside the host. The bridge network allows all containers inside that network to communicate with each other by making them members of the same subnet and assigning them IP addresses. It&#8217;s important to understand this to move on, but in reality a production network configuration will most likely be different. We will probably have more than one host and we need containers inside a host to be able to communicate with containers from another host.

The docker0 bridge is only available inside the host it was created and is in principal not accessible from the outside. If you have worked with Docker, though, you might be wondering how does something like this work (More specifically, the **-p 8799:1337** part):

```
sudo docker run -d -p 8799:1337 c45917800ae2 nodejs /app/app.js
```

You have probably done this while developing. This expose a specific port in the container to a port in the host, making it this way available to the outside. Docker achieves this by using iptables rules. Here is how my NAT rules look for a host with one publicly visible container:

```
# iptables -t nat -L
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  anywhere             anywhere             ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  anywhere            !loopback/8           ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  172.17.0.0/16        anywhere
MASQUERADE  tcp  --  172.17.0.4           172.17.0.4           tcp dpt:http

Chain DOCKER (2 references)
target     prot opt source               destination
RETURN     all  --  anywhere             anywhere
DNAT       tcp  --  anywhere             anywhere             tcp dpt:http to:172.17.0.4:80
```

Lets decipher what all of that means. Starting from the top we find the PREROUTING chain; this chain will catch a packet as soon as it arrives to the machine.

```
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  anywhere             anywhere             ADDRTYPE match dst-type LOCAL
```

There is only one rule on this chain. If you are not familiar with iptables&#8217; rules, the first thing you want to look at is the source and destination columns. In this case it will match all packets from anywhere to anywhere. For this rule there is a special restriction applied: **ADDRTYPE match dst-type LOCAL**. This means that it will only match packets that are being sent to a local IP address (ADDRTYPE match dst-type LOCAL). Once we understand this, we want to look at the target, which basically is the action to take for that packet. The target in this scenario is DOCKER, which causes the packet to be sent to the DOCKER chain:

```
Chain DOCKER (2 references)
target     prot opt source               destination
RETURN     all  --  anywhere             anywhere
DNAT       tcp  --  anywhere             anywhere             tcp dpt:http to:172.17.0.4:80
```

<del datetime="2016-11-27T09:52:38+00:00">I&#8217;m actually a little confused about this part</del>(See update below) because the first rule appears to match all packets, and the RETURN target is supposed to return control to the calling chain (PREROUTING). Assuming this is what happens, the packet would be accepted since the default policy for the PREROUTING chain is to accept a packet. The part that confuses me is that this rule would prevent any packet from ever reaching the second rule. The second rule is necessary so packets from the outside can reach the container (so it must be being hit). It will match packets received by the host from anywhere and to anywhere, as long as they come from dpt(multicast packets) or http(port 80). If a packet matches it will be redirected to port 80 on 172.17.0.4. The DNAT rule takes care of changing the source IP address to an address in the correct subnet.

The OUTPUT chain is similar to the PREROUTING chain, but it deals with packets generated locally instead of coming from the outside:

```
Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
DOCKER     all  --  anywhere            !loopback/8           ADDRTYPE match dst-type LOCAL
```

This rule is a little tricky. It is similar to the PREROUTING rule, but the destination is different. The destination **!loopback/8** can actually be translated to **!127.0.0.1/8** which means, match ip addresses that are not in the 127.0.0.x range. This will match ip addresses like one of the container: 172.17.0.4. Here the target is DOCKER too, so the same treatment as per PREROUTING packets applies.

Finally, we have the POSTROUTING chain:

```
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  172.17.0.0/16        anywhere
MASQUERADE  tcp  --  172.17.0.4           172.17.0.4           tcp dpt:http
```

This chain will take care of packets that are going to be sent to a different network interface (through NAT). The POSTROUTING rules will take effect before the packet is transmitted. MASQUERADE is something I have probably used many times but I just found out it had a name.

When you get internet for your home, you will probably get a router that is connected to you ISP via a cable. Most likely this router communicates with your ISP with a single IP address, nevertheless, you can connect multiple computers to this router via ethernet or wireless. Each of the machines connected to the router has its own IP address, but the router has only a single address it uses to communicate with the world. Every time one of your computers sends a packet to the router, the router will change the origin IP address to be its public IP, but it will remember that this packet was generated by that machine. When the response comes, it will forward it to the correct machine. Masquerading is the process of changing the destination IP but making sure that the response arrives to the correct machine.

Now that we know what masquerading is, we can continue reading the rules. <del datetime="2016-11-27T09:52:38+00:00">The rules puzzle me a little</del>(see update below) because the first one will match all outgoing packets coming from the DOCKER bridge network. The second one seems to be redundant, it does masquerading for packets from the container to itself, but only on some ports. Although I&#8217;m not sure why the second rule would be necessary, what the first rule does is allow docker containers to communicate with the outside world.

These are the basics of how Docker sets up networking for containers. There are more complex configurations available, but these principals serve as a good base to understand how other configurations work.

## Update

Today I was checking some stuff on my servers and I accidentally discovered how the rules that puzzled me before work. The secret is using the -v modifier when listing the rules:

```
Chain POSTROUTING (policy ACCEPT 817K packets, 49M bytes)
 pkts bytes target     prot opt in     out     source               destination
48468 2965K MASQUERADE  all  --  any    !docker0  172.17.0.0/16        anywhere
    0     0 MASQUERADE  tcp  --  any    any     172.17.0.4           172.17.0.4           tcp dpt:http

Chain DOCKER (2 references)
 pkts bytes target     prot opt in     out     source               destination
 390K   23M RETURN     all  --  docker0 any     anywhere             anywhere
62848 3382K DNAT       tcp  --  !docker0 any     anywhere             anywhere             tcp dpt:http to:172.17.0.4:80
```

The -v modifier will turn on verbose output. The verbose output includes the number of packets and bytes that have matched each of the rules as well as two extra columns: in and out. These two columns work similarly to the source and destination columns but at the network interface level.

For the POSTROUTING chain we can see that the first rule only applies for packets that are not being sent to docker0. This makes sense because we don&#8217;t need/want to do masquerading when the packets are already on the bridge network.

For the DOCKER chain we can see that DNAT is only done when the packet doesn&#8217;t come from the bridge network, which in docker&#8217;s perspective is all that matters.
