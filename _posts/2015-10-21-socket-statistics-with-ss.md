---
id: 3229
title: Socket Statistics with ss
date: 2015-10-21T07:30:32+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3229
permalink: /2015/10/socket-statistics-with-ss/
tags:
  - apache
  - debugging
  - linux
---
ss is a replacement for netstat; a program that allows you to analyze the sockets running on a Linux system. In practice, it is useful to investigate if a port is being used and by whom or to investigate which services are running.

In its simplest form, the **ss** command will list all non-listening sockets:

```
[adrian@localhost ~]$ ss
Netid  State   Recv-Q Send-Q       Local Address:Port                          Peer Address:Port
u_str  ESTAB   0      0            /run/systemd/journal/stdout 8313                    * 29127
u_str  ESTAB   0      0            /run/systemd/journal/stdout 9946                    * 30837
u_str  ESTAB   0      0            /var/run/dbus/system_bus_socket 7415                * 25359
u_str  ESTAB   0      0            /var/run/dbus/system_bus_socket  8795               * 18724
u_str  ESTAB   0      0                * 30484                                         * 28442
...
```

<!--more-->

The output is kind of long. These are mostly sockets created by the OS but that are not really listening for any connections. ESTAB means stablished.

Usually you are more interested in listening sockets(sockets listening for connections), you can see those using the -l flag:

```
[adrian@localhost ~]$ ss -l
Netid  State      Recv-Q Send-Q           Local Address:Port                             Peer Address:Port
nl     UNCONN     0      0                   rtnl:evolution-calen/2051                             *
nl     UNCONN     0      0                   rtnl:geoclue/1784                                     *
u_str  LISTEN     0      128                 @/tmp/.ICE-unix/1665 25361                            * 0
u_str  LISTEN     0      128                 /var/run/cups/cups.sock 13057                         * 0
u_str  LISTEN     0      30                  /run/user/1000/at-spi2-62DK6X/socket 30467            * 0
u_str  LISTEN     0      128                 /var/run/rpcbind.sock 13059                           * 0
u_str  LISTEN     0      30                  /run/user/1000/at-spi2-KHX56X/socket 31236            * 0
...
```

This is a little more useful, but it still includes a lot of system sockets that we are probably not interested in. If you work on the web, you will most likely be working with TCP and UDP. It is very easy to tell **ss** to show only one of these protocols:

TCP:

```
[adrian@localhost ~]$ ss -lt
State      Recv-Q Send-Q                     Local Address:Port                     Peer Address:Port
LISTEN     0      5                          192.168.122.1:domain                          *:*
LISTEN     0      128                        127.0.0.1:ipp                                 *:*
LISTEN     0      128                        *:db-lsp                                      *:*
LISTEN     0      128                        127.0.0.1:17600                               *:*
LISTEN     0      128                        127.0.0.1:17603                               *:*
LISTEN     0      128                        ::1:ipp                                       :::*
```

UDP:

```
[adrian@localhost ~]$ ss -lu
State      Recv-Q Send-Q                 Local Address:Port                        Peer Address:Port
UNCONN     0      0                      192.168.122.1:domain                             *:*
UNCONN     0      0                      *%virbr0:bootps                                  *:*
UNCONN     0      0                      *:bootpc                                         *:*
UNCONN     0      0                      *:ntp                                            *:*
```

The output is a lot more manageable now, but if we know what we are looking for, we can do better. Lets start a server in port 8080 and run ss:

```
[adrian@localhost ~]$ ss -lt
State      Recv-Q Send-Q                   Local Address:Port                     Peer Address:Port
LISTEN     0      128                          *:webcache                               *:*
LISTEN     0      5                        192.168.122.1:domain                         *:*
LISTEN     0      128                        127.0.0.1:ipp                              *:*
LISTEN     0      128                       *:db-lsp                                    *:*
...
```

It seems like our server is not part of the output, but in reality it is. SS shows you the name of the service that commonly runs in the port when it&#8217;s available. In this case the service that usually runs on port 8080 is called webcache. There is a [list of port numbers in wikipedia](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers) that contains the most common port numbers and services running on those ports.

Because working with IPs and ports is easier for us, we can use the -n flag:

```
[adrian@localhost ~]$ ss -ltn
State      Recv-Q Send-Q                   Local Address:Port                     Peer Address:Port
LISTEN     0      128                          *:8080                               *:*
LISTEN     0      5                        192.168.122.1:53                         *:*
LISTEN     0      128                        127.0.0.1:631                          *:*
LISTEN     0      128                       *:17500                                 *:*
...
```

If we want to be more specific, we can use filtering:

```
[adrian@localhost ~]$ ss -lt sport = :8080
State      Recv-Q Send-Q     Local Address:Port             Peer Address:Port
LISTEN     0      128            *:webcache                         *:*
```

Notice how even when filtered by port number, it still returned the port name. It automatically does the mapping for us. Other useful filters are:

  * dst &#8211; remote address and port
  * src &#8211; local address and port
  * dport &#8211; remote port
  * sport &#8211; local port

Lastly, another very important thing that you might want to know is which process is listening to that port. Just add the -p flag:

```
[adrian@localhost ~]$ ss -ltp sport = :webcache
State      Recv-Q Send-Q          Local Address:Port     Peer Address:Port
LISTEN     0      128                 *:webcache              *:*            users:(("node",pid=31183,fd=10))
```
