---
id: 4060
title: SSL termination with HA-Proxy
date: 2017-01-11T12:02:43+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4060
permalink: /2017/01/ssl-termination-with-ha-proxy/
tags:
  - docker
  - haproxy
  - linux
---
SSL termination refers to the process of terminating the encrypted connection at the load balancer and handling all internal traffic in an unencrypted way. This means that traffic between your load balancer and internal services (or between internal services) will not be encrypted, so you should make sure your network is secure. If you have your own data center, you can trust your network, otherwise you should set up a VPN so traffic can&#8217;t be sniffed.

Terminating SSL at the load balancer has a few advantages:

  * Single place responsible of managing encryption and decryption of traffic
  * Centralized place to store certificates
  * The load balancer can analyze the traffic and take special actions based on this
  * The load balancer can modify the request and response if necessary

A somewhat common scenario of wanting the load balancer to modify the request is adding headers to HTTP requests. More specifically, it is common to have the load balancer add a **X-Forwarded-For** header, which includes the IP address where the request originated. Without this header, all requests would look like they originated in the load balancer.

<!--more-->

## Creating the pem file

I assume you already have an SSL certificate ready. If not, you can follow my post to [learn how to get a Let&#8217;s Encrypt certificate for free](https://ncona.com/2017/01/free-https-with-lets-encrypt/).

I explain my [Ha-proxy setup in a previous article](http://ncona.com/2016/07/simple-haproxy-setup/). Since I run my Ha-proxy in a Docker container, I will include the steps I followed to make the certificate available to the container.

Ha-proxy expects the certificate and the key to be concatenated in a single file(in that order: certificate then key). This command will create the concatenated file and put it in the folder where I want it to be:

```
cat /etc/letsencrypt/live/ncona.com/fullchain.pem /etc/letsencrypt/live/ncona.com/privkey.pem > /services/ha-proxy/ncona.pem
```

The folder where you put the certificate doesn&#8217;t really matter. We will later tell Docker to make this file available to the container. It is a good idea to make this file only accessible to the root user and the root group:

```
chmod go-rwx /services/ha-proxy/ncona.pem
```

If you followed my [article to obtain the certificate](https://ncona.com/2017/01/free-https-with-lets-encrypt/), you also have a cron job that will update it before it expires. We want our load balancer to use the new certificate once it is renewed so we should also put the above commands in a cron job:

```
42 22 * * * cat /etc/letsencrypt/live/ncona.com/fullchain.pem /etc/letsencrypt/live/ncona.com/privkey.pem > /services/ha-proxy/ncona.pem && chmod go-rwx /services/ha-proxy/ncona.pem
```

This will move the pem file that Ha-proxy needs to its correct location everyday at 22:42 hours.

## Ha-proxy configuration

The first thing you might want to do is add this to your **defaults** section:

```
option forwardfor
```

This instructs Ha-proxy to add the X-Forwarded-For header to each request. This header includes the IP address where the request originated so it might be useful for your services.

We also need to add a new frontend:

```
frontend https-in
        bind *:443 ssl crt /certs/ncona.pem

        acl ncona-web-frontend hdr(host) -i ncona.com www.ncona.com

        use_backend ncona-web if ncona-web-frontend
```

This frontend will receive requests on port 443 and forward them to the right backend if they match the domain name. You can see that we are referencing the certificate at /certs/ncona.pem, which is not the same location as above(/services/ha-proxy/ncona.pem). This is because my ha-proxy runs in a container and I&#8217;m going to copy the certificate to that location later in this post.

My ncona-web backend looks like this:

```
backend ncona-web
        redirect scheme https if !{ ssl_fc }
        balance roundrobin
        server ncona-web-1 ncona-web:80 check
```

The **redirect** instruction redirects HTTP connections to HTTPS. If this is not something you want, you can omit it.

Lastly we want to make the certificate accessible to the container. We can do this by mounting the folder where the certificate is into the container. It would look something like this:

```
docker run -p 80:80 -p 443:443 --restart=on-failure -d --link=ncona-container:ncona-web --name haproxy-container haproxy-image -v /services/ha-proxy/ncona.pem:/certs/ncona.pem
```

Now my Ha-proxy is configured to do SSL termination for ncona.com.
