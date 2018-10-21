---
id: 3923
title: Securing your network with iptables
date: 2017-03-01T12:31:17+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3923
permalink: /2017/03/securing-your-network-with-iptables/
tags:
  - linux
  - networking
  - security
---
There comes a time on every system administrator&#8217;s life when they need to start being a little more conscious about security. That time has finally come for me.

I have a couple of servers in DigitalOcean where I run various sites and services. Some of these need to communicate with each other to do their job, for example, this blog runs in a server with Apache and PHP and communicates with another server that is running a MySQL database.

This is all good, but one of the most important rules of security is to only allow access to resources on a per-need basis. What this means is that from a security standpoint, nobody should be able to access a resource unless explicitly allowed. This rule applies to almost all scenarios that require some kind of access control and is a good idea to follow it whenever possible.

<!--more-->

To put some emphasis on the importance of this rule, I want to tell you a little story of a time when I didn&#8217;t follow it and there were great consequences.

A few years ago I was building a service that allowed access to certain resources. These resources were private to the company I used to work for, so they shouldn&#8217;t be visible to anybody else. This service provided an HTTP endpoint that exposed the information. The way I ensured that the person calling the endpoint was supposed to access that information was by adding a check for an Auth token when a specific endpoint was called.

When a GET request to /secret-resource was made, a function was executed and the code looked something like this:

```js
function listSecretResource(request) {
  if (!isValid(request.headers.authorization)) {
    return sendResponse(401);
  }

  // Code here only got executed if the user
  // was valid
}
```

This might not seem that bad, but it was a huge mistake. Short after that endpoint was delivered I was asked to create a new endpoint, but I forgot to add the check for the auth token:

```js
function listAnotherSecretResource(request) {
  // There was no check, so this code always
  // got executed
}
```

This caused the endpoint to be open to anybody, leaking secret information to the public. This could have been avoided by including an authorization check on all endpoints by default. This would mean that by default nobody without an access token can communicate with this service. Since some of the endpoints were actually public, we had to go to those endpoints and explicitly say that they could be accessed by anyone.

The previous example is at the code level, but iptables works at the network level. Although they work at different levels, the principal is the same. 

The problem I&#8217;m facing now is indeed at the network level. I have a MySQL server that requires a username and password to log-in, but can be accessed from anywhere in the world. Since at this moment I only want my blog to be able to access the database, I could use iptables to block all connections except for the ones coming from my blog&#8217;s IP address. I can create similar configurations for other services by blocking all connections and then only allowing the ones I know I want. The end result will be a more tightly secured network, and better sleep at night.

## Uncomplicated Firewall

How your system will handle a package is decided by iptables rules. Uncomplicated Firewall (ufw) is a tool that makes it easier to configure your firewall (iptables). Since it is the recommended tool for Ubuntu, I&#8217;m going to be using it to configure my servers.

I&#8217;m connected to my server using SSH and I want to make sure I&#8217;m not locked out of my server, so the first thing I did is open port 22:

```
sudo ufw allow 22
```

Note that this command allows everybody in the world to access port 22 on my server. This is fine for me because you need a valid SSH key to log into my server. If you want, you can have a more restrictive configuration. e.g. Allow only your home IP address.

After opening port 22 we can go ahead and enable ufw:

```
sudo ufw enable
```

After enabling ufw I tried restarting my server and SSHing back in to make sure it works fine. Back in the server I checked the status of the firewall:

```
ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22                         ALLOW IN    Anywhere
22 (v6)                    ALLOW IN    Anywhere (v6)
```

The _Default_ section shows that by default all incoming traffic is denied, which is what we want.

One problem with ufw is that it doesn&#8217;t show you all iptables in your system, just the rules it manages. In the previous output you can&#8217;t see that Docker is opening port 80 and allowing everyone to communicate with a server I am running on that machine. You can see the rules Docker added to iptables:

```
iptables -L

Chain FORWARD (policy DROP)
target     prot opt source               destination
DOCKER-ISOLATION  all  --  anywhere             anywhere
DOCKER     all  --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere             ctstate RELATED,ESTABLISHED
ACCEPT     all  --  anywhere             anywhere
ACCEPT     all  --  anywhere             anywhere
...

Chain OUTPUT (policy ACCEPT)
...

Chain DOCKER (1 references)
target     prot opt source               destination
ACCEPT     tcp  --  anywhere             172.17.0.2           tcp dpt:http

Chain DOCKER-ISOLATION (1 references)
target     prot opt source               destination
RETURN     all  --  anywhere             anywhere
```

For the specific case of Docker, we can tell it to not mess our iptables configuration:

```
mkdir /etc/systemd/system/docker.service.d

cat << EOF > /etc/systemd/system/docker.service.d/noiptables.conf
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon -H fd:// --iptables=false
EOF

systemctl daemon-reload
```

You can restart your server and the rules Docker added will be gone. If you don&#8217;t have anything else messing your iptables, you will only have port 22 open at this point.

At this point I have a service running on docker, but not accessible from the outside:

```
CONTAINER ID   IMAGE      COMMAND                  PORTS                NAMES
66191e736932   some-app   "nginx -g 'daemon ..."   0.0.0.0:80->80/tcp   some-app-container
```

If we want to make this service available we just need to open the port:

```
sudo ufw allow 80
```

In the future if I need other ports open I can use a similar command to open them. This way my server is my more secure since it only allows things I explicitly tell it to.
