---
id: 2875
title: Introduction to Salt
date: 2015-06-10T17:28:37+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2875
permalink: /2015/06/introduction-to-salt/
tags:
  - linux
  - salt
  - virtual_host
---
Salt is a server orchestration platform that allows you to manage your server infrastructure. It allows you to remotely configure all your servers(minions) from a single place(master). Salt also allows you to execute commands or scripts in a collection of servers at the same time and it will aggregate the output for you.

## Installation

You will typically have one master and multiple minions. In your master host you will need to install salt-master

```
sudo yum install salt-master
```

If you want your salt to start automatically every time your master is started you can use:

```
systemctl enable salt-master.service
```

You will also need to install something in your minions:

```
yum install salt-minion
```

And to have it start with the system:

```
systemctl enable salt-minion.service
```

<!--more-->

## Communicating with minions

Minions should be able to communicate with their master so they can connect to it. By default they will try to hit the **salt** host. To verify if your minion is able to connect to the master you can run this command in the minion:

```
sudo salt-minion -l debug
```

If the salt host doesn&#8217;t exist you will see something like this:

```
[ERROR   ] DNS lookup of 'salt' failed.
[ERROR   ] Master hostname: 'salt' not found. Retrying in 30 seconds
```

If the salt host doesn&#8217;t exist you can configure the location of the master on the configuration file(/etc/salt/minion). Search for the line **#master: salt** and replace it with something like:

```
master: 192.168.122.36
```

If you try to connect to the master you will see a different error now:

```
[ERROR   ] The Salt Master has cached the public key for this node, this salt minion will wait for 10 seconds before attempting to re-authenticate
[INFO    ] Waiting for minion key to be accepted by the master.
[INFO    ] Waiting 10 seconds before retry.
```

The communication between master and minions is protected by AES encription. Because of this, the master won&#8217;t accept any connections from unknown minions. You can see the list of keys known by the master using:

```
[anovelo@localhost ~]$ sudo salt-key -L
```

Which will return something like:

```
Accepted Keys:
Unaccepted Keys:
192.168.122.230
Rejected Keys:
```

The value you seen in the Unaccepted keys section is the IP address of the minion I was using to try to connect to the master. Since I know that is a good minion I can start accepting connections from it:

```
sudo salt-key -a 192.168.122.230
```

Now the minion should be able to connect to the master and start receiving commands from it. To test that your master can send commands to all its minions use this command:

```
sudo salt '*' test.ping
```

The salt command has the following signature:

```
salt [options] '<target>' <function> [arguments]
```

In the previous example we are using `*` as the target which means all minions. There are many ways of [targeting](http://docs.saltstack.com/en/latest/topics/targeting/index.html) minions so you can send commands only to the group of minions you are interested in. The function part is a function from a [list of built-in execution modules](http://docs.saltstack.com/en/latest/ref/modules/all/index.html#all-salt-modules), or you can [create your own modules with custom functions](http://docs.saltstack.com/en/latest/ref/modules/index.html).

This is a very shallow introduction to salt. I will try to write some more articles with examples of complex configurations.
