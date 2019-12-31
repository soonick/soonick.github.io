---
title: PostgreSQL - Connection refused
author: adrian.ancona
layout: post
date: 2020-01-08
permalink: /2020/01/postgresql-connection-refused/
tags:
  - postgresql
  - linux
---

While setting up a new PostgreSQL server, I noticed that I was getting a `connection refused` error while trying to connect to it. After checking the firewall settings and finding everything in order, I decided to check things in the host.

I used [ss](/2015/10/socket-statistics-with-ss/) to inspect connections listening on port 5432 (Default port used by PostgreSQL):

```sh
$ ss -tna src :5432
State       Recv-Q        Send-Q       Local Address:Port        Peer Address:Port
LISTEN        0            128          127.0.0.1:5432             0.0.0.0:*
```

<!--more-->

The output shows that the server is only listening on `127.0.0.1`, while we need to allow connections from any IP address.

To fix this we need to modify `postgresql.conf`. To find the file:

```sql
SELECT
  name, setting
FROM
  pg_settings
WHERE
  name = 'config_file';
```

Then, to allow connections from any host, we need to add this:

```ini
listen_addresses = '*'
```

And restart the server:

```sh
sudo systemctl restart postgresql
```
