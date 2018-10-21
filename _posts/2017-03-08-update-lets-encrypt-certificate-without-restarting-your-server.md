---
id: 4199
title: 'Update let&#8217;s encrypt certificate without restarting your server'
date: 2017-03-08T03:16:42+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4199
permalink: /2017/03/update-lets-encrypt-certificate-without-restarting-your-server/
tags:
  - automation
  - linux
  - security
---
I started using HTTPS in my blog a few months ago and today came the time to renew my certificate. I thought I had automated the process correctly but it turns out for my configuration I have to take some extra steps.

[In my previous post](https://ncona.com/2017/01/free-https-with-lets-encrypt/) I suggested using this command:

```
21 7,19 * * * /home/user/certbot-auto renew --quiet --no-self-upgrade
```

But it tries to spin a server in port 80, and I&#8217;m already using port 80 for my blog, so the server fails to start.

There is another approach that allows you to renew your certificate without having to free port 80. It works by writing a file to a folder in your webroot and having let&#8217;s encrypt server read that file. This sounds pretty straight forward but it was actually a little tricky for me, since I&#8217;m using docker.

My blog runs WordPress inside a docker container. Inside the docker container the webroot is /var/www/html and this folder contains all wordpress files. I can&#8217;t write directly to this folder because it is inside the docker container, so I had to use a volume. I also can&#8217;t mount the whole /var/www/html folder because there are already files in that location inside the container. To make it work I had to mount to _/var/www/html/.well-known_, which is the folder certbot-auto creates.

<!--more-->

Once we know how we&#8217;ll make the file available to our container, we can put the file anywhere in the host. I chose to put it in /letsencrypt. The command I used to run my container is:

```
docker run -d --restart on-failure -e ALLOW_OVERRIDE=true -v /letsencrypt/.well-known:/var/www/html/.well-known --name ncona-container ncona:1
```

Then I can renew the certificate:

```
/home/user/certbot-auto certonly -n --webroot -w /letsencrypt -d ncona.com -d www.ncona.com
```

This generates the certificate as expected. But we still need to create the pem file:

```
cat /etc/letsencrypt/live/ncona.com/fullchain.pem /etc/letsencrypt/live/ncona.com/privkey.pem > /certs/ncona.pem && chmod go-rwx /certs/ncona.pem
```

I can now put this in CRON and next time things should work:

```
21 7,19 * * * /home/adrian/certbot-auto certonly -n --webroot -w /root/letsencrypt -d ncona.com -d www.ncona.com
42 22 * * * cat /etc/letsencrypt/live/ncona.com/fullchain.pem /etc/letsencrypt/live/ncona.com/privkey.pem > /root/apps/certs/ncona.pem && chmod go-rwx /root/apps/certs/ncona.pem
```
