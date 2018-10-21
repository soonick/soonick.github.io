---
id: 3771
title: Simple HAProxy setup
date: 2016-07-14T09:32:02+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3771
permalink: /2016/07/simple-haproxy-setup/
tags:
  - docker
  - haproxy
  - linux
---
I&#8217;m migrating a few web apps from a shared web server to a Digital Ocean droplet. Since I&#8217;m going to be hosting more than one application in the same machine I need a proxy that will direct traffic to the correct application based on the domain name.

I decided to use HAProxy because I have never used it and because in the future I can extend it to also do load balancing if necessary.

Since I&#8217;m moving a domain that I already own from one shared server to a Digital Ocean droplet, the process I&#8217;m going to follow is going to be something like this:

  1. Set up my application in the droplet so it runs in a port different to port 80
  2. Set up HAProxy so it runs on port 80 and routes all traffic coming from the correct domain name to my application
  3. Change DNS configuration so traffic from my application domain is now sent to the droplet

<!--more-->

After I&#8217;m done with those steps my web application will be served using HAProxy from my droplet. At this point adding more applications will be a simple matter of changing the configuration.

[<img src="/images/posts/haproxy.jpg" alt="haproxy" />](/images/posts/haproxy.jpg)

I want to focus on the HAProxy part so I&#8217;m not going to go into much detail on how I set up the application. This also varies a lot based on the type of application. For this specific scenario I&#8217;m going to use an application running in a Docker container. The application will be exposed in port 9999 of the machine.

After the application is ready, it is time to set up HAProxy. To make the installation and configuration of HAProxy easy to reproduce, I will use Docker again. The [official HAProxy image](https://hub.docker.com/_/haproxy/) is a good place to start. The Dockerfile for my HAProxy looks like this:

```docker
FROM haproxy:alpine
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
```

The interesting part now, is configuring haproxy so it routes traffic from my application&#8217;s domain name to my application server. Here is how my haproxy.cfg file looks:

```
global
    log 127.0.0.1 local0
    maxconn 4096

defaults
    log global
    mode http
    option httplog
    option dontlognull
    retries 3
    redispatch
    maxconn 2000
    contimeout 5000
    clitimeout 50000
    srvtimeout 50000

frontend http-in
    bind *:80
    acl myapp-frontend hdr(host) -i mydomain.com
    use_backend myapp-backend if myapp-frontend

backend myapp-backend
    balance roundrobin
    option http-server-close
    server myapp-server-1 myapp-server-hostname:80 check
```

The global and defaults section are sensible defaults for most proxies. The parts that I had to modify were the frontend and backend sections:

```
frontend http-in
    bind *:80
    acl myapp-frontend hdr(host) -i mydomain.com
    use_backend myapp-backend if myapp-frontend
```

The frontend keyword is used to define a frontend (A set of sockets accepting client connections). For this scenario we name our frontend http-in, but it could be named anything. This frontend will be listening on port 80. We use the acl keyword to define a rule that will match if the host equals mydomain.com. Then we use the use_backend to route all requests that match that acl to the correct backend.

```
backend myapp-backend
    balance roundrobin
    option http-server-close
    server myapp-server-1 myapp-server-hostname:80 check
```

As with the frontend definition, we define a name for our backend. This name is used in our frontend to define where to redirect traffic if the acl is matched. I set the load balancing method to roundrobin, although in this case it doesn&#8217;t really matter because I have only one server. The http-server-close option will close the connection to your server once a request is made but will keep the connection to the client open in case it wants to request more files (this connection will be closed after a timeout). Lastly we define the servers that are part of this backend. In this case just one server that can be located at myapp-server-hostname:80 is added. We assign a name of myapp-server-1 to this server and enable health checks.

This is now all set up in my droplet, but it is not really testable since typing mydomain.com in the browser will redirect to the application in the old server. The last step is to change the DNS settings so mydomain.com redirects to the new server, but if things are not working correctly the site would be down until problems are fixed.

An easy way to test that things are working correctly is by temporarily adding an entry in your hosts file linking mydomain.com to the IP address of the new server. This way, when you type mydomain.com in the browser will redirect to the server where HAProxy is running. HAProxy will then look at the hostname and redirect to the correct backend.

Once this step is verified it should be safe to change the DNS settings and kill the old server.
