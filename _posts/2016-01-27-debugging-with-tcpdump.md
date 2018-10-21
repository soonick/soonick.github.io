---
id: 3446
title: Debugging with tcpdump
date: 2016-01-27T20:23:49+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3446
permalink: /2016/01/debugging-with-tcpdump/
tags:
  - linux
  - tcpdump
---
I&#8217;m having some problems with one of my hobby servers but this time instead of looking at the code to try to figure out what is happening, I decided to try to do it using only tcpdump. I was trying to start my server and I got this error message:

```
failed to create GA auth provider: invalid character '\u003c' looking for beginning of value
```

The character &#8216;\u003c&#8217; translates to <, so it seemed like the problem was that somewhere in my GA auth library I was getting what looked like an HTML instead of a JSON. The first thing I did was monitor the HTTP traffic using this command:

```bash
tcpdump -c 20 -s 0 -i eth0 -A tcp port http
```

<!--more-->

From the output, I found this request being sent:

```
14:59:43.453314 IP 56.121.31.229.54827 > ham04s01-in-f13.1e100.net.http: Flags [P.], seq 1:133, ack 1, win 115, options [nop,nop,TS val 89156682 ecr 3084658700], length 132
@.@.Y..e...:.....P|..N7......sa......
.PlJ..(.GET /.well-known/openid-configuration HTTP/1.1
Host: accounts.google.com
User-Agent: Go-http-client/1.1
Accept-Encoding: gzip
...
```

And a response that confirmed my suspicion:

```
14:59:43.475599 IP ham04s01-in-f13.1e100.net.http > 56.121.31.229.54827: Flags [.], seq 1:1419, ack 133, win 341, options [nop,nop,TS val 3084658723 ecr 89156682], length 1418
E.......6.{..:...e...P..7...|......U1......
..(#.PlJHTTP/1.1 404 Not Found
Content-Type: text/html; charset=UTF-8
X-Content-Type-Options: nosniff
Date: Thu, 14 Jan 2016 19:59:43 GMT
Server: sffe
Content-Length: 1593
X-XSS-Protection: 1; mode=block

<!DOCTYPE html>
...
```

The problem here is that I was getting a URL I didn&#8217;t really know what to do with: ham04s01-in-f13.1e100.net.http. An IP would be more useful, so I just added -n to the command:

```bash
tcpdump -n -c 20 -s 0 -i eth0 -A tcp port http
```

And now I got something more useful:

```
15:19:50.934257 IP 56.121.31.229.54827 > 216.58.213.237.80: Flags [P.], seq 1:116, ack 1, win 115, options [nop,nop,TS val 89458553 ecr 3085899276], length 115
E....>@.@....e...:.....P^H.J.|.....sa......
.U.y....GET /.well-known/openid-configuration HTTP/1.1
User-Agent: curl/7.35.0
Host: accounts.google.com
Accept: */*
```

I used curl to reproduce the issue outside my server:

```bash
curl 216.58.213.237/.well-known/openid-configuration
```

My app doesn&#8217;t really try to hit the IP directly, it actually hits accounts.google.com, so I tried that, which resulted in the same error:

```bash
curl accounts.google.com/.well-known/openid-configuration
```

Soon after discovering this, a friend suggested me to try HTTPS. This was effectively the problem, so I just had to change the code to use HTTPS instead of HTTP. This was indeed a very simple problem that happened because I did something stupid. Nevertheless it helped me learn a little about tcpdump which might come useful in the future.
