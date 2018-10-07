---
id: 234
title: Using UTF-8 characters on an e-mail subject
date: 2011-06-28T01:00:31+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=234
permalink: /2011/06/using-utf-8-characters-on-an-e-mail-subject/
categories:
  - PHP
tags:
  - e-mail
  - internationalization
---
If you have sent e-mails in a different language than English or using characters outside the ASCII range you have probably already used utf8 to send them.

Specifying the use of UTF-8 in the body of an e-mail is very similar to doing it for a HTTP response. You can specify the content-type in an e-mail header like this:

```
Content-Type: text/plain; charset=utf-8
```

But there is catch. The subject line of an e-mail is a header by itself, and headers must contain only ASCII characters. Happily, there is a work around. RFC 1342 is a recommendation that provides a way to represent non ASCII characters inside e-mail headers in a way that won&#8217;t confuse e-mail servers.

<!--more-->

To encode a header using this technique you must use this format:

```
=?charset?encoding?encoded-text?=
```

And this is an example of its use:

```
=?utf-8?Q?hello?=
```

The encoding must be either **B** or **Q**, these mean base 64 and quoted-printable respectively. You can read the RFC 1342 document for more information about how they work.

I am going to show a snippet of how to use php&#8217;s mail function to send an e-mail using UTF-8 in the subject and content.

```php
$to = 'example@example.com';
$subject = 'Subject with non ASCII ó¿¡á';
$message = 'Message with non ASCII ó¿¡á';
$headers = 'From: example@example.com'."\r\n"
.'Content-Type: text/plain; charset=utf-8'."\r\n";
mail($to, '=?utf-8?B?'.base64_encode($subject).'?=', $message, $headers)
```
