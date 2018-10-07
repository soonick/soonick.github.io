---
id: 282
title: Local Apache and OpenSSL configuration
date: 2012-05-24T06:09:59+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=282
permalink: /2012/05/local-apache-and-openssl-configuration/
categories:
  - Linux
tags:
  - apache
  - ssl
  - virtual host
---
This post can be seen as a continuation of &#8220;[Creating local virtual hosts with apache](http://ncona.com/2011/06/creating-local-virtual-hosts-with-apache/)&#8220;. We are going to extend the virtual server we created to be accessible via SSL locally.

We start by activating the SSL module:

```
sudo a2enmod ssl
```

The next step is to create the encryption keys for our certificate:

````
cd /etc/apache2
sudo openssl genrsa -des3 -out server.key 1024
```

<!--more-->

The **openssl genrsa** command generates an RSA private key. The arguments provided instruct genrsa to use triple DES encription and output to a file called server.key of 1024 bits.

Now we create our certificate:

```
sudo openssl req -new -key server.key -out server.csr
```

The **openssl req** command generated certificates and certificates requests. The arguments provided instruct req to create a new request (we will be prompted for the information of the certificate) using the server.key and output it to server.csr.

Now we sign the certificate:

```
sudo openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
```

Install key and certificate:

```
sudo cp server.crt /etc/ssl/certs/
sudo cp server.key /etc/ssl/private/
```

Now we are going to modify our virtual host file to work with SSL too:

```xml
<VirtualHost *:80>
    ServerName ncona.dev
    ServerAlias www.ncona.dev
    DocumentRoot /home/adrian/www/ncona.dev
    <Directory /home/adrian/www/ncona.dev>
        Options FollowSymLinks
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>
</VirtualHost>

<VirtualHost *:443>
    ServerName ncona.dev
    ServerAlias www.ncona.dev
    DocumentRoot /home/adrian/www/ncona.dev
    SSLEngine on
    SSLOptions +FakeBasicAuth +ExportCertData +StrictRequire
    SSLCertificateFile /etc/ssl/certs/server.crt
    SSLCertificateKeyFile /etc/ssl/private/server.key
    <Directory /home/adrian/www/ncona.dev>
        Options FollowSymLinks
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>
</VirtualHost>
```

And finally we restart apache:

```
sudo /etc/init.d/apache2 restart
```
