---
id: 3855
title: Introduction to Vagrant
date: 2016-09-07T11:56:08+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3855
permalink: /2016/09/introduction-to-vagrant/
categories:
  - Linux
tags:
  - bootstrapping
  - linux
  - open source
  - productivity
---
Vagrant is a tool for easily creating shareable development environments for your team. It consists of a configuration file with instructions for creating a virtual machine. This virtual machine should contain everything a developer might need to work in a specific project. This configuration file is then committed to the repo and shared with the team. All developers work inside this machine, preventing problems or inconsistencies setting up their development environment.

Now-a-days [the same thing can be achieved using Docker](http://ncona.com/2015/11/local-development-with-docker/)(and it is my preferred way of doing it), but the company where I work has some projects using Vagrant, so I decided to learn about it.

## Installation

The installation is pretty straight forward. Just head to [Vagrant&#8217;s downloads](https://www.vagrantup.com/downloads.html) page, get the binary for your OS and install it.

<!--more-->

Vagrant is a little different than Docker in that it uses a virtual machine for running the development environment (Docker uses linux native virtualization). This gives it better support for Mac and Windows than Docker (although Docker is catching up) at the cost of a little more setup.

The extra setup consists of installing VirtualBox. In fedora I tried to use dnf, but the version in their repo doesn&#8217;t work very well, so I had to install the RPM from [VirtualBox downloads page](https://www.virtualbox.org/wiki/Downloads).

You can test that the installation went well by running a simple example:

```
mkdir ~/vagrant-test
cd ~/vagrant-test
vagrant init hashicorp/precise64
vagrant up
```

If everything went well, you will have your virtual machine ready to use. You can get a terminal on it by using:

```
vagrant ssh
```

If you want to free the memory it is using you can destroy it:

```
vagrant destroy
```

## Configuring a Vagrant project

When we ran _vagrant init hashicorp/precise64_, a Vagrantfile was generated. This file allows us to configure our virtual machine with the dependencies necessary for our project. If you open the file you will see that it is full with comments, so it is very easy to understand what each part does.

If we remove the comments, the file looks like this:

```
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/precise64"
end
```

We can choose a different operating system if we feel like so:

```
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
end
```

There is a repository of [vagrant boxes online](https://atlas.hashicorp.com/boxes/search) that you can use as your base. Some boxes include only an operating system, but others contain other common tools that might be necessary for many projects (web servers, compilers, etc&#8230;).

Now that we have the operating system, we should install the tools all our developers will need. For this example project I&#8217;m going to need node, so I need to tell vagrant to install it for us. I created this script and placed it under ~/vagrant-test/scripts/provision.sh on the host machine:

```bash
#!/usr/bin/env bash

# Folder where dependencies will be installed
mkdir /provisioning
cd /provisioning

# Install node
wget https://nodejs.org/dist/v4.5.0/node-v4.5.0-linux-x64.tar.xz
tar xf node-v4.5.0-linux-x64.tar.xz
rm node-v4.5.0-linux-x64.tar.xz
cd node-v4.5.0-linux-x64
echo "PATH=$PATH:/provisioning/node-v4.5.0-linux-x64/bin" >> /home/vagrant/.bashrc
```

And then told Vagrant to provision our machine using that script:

```
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, path: "scripts/provision.sh"
end
```

We can test that this worked by rebuilding the virtual machine:

```
vagrant destroy
vagrant up
```

Now we have a virtual machine running in the background with node installed. To show node in action we can create a simple server. I created the file ~/vagrant-test/server.js and put the node example server on it:

```js
const http = require('http');

const hostname = '127.0.0.1';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World\n');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
```

Vagrant will by default mount the working directory(the one containing Vagrantfile) in the /vagrant folder inside the virtual machine, so we easily access our newly created server:

```
vagrant ssh
node /vagrant/server.js
```

If everything went well, you will see this message:

```
Server running at http://127.0.0.1:3000/
```

If you try to visit that URL in your browser you see that you can&#8217;t access it. The reason for this is that the server is running on the virtual machine, so 127.0.0.1 doesn&#8217;t refer to your machine, but to the virtual machine running on it.

The easiest way to fix this issue is by using port forwarding. What this means is that we will forward all traffic to a port in our host machine to a port in our virtual machine. This is very easy to do:

```
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, path: "scripts/provision.sh"
  config.vm.network :forwarded_port, guest: 3000, host: 4000
end
```

Note that I am using port 3000 on the guest, because this is the port where the server is running inside the virtual machine. The host port can be anything you want, it can even be the same port as the guest, I just used a different one to make the example clearer.

This should be all you need to do in most cases, but the hostname parameter passed to the server.listen function works a little weirdly. Because of this, we need to change the value of hostname in the example above:

```js
const http = require('http');

const hostname = '';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World\n');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
```

I&#8217;m not going to explain why this is necessary since it is outside of the scope of this article, but once you do that you can reload your vagrant machine:

```
vagrant reload
```

Then you can SSH and start the server, and finally visit http://127.0.0.1:4000/ in the host machine to see the server running.

Vagrant offers more options, but this should be enough to get you started if you are interested in using Vagrant.
