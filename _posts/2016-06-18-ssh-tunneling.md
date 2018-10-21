---
id: 3700
title: SSH tunneling
date: 2016-06-18T13:26:00+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3700
permalink: /2016/06/ssh-tunneling/
tags:
  - automation
  - linux
  - ssh
---
I have found SSH tunneling very useful for two main scenarios:

&#8211; I want to access something that can&#8217;t be accessed from my local computer
  
&#8211; I want someone to access something in my computer

Lets look first at accessing something that can&#8217;t be accessed from my local computer. The easiest way to explain is with an example. I&#8217;m sitting at my desk with my laptop and I want to connect to my production database to run some queries. For security reasons, I can&#8217;t access my production database directly from my desk. As a matter of fact, for security reasons there is only one way you can access my production database, and this is from my application server. I have specifically denied all access to my database from all IP addresses except from the IP address where I&#8217;m running an application that uses the database.

So, what do I do when I want to run queries in my database? I SSH into my application server and connect to my database from there. This works, but there are scenarios where it would be easier if I could just connect directly from my laptop (e.g. I want to use a graphical client for connecting to my DB). We can solve this by creating an SSH tunnel.

<!--more-->

Lets assume my production database is MySQL, runs on port 3306 and the host name is private.awesome.db. What we want to do is basically be able to connect to private.awesome.db on port 3306 through the application server. We can do this with SSH because we have all we need:

&#8211; The host and port we want to connect to but we can&#8217;t access (private.awesome.db:3306)
  
&#8211; A machine we can SSH into that gives us access to that host and port (Our application server. Lets call it: public.awesome.app)
  
&#8211; A machine with an SSH client and an available port we want to use for tunneling (This will be my laptop and we can use any available port. Lets use 9876)

With this information, creating the tunnel is easy if we know the format:

```
ssh -L [bind_address:]port:host:hostport
```

As you can see, bind_address is optional and is usually good to leave it out:

```
ssh -nNT -L 9876:private.awesome.db:3306 user@public.awesome.app
```

You can see that I added the some flags (-nNT). These are to prevent SSH from giving us a terminal since we don&#8217;t need it for creating a tunnel. We can leave this command running and connect to the production database as if it was running locally on port 9876:

```
mysql -udbuser -h127.0.0.1 -P 9876 -p
```

And with that the problem is solved.

Now, lets look at the other scenario: I want to give someone access to something in my computer. For this, lets assume I have a server running in my laptop and I want to show it to a friend. My friend is in another country, so I can&#8217;t just tell him to come over and look at my screen. I also don&#8217;t have a public IP address, so I can&#8217;t just give him an IP address he can connect to.

What I do have is an internet facing server that has a publicly accessible IP address. Since I have SSH access to this server, I can create a tunnel that routes the traffic from one port in that server to another port in my computer.

For security reasons, SSH doesn&#8217;t allow access to forwarded ports by default. We need to configure the SSH daemon on the server so it allows external connections to forwarded ports. Add this line:

```
GatewayPorts yes
```

To /etc/ssh/sshd_config and restart the SSH daemon:

```
sudo service ssh restart
```

We are ready to create the tunnel:

```
ssh -nNT -R 9876:localhost:9999 user@myhost
```

What we are saying here is that we want to open port 9876 on the remote server and connect it to localhost:9999. You can give now the url myhost:9876 to your friend and he will be able to access the local server.
