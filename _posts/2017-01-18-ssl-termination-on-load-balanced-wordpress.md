---
id: 4081
title: SSL termination on load-balanced wordpress
date: 2017-01-18T12:08:13+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4081
permalink: /2017/01/ssl-termination-on-load-balanced-wordpress/
tags:
  - php
  - programming
---
Previously I wrote a post explaining how to do [SSL termination with Ha-proxy](http://ncona.com/2017/01/ssl-termination-with-ha-proxy/). It seemed to be working fine, but it was giving me problems about mixed content when loading my blog.

What was happening was that my blog was being served on **https://ncona.com**, but all the JS, CSS and links where being returned in **http**. This actually makes a lot of sense because the load balancer is requesting content using http and then forwarding this content to the browser.

Once the problem is understood, the solution is just a matter of finding out how to tell wordpress to render https content when Ha-proxy receives an https request. A way to do this is by sending a header to wordpress when the request came on port 443. We can do this in haproxy.cfg:

```
frontend https-in
        bind *:443 ssl crt /certs/ncona.pem
        reqadd X-Forwarded-Proto:\ https

        acl ncona-web-frontend hdr(host) -i ncona.com www.ncona.com

        use_backend ncona-web if ncona-web-frontend
```

The **reqadd** instruction will add a header to the request being sent to the backend. Now we can inspect for this header in **wp-config.php**:

```php
if ($_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
  $_SERVER['HTTPS'] = 'on';
  $_SERVER['SERVER_PORT'] = 443;
}
```

This solved the problem and I can finally serve my blog with https.

<!--more-->
