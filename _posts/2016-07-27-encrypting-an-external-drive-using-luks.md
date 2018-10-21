---
id: 3827
title: Encrypting an external drive using LUKS
date: 2016-07-27T17:08:14+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3827
permalink: /2016/07/encrypting-an-external-drive-using-luks/
tags:
  - linux
---
I recently had a friend who lost an external hard drive where she stored private information. This hard drive can now be read by anyone who finds it because there was no protection on it. To prevent that from happening to me I decided I will start encrypting my external drives (My computer drives are already encrypted by the OS).

The first thing you should do is temporarily backup your data in another drive. In order to encrypt the external drive we will need to remove all the data first.

<!--more-->

The first thing we need to do is to find the device we want to encrypt. You can use fdisk for this:

```
fdisk -l
```

The command will list all your block devices with some information about them so you can identify them. The one I want to work on looked like this:

```
Device     Boot Start       End   Sectors   Size Id Type
/dev/sdb1        2048 976771119 976769072 465.8G  7 HPFS/NTFS/exFAT
```

Since all content in this drive will be deleted, it is very important to make sure this is the drive you think it is. I verified by unplugging it and making sure that it wasn&#8217;t there anymore and then connecting it again and verifying that it appeared.

Now that we have our information backed up and we know which device we want to encrypt, it is a good idea to fill the disk with zeros:

```
dd if=/dev/zero of=/dev/sdb1 bs=1M
```

If you are more paranoid you can fill the disk with random data, but it takes a very long time and most of the time is not necessary:

```
badblocks -c 10240 -s -w -t random -v /dev/sdb1
```

We can now format the disk using LUKS:

```
cryptsetup luksFormat /dev/sdb1
```

You will be prompted for a passphrase. This is going to be the key to decrypt the contents of the disk when needed. Make it something hard to guess and make sure you don&#8217;t forget it because if you do, you won&#8217;t be able to recover it.

We have now an encrypted hard drive, but it doesn&#8217;t have a file system. To create a file system we need to first create a mapping to allow access to the content on the device:

```
cryptsetup luksOpen /dev/sdb1 encrypted-external-drive
```

I used encrypted-external-drive, but you can choose whatever name suits you. Now, format the device with ext2:

```
mke2fs /dev/mapper/encrypted-external-drive
```

Once that command is done you can disconnect the external drive. You can test that everything works correctly by connecting it again and trying to access it from nautilus. You will be prompted for the passphrase and then you will be able to see the contents of the disk. At this point things might seem fine, but there is a problem. Only root can write to the disk.

To fix this you need to give write permissions to your user in the mount location where the drive is mounted. Here is an example:

```
sudo chown -R adrian /run/media/anovelo/e2902cbe-7e2d-4fb2-8cfe-f50ba9b80795/
```
