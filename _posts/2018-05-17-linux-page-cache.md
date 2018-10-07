---
id: 5036
title: Linux page cache
date: 2018-05-17T03:53:15+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=5036
permalink: /2018/05/linux-page-cache/
categories:
  - Linux
tags:
  - debugging
  - linux
---
Linux (and most other operating systems) provide a transparent layer of caching for [auxiliary storage](https://en.wikipedia.org/wiki/Auxiliary_memory) (hard drives, etc&#8230;). This layer allows fast access to frequently used files on disk by keeping their content in memory and reading from there when necessary.

The kernel can use any free space in RAM as page cache. If the system requires more memory, the kernel might free space used by this cache and provide it to the application that needs it.

## Inspecting page cache

Page cache is stored in RAM, but the space can be reclaimed by the kernel for applications whenever necessary. In Linux we can see how many bytes of RAM are used for page cache:

```
~ $ free -h
              total        used        free      shared  buff/cache   available
Mem:            19G        5.4G        7.8G        1.5G        6.2G         12G
Swap:           19G          0B         19G
```

<!--more-->

  * Total: The total amount of RAM available
  * Used: total &#8211; free &#8211; buffers &#8211; cache
  * Free: Memory not being used
  * Shared: Used by [tmpfs](https://en.wikipedia.org/wiki/Tmpfs)
  * Buff/cache: Memory used by buffers and page cache
  * Available: Estimate of how much memory can be reclaimed by apps (All the free space + some of the buff/cache)

## Reading

When we read a file from auxiliary storage, its contents are stored in page cache. If we try to read that same file again, the read will go faster. We can see that after reading a file from disk, our buff/cache value increases, but after subsequent reads, it doesn&#8217;t increase anymore:

```
~ $ free -h
              total        used        free      shared  buff/cache   available
Mem:            19G        5.3G         11G        1.5G        2.6G         12G
Swap:           19G          0B         19G
~ $ cat big.txt > /dev/null
~ $ free -h
              total        used        free      shared  buff/cache   available
Mem:            19G        5.4G         11G        1.5G        2.8G         12G
Swap:           19G          0B         19G
~ $ cat big.txt > /dev/null
~ $ free -h
              total        used        free      shared  buff/cache   available
Mem:            19G        5.4G         11G        1.5G        2.8G         12G
Swap:           19G          0B         19G
```

## Writing

The page cache is really useful for making reads faster, but it also affects the way writes work. When we perform a write, the write doesn&#8217;t go directly to the auxiliary device. The kernel first modifies the content in cache and marks that section of the cache as dirty. It is possible to see how much memory the system has marked as dirty:

```
~ $ cat /proc/meminfo | grep Dirty
Dirty:               248 kB
```

This memory is flushed to the disk periodically by the kernel. Parts of the page cache that are marked as dirty can&#8217;t be reclaimed by other applications until they are flushed to disk.

There are a few settings that control when the dirty cache is written to disk:

```
~ $ sysctl -a | grep dirty
vm.dirty_background_bytes = 0
vm.dirty_background_ratio = 10
vm.dirty_bytes = 0
vm.dirty_expire_centisecs = 3000
vm.dirty_ratio = 20
vm.dirty_writeback_centisecs = 500
```

  * vm.dirty\_background\_ratio &#8211; The percentage of system memory that can be filled with dirty pages
  * vm.dirty_ratio &#8211; Maximum amount of system memory that can be filled with dirty pages before everything must get committed to disk. When this value is reached, I/O blocks until all dirty pages have been committed to disk
  * vm.dirty\_background\_bytes &#8211; Same as with _ratio. Only one of these two can be set
  * vm.dirty\_bytes &#8211; Same as with \_ratio. Only one of these two can be set
  * vm.dirty\_expire\_centisecs &#8211; Any pages that have been dirty for longer than this time, will be written to disk
  * vm.dirty\_writeback\_centisecs &#8211; How often the kernel checks to see if there is data to be flushed

In my system, there is s thread that will wake up every 5 seconds and check if there are any dirty pages older than 30 seconds and write them to disk.

Having a page marked as dirty means that it hasn&#8217;t been written to disk. This means that in the scenario of a system crash, there will be data loss. This behavior is scary and unacceptable for some applications (e.g. Databases). For scenarios where data loss is not an option, there are system functions that force the kernel to write to disk.

If you were a developer writing a database, you want to give your user a guarantee that once a record has been inserted successfully, it will be there forever (even if the system crashes). To do this, we can use **[fsync](http://man7.org/linux/man-pages/man2/fdatasync.2.html)**. fsync, given a [file descriptor](https://ncona.com/2018/05/file-descriptors/) will flush any dirty pages associated with that file. If the call returns 0, we can be sure that the data has been persisted to disk.

Because calling fsync constantly is not very elegant there is also an option to [open](http://man7.org/linux/man-pages/man2/open.2.html) a file with the O_SYNC flag. This guarantees that all writes on that file will be performed synchronously.
