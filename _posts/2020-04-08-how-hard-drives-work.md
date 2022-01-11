---
title: How hard drives work
author: adrian.ancona
layout: post
date: 2020-04-08
permalink: /2020/04/how-hard-drives-work/
tags:
  - computer_science
---

As computer users, we are accustomed to storing data to retrieve it sometime in the future. Today there are many ways to do this. If you take a photo on your cell phone, it's going to be saved into the phones internal `flash memory` (or an external flash card). If you have a modern computer it's likely that you have a `Solid State Drive (SSD)`. It's also possible to save your data in the "`cloud`". So, why focus on Hard drives?

`Hard Disk Drives (HDD)` have been a reliable way to store data since the 1950's. Cloud providers (AWS, Azure, Google Cloud) have HDD offerings that are cheaper than the SSD alternatives. At the time I wrote this article, if I want to buy a 5TB HDD, I would have to pay around $100 USD; if I want to buy 5TB SSD I would have to pay around $500 USD. For this reason HDDs are still widely used.

<!--more-->

## Hardware

An HDD comes in a a rectangular box made of metal:

[<img src="/images/posts/hdd-box.png" alt="Hard Disk Drive" />](/images/posts/hdd-box.png)

This metal box is designed to protect the moving parts on the inside, which are the ones actually doing data writting and reading.

If we open the box we'll be able to see the disk:

[<img src="/images/posts/hdd-inside.jpg" alt="Hard Disk Drive Inside" />](/images/posts/hdd-inside.jpg)

Modern HDDs contain multiple disks (Each disk is called a platter). All the platters are attached to a spindle that makes the disks rotate. Since all the disks are attached to the same spindle, they all rotate at the same time and speed.

There is a mechanical arm that can move the heads to the inside or outside of the platters. Because there are multiple platters where data can be written, there are also multiple heads. Modern HDDs allow storing data on both sides of each platter, so there will be twice as many heads as there are platters.

There is only one mechanical arm that moves all the heads at the same time. If the disk is asked to read a few chunks of information on different platters, it can't send one head in one direction and the other head in another direction. Even if the disk was asked to retrieve data that is in the same location in multiple platters, a disk can only read or write data from one platter at a time.

The head at the end of the arm is the piece of technology that allows writting and storing data on the disk. When the disk needs to read a bit, it moves the arm to the right location, waits for the platter to spin so the data is underneath the head and it transforms the magnetic field into an electrical current that is interpreted as a 0 or 1. When the head needs to write, it does the opposite. It receives an electrical current and transforms it to a magnetic field that is stored on the platter.

[<img src="/images/posts/hdd-parts.jpg" alt="Hard Disk Drive Parts" />](/images/posts/hdd-parts.jpg)

## Layout

When working with Hard Drives, it's common to hear different terms to describe parts of the disk where the data is stored.

In the previous section, we learned that a platter is where the data is stored. Even though the data is stored in the platter one bit after the other as thight as possible, the platters are logically divided so it's easier to work with them.

### CHS

[Cylinder-head-sector (CHS)](https://en.wikipedia.org/wiki/Cylinder-head-sector), is a way to address data on the disk based on a coordinate system. The system is pretty old and not used by most HDDs anymore. It's still common to hear references to it, so I'm going to explain it.

Each platter is divided into tracks and sectors that together identify a specific block (An addressable amount of data):

[<img src="/images/posts/tracks-and-sectors.png" alt="Hard Drive Tracks and Sectors" />](/images/posts/tracks-and-sectors.png)

From the image above:

- **Track (Red circle on the image)** - A circular section of the platter. A platter is divided in multiple tracks starting from the inside to the outside
- **Sector (Blue on the image)** - A sector is a slice of the disk
- **Track sector (C on the image)** - The intersection of a Track and a sector is usually also referred as a sector. This is the minimum amount of data that can be written or retrieved from an HDD (Typically 512kb)

Because modern HDDs have multiple platters, CHS, uses the term cylinder to refer to the same track on multiple platters (Imagine a cylinder that intersects with all the platters at the same time). It is also necessary to specify the head so the HDD knows which platter surface to read or write from.

### LBA

[Logical Block Addressing](https://en.wikipedia.org/wiki/Logical_block_addressing) is the way modern HDDs use to address data.

While CHS uses a coordinate system, LBA uses a much simpler linear system that abstracts the internal structure of the storage device. To refer to data in an LBA device, you just need to specify the index (from 0 to N, where N is the number of blocks on the device).

Most modern storage devices support LBA. For older devices, the Operating System performs a translation from an LBA index to a CHS coordinate.

## Conclusion

I wrote this article because I want to get more familiar with how data is stored by computers. Here I explore how an HDD is built and two common ways of addressing data. As part of my learning I will try to write an article describing techniques for using HDDs efficiently.
