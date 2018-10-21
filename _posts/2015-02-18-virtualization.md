---
id: 1430
title: Virtualization
date: 2015-02-18T18:16:53+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1430
permalink: /2015/02/virtualization/
tags:
  - hardware
  - linux
---
Since I started working on big companies I&#8217;ve been becoming a little interested in distributed systems. There are some distributed technologies I&#8217;ve been wanting to play with, but I don&#8217;t have a bunch of machines I can use to test how they work. To avoid having to buy multiple machines I decided to learn how to do it in a single machine using virtualization.

In this post I&#8217;m going to try to explain the basics of virtualization so we can build a few virtual machines that can talk to each other.

## Types of virtualization

There are a few types of virtualization:

  * Hardware emulation &#8211; This is generally very slow because the hardware is emulated with software.
  * Full virtualization &#8211; Uses an hypervisor to share hardware with the host machine.
  * Para-virtualization &#8211; Shares the process with the guest operating system.
  * Operating System-level virtualization &#8211; Partitions a host into insulated guests. This is kind of chroot but with much stronger resource isolation.

<!--more-->

## Getting the host ready

I&#8217;m going to be using Fedora as my host system since that is what I&#8217;m currently running. The first thing you want to check is if you have Full Virtualization available:

```
egrep '^flags.*(vmx|svm)' /proc/cpuinfo
```

If no lines were printed it means you will have to use hardware emulation which is much slower.

To install QEMU, KVEM and other virtualization tools we can run this command:

```
su -c "yum install @virtualization"
```

Once the necessary packages are installed, you can check that the KVM modules are properly loaded by running:

```
lsmod | grep kvm
```

You should see kvm\_intel or kvm\_amd in the output if everything is fine.

## Creating guests

Before we create a guest we have to decide what kind of virtual disk we are going use for it. I&#8217;m going to use an LVM2 volume with 16384MB. You can find more information about the types of disks in the [virt-tools documentation](http://virt-tools.org/learning/install-with-command-line/).

To create an LVM2 volume we need to create a Logical Volume. To start we need to understand what a physical volume and a logical volume are. A physical volume is something that from the OS point of view looks like a physical storage unit. You can display the physical volumes on your machine using this command:

```
sudo pvdisplay
```

Output looks like this:

```
  --- Physical volume ---
  PV Name               /dev/sda3
  VG Name               fedora
  PV Size               930.83 GiB / not usable 4.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              238291
  Free PE               16
  Allocated PE          238275
  PV UUID               4I0Ygj-Nbh4-t5kn-6Hk7-SoM5-C2uJ-ILrXp8
```

The output is telling us that we have a single physical volume called /dev/sda3 which is part of a volume group called fedora. A volume group is a group of physical volumes. A physical volume can only be part of one group but there can be multiple physical volumes in one group. Logical volumes are virtual volumes created on top of volume groups. We can see all the current logical volumes on the fedora group with this command:

```
sudo lvdisplay -v fedora
```

And the output:

```
...
  --- Logical volume ---
  LV Path                /dev/fedora/home
  LV Name                home
  VG Name                fedora
  LV UUID                zDJx1P-ZzLT-PAjW-WImL-LaFN-RTOR-86QKAU
  LV Write Access        read/write
  LV Creation host, time localhost, 2014-12-18 17:35:24 -0600
  LV Status              available
  # open                 1
  LV Size                873.01 GiB
  Current LE             223491
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
...
```

The logical volume I&#8217;m most interested in right now is the home volume because it has a size of 873.01GB from where I can steal some space for a new logical volume.

