---
id: 4015
title: 'Free SSL certificates with Let&#8217;s encrypt'
date: 2017-01-04T01:29:31+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=4015
permalink: /2017/01/free-https-with-lets-encrypt/
categories:
  - Linux
tags:
  - automation
  - linux
  - ssh
---
This blog and a few other of my personal projects are not using HTTPS at the moment of this writing. Using plain HTTP has a couple of disadvantages that could result in catastrophic consequences:

  * **Traffic can be sniffed** &#8211; If somebody monitored the traffic in your network they would be able the see everything you are sending and receiving (including usernames and passwords).
  * **Traffic can be modified** &#8211; When using plain HTTP, there is no guarantee that who you are talking to is who they say they are. Because of this, somebody could intercept your traffic and give you a response of their own. They could give you a log-in form to trick you into entering your credentials

<!--more-->

## Asymmetric encryption

Asymmetric encryption is one of the techniques used by HTTPS to solve the problems stated above. The server holds a public key and a private key. The private key is kept securely in the server all the time, while the public key is given to anybody who requests it. When a browser requests a URL using HTTPS, the server will first give the public key to the browser that made the request and then it will return the requested content encrypted with the private key. All messages encrypted with the private key can be decrypted using the public key.

When the user wants to send information to the server through the browser, the browser will use the public key to encrypt the content before it leaves the computer. This message can only be decrypted by the server, because only the server has the private key.

If you paid attention, you might be wondering if anybody can see anything returned by the server. Since the server encrypts with its private key, and the browser decrypts with the public key (which is by definition public), then anybody will be able to see any message sent by the server. To prevent this, messages are actually encrypted twice.

Both the server and the browser have a pair of public and private keys. At the beginning of the conversation they both exchange their public keys. When the server sends a message to a browser it will encrypt it first with the browser&#8217;s public key and then with its own private key. This way if someone intercepts the response they won&#8217;t be able to decrypt it because the browser&#8217;s private key will be needed for the decryption, and nobody but the browser who sent the request, has it.

## Public Key Infrastructure

Asymmetric encryption solves the problem of people sniffing your traffic, but an attacker could still trick you into sending information to them instead of to the service you are trying to contact. If an attacker found a way to get between a user and a server by acting as a proxy, it could issue its own pair of private an public keys and use those to communicate with both ends. By using it&#8217;s own private and public keys it gets the power to decrypt all traffic going through it. To mitigate this problem PKI was introduced.

In the web we usually communicate to a service by using a domain name(e.g. ncona.com). There is a DNS server that will tell your computer in which IP address does ncona.com live. If everything works well, the DNS resolution makes sure all messages are delivered to my blog and nobody else. If an attacker got in the middle of a visitor and ncona.com, they could grab the request and create a response of their own without even hitting that IP address.

How can we then prevent someone in the middle to impersonate our server? By using certificates. HTTPS Certificates are only valid if they are issued by a Certification Authority(CA). This means, if you visit a website that uses HTTPS you will receive a certificate that was issued by a CA. If the certificate you receive was not issued by a CA then your browser will show you a warning(How big is the warning varies by browser).

Lets say you go to https://www.google.com, you will receive a certificate signed by a CA back. Browsers come with hard-coded copies of all the trusted CA&#8217;s public keys. When the browser sees a certificate, it will validate that the certificate was issued by a CA by checking the signature (which was made using the CA&#8217;s private key). The certificate includes information about the server you are talking to, but the most important pieces of information are the domain name and the public key for this domain. Only if the signature check passes and the domain you are trying to access matches the domain in the certificate, the browser will let you let you visit it without a warning.

## Let&#8217;s encrypt

Now that we(roughly) know how HTTPS works we can try getting a certificate. There are many CA&#8217;s out there but I decided to go with Let&#8217;s Encrypt because it is free. Although being free was my greatest motivation, another great advantage of using Let&#8217;s Encrypt is that certificate issuing and renewal are automated, so they are very easy and fast processes.

Their [getting started documentation](https://letsencrypt.org/getting-started/) explains different ways of installing a certificate on your server. Since I use [DigitalOcean](https://www.digitalocean.com/) for my servers I will be using [Certbot](https://certbot.eff.org/).

## Certbot

Certbot is a client for the ACME(Automatic Certificate Management Environment) Protocol which is used to obtain and renew certificates from Let&#8217;s Encrypt. Since my server is running Ubuntu trusty, but I have different services running there(running on Docker containers), I will use the [&#8220;none of the above-Ubuntu trusty&#8221;](https://certbot.eff.org/#ubuntutrusty-other) combination.

First of all, I SSH into my server, download certbot-auto and make it executable:

```
ssh user@server.com
wget https://dl.eff.org/certbot-auto
chmod a+x certbot-auto
```

cerbot-auto is a wrapper to the certbot client that will install its dependencies and keep the client updated. The initial installation can be done with this command:

```
./certbot-auto
```

On my first try, I actually got this error:

```
InsecurePlatformWarning
```

To fix this I needed to upgrade python:

```bash
sudo add-apt-repository ppa:fkrull/deadsnakes-python2.7
sudo apt-get update
sudo apt-get upgrade
```

Also, because I&#8217;m using a cheap DigitalOcean box I had to increase the swap size so the install goes through:

```bash
sudo dd if=/dev/zero of=/swapfile bs=1024 count=524288
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

The command should now work:

```
./certbot-auto
```

Once everything is installed, you might want to turn off the swap file:

```
sudo swapoff /swapfile
```

Now it&#8217;s time to create our certificate:

```
./certbot-auto certonly
```

In order to generate the Certificate you will need to answer a few questions. My answers below:

```
How would you like to authenticate with the ACME CA?
Spin up a temporary webserver (standalone)

Please enter you domain names(s) (comma and/or space separated)
ncona.com,www.ncona.com
```

Another way to do the same thing would have been:

```
./certbot-auto certonly --standalone -d ncona.com -d www.ncona.com
```

After successfully generating the certificates I got this message:

```
 - Congratulations! Your certificate and chain have been saved at
   /etc/letsencrypt/live/ncona.com/fullchain.pem. Your cert will
   expire on 2017-03-14. To obtain a new or tweaked version of this
   certificate in the future, simply run certbot-auto again. To
   non-interactively renew *all* of your certificates, run
   "certbot-auto renew"
```

The success message gives two important pieces of information: The expiration date and how to renew it. Lets encrypt&#8217;s certificates expire often to encourage the automation of the renewal process. Certbot&#8217;s documentation recommends to attempt to renew twice a day in a random minute and hour, so that is what I&#8217;m going to do.

Just to see what will happen if I try to renew right away I ran the command:

```
./certbot-auto renew
```

And got this message:

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log

-------------------------------------------------------------------------------
Processing /etc/letsencrypt/renewal/ncona.com.conf
-------------------------------------------------------------------------------
Cert not yet due for renewal

The following certs are not due for renewal yet:
  /etc/letsencrypt/live/ncona.com/fullchain.pem (skipped)
No renewals were attempted.
```

You can also do a dry run to check everything would work fine:

```
./certbot-auto renew --dry-run
```

If everything goes well, we can go ahead and create the cron job. This is the entry I created:

```
21 7,19 * * * /home/user/certbot-auto renew --quiet --no-self-upgrade
```

Which translates to every day at 7:21 and 19:21. I&#8217;m using the whole path to my certbot-auto script so the cron daemon can find it. I&#8217;m also using &#8211;quiet to omit all output in case of success.

Now we have our certificate and a cron job that will renew them automatically so it never expires. The next step is installing it so my service starts using it. I will cover that part in another post.
