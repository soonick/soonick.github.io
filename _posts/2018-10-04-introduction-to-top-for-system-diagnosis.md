---
id: 5318
title: Introduction to top for system diagnosis
date: 2018-10-04T03:17:47+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=5318
permalink: /2018/10/introduction-to-top-for-system-diagnosis/
tags:
  - debugging
  - linux
---
**top** is a program available in most Unix systems. It allows us to see the processes or threads running on a computer and help understand what they are doing at a high level (How much CPU or memory they are using, etc).

The **top** command with no modifiers will show something like this:

```
top - 11:44:51 up 13:24,  1 user,  load average: 0.58, 0.56, 0.63
Tasks: 247 total,   1 running, 246 sleeping,   0 stopped,   0 zombie
%Cpu(s):  9.3 us,  2.5 sy,  0.0 ni, 88.1 id,  0.0 wa,  0.0 hi,  0.2 si,  0.0 st
KiB Mem : 20296196 total, 15693616 free,  2027196 used,  2575384 buff/cache
KiB Swap: 20713468 total, 20713468 free,        0 used. 17373856 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 6541 adriana+  20   0 1711996 371500 179160 S  14.6  1.8   2:48.36 chromium-browse
 6086 adriana+  20   0 3204864 397544 143956 S  11.3  2.0   5:20.30 chromium-browse
 6560 adriana+  20   0 1299604 152364  77924 S   7.0  0.8   0:36.41 chromium-browse
 6521 adriana+  20   0 1338048 192696  94196 S   6.6  0.9   0:58.36 chromium-browse
 2860 adriana+  20   0 2000924 238864  68368 S   3.0  1.2   4:54.79 gnome-shell
 1440 root      20   0  233260  83616  25896 S   1.0  0.4   0:14.25 splunkd
 1914 root      20   0  500940  34424  20004 S   1.0  0.2   0:25.60 docker-containe
12367 adriana+  20   0   35600   3464   2896 R   0.7  0.0   0:00.05 top
    8 root      20   0       0      0      0 S   0.3  0.0   0:03.92 rcu_sched
  345 root       0 -20       0      0      0 S   0.3  0.0   0:01.65 kworker/u9:3
 1387 root      20   0  299452  64072  39456 S   0.3  0.3   2:24.16 Xorg
 1833 root      20   0  756772  68200  39192 S   0.3  0.3   0:11.96 dockerd
```

<!--more-->

The first line shows the time, how long has the system been up, the number of users logged into the system and the load average over the last 1, 5 and 15 minutes. The exact same information can be obtained by using the **uptime** program.

In the example above, we can see that the system has been running for 13 hours and 24 minutes and it currently has a single user logged in. The **0.58, 0.56, 0.63** is a little tricky to read. In a system with a single CPU it means that the system was 58% utilized the last minute, 56% utilized the last 5 minutes and 63% utilized the last 15 minutes. The system where I ran **top** has [4 processing units](https://ncona.com/2018/09/how-to-find-how-many-cores-your-system-has/) so the value we would see when the system is at capacity is 4.00. The 0.58 value actually means that the system was only 14.5% utilized. A system can be more than 100% used in some scenarios. What this means is that there are processes waiting for the CPU, but they are being queued.

The next line shows the number of Tasks (Processes) being run. It also shows the number of processes on each state (running, sleeping, etc&#8230;). By default it shows the number of processes, but you can see the number of threads instead by using the Threads-mode toggle (Uppercase letter H).

The next line shows the percentage of time the CPU was in certain state since last refresh:

```
us, user    : time running un-niced user processes
sy, system  : time running kernel processes
ni, nice    : time running niced user processes
id, idle    : time spent in the kernel idle handler
wa, IO-wait : time waiting for I/O completion
hi : time spent servicing hardware interrupts
si : time spent servicing software interrupts
st : time stolen from this vm by the hypervisor
```

The next two lines show physical memory and virtual memory. The value is in Kilobytes, but it can be toggled to Megabytes, Gigabytes, etc, by using uppercase letter E (The lowercase letter e can be used to toggle the units for the task list)

Everything I have explained so far is part of the Summary section. The section below is called the task list. We can move around the task list by using the arrow keys. The default columns for the task list can be seen in the example above. I&#8217;ll explain the ones that are not obvious:

  * **PR (Priority)** &#8211; A negative value means higher priority. A value of **rt** means real-time scheduling priority
  * **NI (niceness)** &#8211; Similar to priority, a lower value means higher priority. Lower values mean more CPU time
  * **VIRT** &#8211; Virtual memory size (code, data, shared libraries, etc)
  * **RES** &#8211; The non-swapped physical memory a task is using.
  * **SHR (Shared Memory)** &#8211; Memory that could be shared with other processes
  * **S (Status)** &#8211; Can be any of: D (uninterruptible sleep), R (running), S (sleeping), T (stopped by job control signal), t (stopped by debugger during trace), Z (zombie)
  * **%CPU** &#8211; Works similar to the %CPU section in the summary section, but specific to the task

These are the basics of top. I&#8217;ll write another article where I&#8217;ll cover more advanced usage.
