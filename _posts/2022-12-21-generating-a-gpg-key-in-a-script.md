---
title: Generating a GPG key in a script
author: adrian.ancona
layout: post
date: 2022-12-21
permalink: /2022/12/generating-a-gpg-key-in-a-script
tags:
  - automation
  - security
---

In this post we are going to learn how to generate a GPG key without having to answer prompts so it can be added to a script if desired.

We start by creating a file where we'll write the details for our key. This will be the content of the file:

```
%echo Generating GPG key
Key-Type: default
Key-Type: RSA
Key-Length: 3072
Subkey-Type: RSA
Subkey-Length: 3072
Name-Real: Carlos Sanchez
Name-Email: carlos@sanchez.mex
%no-protection
%commit
%echo done
```

And then we can use this command to generate the key:

```bash
gpg --batch --gen-key <file path>
```

We can find all the options for generating the key in [unattended key generation documentation](https://www.gnupg.org/documentation/manuals/gnupg/Unattended-GPG-key-generation.html).