Follow the instructions here to [safely shrink an LVM volume](http://blog.shadypixel.com/how-to-shrink-an-lvm-volume-safely/). The commands I used are:

```
umount /dev/fedora/home
e2fsck -f /dev/fedora/home
resize2fs /dev/fedora/home 720G
lvreduce -L 800G /dev/fedora/home
resize2fs /dev/fedora/home
```

Running lvdisplay after, shows that the changes correctly took effect:

```
  --- Logical volume ---
  LV Path                /dev/fedora/home
  LV Name                home
  VG Name                fedora
  LV UUID                zDJx1P-ZzLT-PAjW-WImL-LaFN-RTOR-86QKAU
  LV Write Access        read/write
  LV Creation host, time localhost, 2014-12-18 17:35:24 -0600
  LV Status              available
  # open                 1
  LV Size                800.00 GiB
  Current LE             204800
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
```

The output of pvdisplay has also changed to show the available PE:

```
  PV Name               /dev/sda3
  VG Name               fedora
  PV Size               930.83 GiB / not usable 4.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              238291
  Free PE               18707
  Allocated PE          219584
  PV UUID               4I0Ygj-Nbh2-t5kn-6Hk7-SoM5-C2uJ-ILrXp8
```

Now I can go ahead and create an LVM2 logical volume for my guest:

```
sudo lvcreate -n vm1 -L 16384M fedora
```

Where vm1 is the name of the logical volume and fedora is the group where I want to add it.

I&#8217;m going to install fedora on my virtual machine, so I&#8217;m going to use this command:

```
sudo virt-install -r 1024 --accelerate -n VirtualFedora -f /dev/fedora/vm1 --cdrom /tmp/Fedora-Live-Workstation-x86_64-21-5.iso
```

Where VirtualFedora is the name of the virtual machine, /dev/fedora/vm1 is the full path to the logical volume and /tmp/Fedora-Live-Workstation-x86_64-21-5.iso is the path to the ISO I want to install. The installation process is the same as with a real machine.

## Starting and stopping

We now have a virtual machine ready and we need to know how to use it. If you want to know which virtual machines you have available in the current host you can use:

```
sudo virsh list --all
```

I got this output:

```
 Id    Name                           State
----------------------------------------------------
 -     VirtualFedora                  shut off
```

You can start the virtual machine using this command:

```
sudo virsh start VirtualFedora
```

This command basically acts as pressing the on button on a machine, but it doesn&#8217;t do anything else. You can see that it actually worked using &#8220;sudo virsh list &#8211;all&#8221;. This is an example output:

```
 Id    Name                           State
----------------------------------------------------
 13    VirtualFedora                  running
```

An Id has been assigned and now the state is &#8220;running&#8221;. To get an actual screen where you can interact with the machine, use:

```
sudo virt-viewer VirtualFedora
```

You can shut off the computer from the GUI the way you would normally do it(And that is the recommended way to shut down the machine) but if for some reason the GUI is not responsive you can use this command to pull the virtual plug of your machine:

```
sudo virsh destroy VirtualFedora
```

## Networking

By default libvirt will create a private network for your guests on the host machine. This makes it possible for the guests and the host to talk among them. To allow computers in the host&#8217;s network to talk to guests a little configuration is necessary.

Currently I&#8217;m running two guests on my machine. If I run ifconfig on the host I get an output like this:

```
virbr0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        inet6 fe80::fc54:ff:fe41:b869  prefixlen 64  scopeid 0x20<link>
        ether fe:54:00:12:33:75  txqueuelen 0  (Ethernet)
        RX packets 201940  bytes 11524447 (10.9 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 349889  bytes 513753400 (489.9 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vnet0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::fc54:ff:fe12:3375  prefixlen 64  scopeid 0x20<link>
        ether fe:54:00:12:33:75  txqueuelen 500  (Ethernet)
        RX packets 48060  bytes 3582652 (3.4 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 81083  bytes 115864011 (110.4 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vnet1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::fc54:ff:febc:3817  prefixlen 64  scopeid 0x20<link>
        ether fe:54:00:bc:38:17  txqueuelen 500  (Ethernet)
        RX packets 43588  bytes 3055909 (2.9 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 76266  bytes 112107093 (106.9 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

I have one virtual bridge and two virtual networks. From here there is no way to know which IP addresses belong to my guests. To get a guest IP address you can run ifconfig from within the guest:

```
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.122.48  netmask 255.255.255.0  broadcast 192.168.122.255
        inet6 fe80::5054:ff:fe12:3375  prefixlen 64  scopeid 0x20<link>
        ether 52:54:00:12:33:75  txqueuelen 1000  (Ethernet)
        RX packets 80952  bytes 115855356 (110.4 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 48013  bytes 3578503 (3.4 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

Enabling communication to the private network from the outside world has to be done using iptables rules and is usually done in a per-need basis.

As an example I will have a web server running on port 1337 on my guest that lives on IP 192.168.122.48 and I will make it accessible to the outside from port 8765 from my host machine. We will also need the name of the guest, which is VirtualFedora in my example.

Create this file: /etc/libvirt/hooks/qemu and make it executable using:

```
sudo chmod +x /etc/libvirt/hooks/qemu
```

The content of the file will be:

```sh
#!/bin/sh
# used some from advanced script to have multiple ports: use an equal number of guest and host ports

Guest_name=VirtualFedora
Guest_ipaddr=192.168.122.48
Host_port=( '8765' )
Guest_port=( '1337' )
length=$(( ${#Host_port[@]} - 1 ))
if [ "${1}" = "${Guest_name}" ]; then
   if [ "${2}" = "stopped" -o "${2}" = "reconnect" ]; then
       for i in `seq 0 $length`; do
               iptables -t nat -D PREROUTING -p tcp --dport ${Host_port[$i]} -j DNAT \
                       --to ${Guest_ipaddr}:${Guest_port[$i]}
               iptables -D FORWARD -d ${Guest_ipaddr}/32 -p tcp -m state --state NEW \
                       -m tcp --dport ${Guest_port[$i]} -j ACCEPT
       done
   fi
   if [ "${2}" = "start" -o "${2}" = "reconnect" ]; then
       for i in `seq 0 $length`; do
               iptables -t nat -A PREROUTING -p tcp --dport ${Host_port[$i]} -j DNAT \
                        --to ${Guest_ipaddr}:${Guest_port[$i]}
               iptables -I FORWARD -d ${Guest_ipaddr}/32 -p tcp -m state --state NEW \
                        -m tcp --dport ${Guest_port[$i]} -j ACCEPT
       done
   fi
fi
```

Once the script is ready we need to close all our guests and restart libvirt using this command:

```
service libvirtd restart
```

Once we start our guest and our service in port 1337, machines inside the host network will be able to access the service using the host IP address and port 8765 as per our configuration.
