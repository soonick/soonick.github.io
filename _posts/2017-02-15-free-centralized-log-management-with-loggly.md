---
id: 4122
title: Free centralized log management with Loggly
date: 2017-02-15T06:15:43+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4122
permalink: /2017/02/free-centralized-log-management-with-loggly/
tags:
  - docker
  - linux
  - mysql
  - productivity
---
I&#8217;m looking for a centralized log management system that I can plug into some of my hobby projects and while I was about to spin up my ELK server (Elasticsearch, Logstash, Kibana) I found that Loggly has a free tier. I have used Loggly before and it is pretty good so I decided to give it a try.

Before we start setting things up in Loggly, we need to decide which logs we want to send. Here are a few that apply for me:
  
&#8211; Apache logs for ncona.com (Running inside docker container)
  
&#8211; MySQL logs (Running inside Digital Ocean droplet)
  
&#8211; Cron logs (Also inside Digital Ocean droplet)

Before we start configuring our system we need to [create a Loggly account](https://www.loggly.com/plans-and-pricing/).

<!--more-->

## Configuring Rsyslog

A common way to send logs to a central logging system is using Syslog. Since my droplet already has Rsyslog installed, I&#8217;m just going to use it.

To check which version of Rsyslog we are dealing with, we can use this command:

```
rsyslogd -v
```

My systems is using version **7.4.4**. The steps you need to follow might vary depending on your version.

Rsyslog&#8217;s configuration file lives in _/etc/rsyslog.conf_ but it also loads files from _/etc/rsyslog.d/*.conf_. Usually a new file will be added under /etc/rsyslog.d/ for each ruleset on the system. In our case, we will add a new ruleset for Loggly.

```
# cd /etc/rsyslog.d/
# ls
20-ufw.conf  21-cloudinit.conf  50-default.conf
# touch 22-loggy.conf
```

You might be wondering what are the numbers before all the files inside _/etc/rsyslog.d/_. All rules are executed in the order in which they are found. The files in this folder will also be executed in order (i.e. File 20 will be executed, then 21, etc&#8230;). If one of the files includes the instruction to stop processing the current message then the next file wouldn&#8217;t be executed at all. The numbers make it easy to have control over the order in which the rules are executed.

Loggly has a recommended configuration that they provide:

```
# Setup disk assisted queues
$WorkDirectory /var/spool/rsyslog # where to place spool files
$ActionQueueFileName fwdRule1     # unique name prefix for spool files
$ActionQueueMaxDiskSpace 1g       # 1gb space limit (use as much as possible)
$ActionQueueSaveOnShutdown on     # save messages to disk on shutdown
$ActionQueueType LinkedList       # run asynchronously
$ActionResumeRetryCount -1        # infinite retries if host is down

template(name="LogglyFormat" type="string"
 string="<%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msgid% [TOKEN@41058 tag="TAG"] %msg%\n")

# Send messages to Loggly over TCP using the template.
action(type="omfwd" protocol="tcp" target="logs-01.loggly.com" port="514" template="LogglyFormat")
```

It is pretty well commented, so it is easy to understand what it is doing. You will need to replace _TOKEN_ with your Loggly token (You can find this in the /tokens section of your Loggly domain. E.g. https://yourdomain.loggly.com/tokens) and TAG with something that helps you identify the computer where the logs are coming from (E.g. ubuntu-droplet-005).

Now it&#8217;s time to restart syslog so the new configuration takes effect:

```
sudo service rsyslog restart
```

At this point Rsyslog will start sending messages to Loggly. If you don&#8217;t have anything writing to Loggly, you can generate a log for testing:

```
logger 'Taquitos con frijolito'
```

After a few seconds you should see the message in Loggly.

## Cron logs

Cron by default logs the commands it executes to syslog. The log entry looks something like this:

```
(root) CMD (ls /home)
```

If you also want to log Stdout and Stderr you will need to modify the cron entry to look something like this:

```
* * * * * ls /home 2>&1 | /usr/bin/logger -t CRON
```

This will pipe the output of your command to _logger_, which will forward it to syslog with the given app name.

## MySQL logs

Before you can send logs to Loggly you need to configure MySQL to save logs to a log file. The MySQL configuration file can be found at _/etc/mysql/my.cnf_. These lines will enable logging:

```
general_log_file = /var/log/mysql/mysql.log
general_log= 1
log_slow_queries = /var/log/mysql/mysql-slow.log
long_query_time = 1
log-queries-not-using-indexes = 1
```

Depending on the load of your server, MySQL could generate a lot of data, so you might want to keep an eye on it and probably tune it to be less noisy.

We need to restart MySQL for the changes to take effect:

```
/etc/init.d/mysql restart
```

Loggly has a script that allows you to monitor log files and forward the logs to Loggly:

```
curl -O https://www.loggly.com/install/configure-file-monitoring.sh
sudo bash configure-file-monitoring.sh -a SUBDOMAIN -u USERNAME -f /var/log/mysql -l mysql -tag MySQL
```

You will need to replace SUBDOMAIN and USERNAME with your respective subdomain and username for Loggly. You will be prompted for your Loggly password and will be asked some other simple questions about the configuration.

## Docker logs

If your docker container logs to Stdout and Stderr, you just need to change some things to forward the logs to Loggly. First we need to modify our syslog configuration (/etc/rsyslog.d/22-loggly.conf):

```
# Setup disk assisted queues
$WorkDirectory /var/spool/rsyslog # where to place spool files
$ActionQueueFileName fwdRule1     # unique name prefix for spool files
$ActionQueueMaxDiskSpace 1g       # 1gb space limit (use as much as possible)
$ActionQueueSaveOnShutdown on     # save messages to disk on shutdown
$ActionQueueType LinkedList       # run asynchronously
$ActionResumeRetryCount -1        # infinite retries if host is down

# Send messages to Loggly over TCP using the template.
action(type="omfwd" protocol="tcp" target="logs-01.loggly.com" port="514" template="LogglyFormat")

$template LogglyFormat,"<%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %$!syslogtag% %procid% %msgid% [TOKEN@41058] %msg%\n"

#Script below will send  'docker/Container ID' in appName.
if re_match($syslogtag,'(docker)')
then
{
    set $!extract = re_extract($syslogtag,'(docker/[a-zA-Z0-9]*)',0,1,"");
    set $!syslogtag= $!extract;
}
else
    set $!syslogtag = $syslogtag;
```

Then you just need to add _&#8211;log-driver=syslog_ to your docker run command:

```
docker run -d --restart=on-failure --log-driver=syslog ncona-image
```

That&#8217;s it! All the things I wanted to keep an eye on are now sending logs to Loggly.
