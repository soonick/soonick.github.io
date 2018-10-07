---
id: 4389
title: Disable SSLv3 in HAProxy
date: 2017-11-02T04:37:59+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4389
permalink: /2017/11/disable-sslv3-in-haproxy/
categories:
  - Linux
tags:
  - linux
  - security
---
I just learned that my load balancer is [vulnerable to the POODLE attack due to SSL 3](https://blog.qualys.com/ssllabs/2014/10/15/ssl-3-is-dead-killed-by-the-poodle-attack). The recommended solution is to disable SSL 3.

I explained my [HAProxy setup](https://ncona.com/2016/07/simple-haproxy-setup/) in a previous post, and also how I do [SSL termination](https://ncona.com/2017/01/ssl-termination-with-ha-proxy/).

The section from my configuration I care about is:

```
frontend https-in
        bind *:443 ssl crt /certs/ncona.pem

        acl ncona-web-frontend hdr(host) -i ncona.com www.ncona.com

        use_backend ncona-web if ncona-web-frontend
```

This mode is called SSL offloading in HAProxy terms. Fixing it is as simple as adding a keyword (no-sslv3):

```
        bind *:443 ssl crt /certs/ncona.pem no-sslv3
```
