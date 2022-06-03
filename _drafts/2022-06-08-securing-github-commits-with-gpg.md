---
title: Verifying Github commits with GPG
author: adrian.ancona
layout: post
date: 2022-06-08
permalink: /2022/06/verifying-github-commit-with-gpg
tags:
  - git
  - security
---

At the time of this writing, Github is the most popular place to host open source projects on the internet. It has a lot of features that make it easy to collaborate, navigate the code, test, deploy, etc.

Since it's so popular, it's important to understand a little about how security works on Github.

## Security

When we create a new repository on Github we are the only ones who are allowed to write to that repository.

If we want to allow other people to write to a repository we can add them as a `collaborator`. Collaborators have a lot of power, so they should be people we know well and trust.

<!--more-->

When we try to write to the repository (e.g. by doing `git push`), the SSH protocol is used to prove we are the owner of a private key that is authorized.

More commonly, contributions by are done via pull requests. A user forks our repository, makes changes there and then submits a pull request. This pull request can then be reviewed by a collaborator and merged into the project if we decide to do so.

With this, we can be sure that only people allowed to write to a repo can actually do so, but there is an interesting problem with how commit authoring works in git.

## Commit authors

When we create a commit in git, the author of the commit is defined by the `user.email` and `user.name` configuration values.

If you are curious what those values are for you, you can check them with these commands:

```
git config user.email
git config user.name
```

The interesting thing about these values is that we can set them to anything we want:

```
git config --global user.name "Tom cruise"
git config --global user.email "tom@cruise.com"
```

They can be made up like my example above, but they could also be a real name and email adress from another developer, which could have very bad consequences.

Since this can be used maliciously, Github has a way to allow users to identify themselves as the actual owner of an e-mail address.

## PGP

[PGP (Pretty Good Privacy)](https://en.wikipedia.org/wiki/Pretty_Good_Privacy) is a set of tools that can be used to encrypt and sign files. [GPG (The GNU Privacy Guard)](https://gnupg.org/) is an open source implementation of PGP available for most popular operating systems.

We are mostly interested in the `signing` functionality, which allows us to tell the world that we are the real actors of a commit.

## Generating a GPG key pair

GPG works similarly to SSH in that we need to generate a key pair. To generate our keys we need the `gpg` program. On Ubuntu we can get it with this command:

```
sudo apt-get install gnupg
```

Once we have `gpg` we need to generate a key pair:

```
gpg --gen-key
```

To see our key, we can use this command:

```
gpg --list-secret-keys
```

The output looks something like this:

```
/home/adrian/.gnupg/pubring.kbx
-------------------------------
sec   rsa3072 2022-06-03 [SC] [expires: 2024-06-02]
      0254A18FE8B483A6D1FFCD89F86AD8F1C196F31F
uid           [ultimate] Adrian Ancona Novelo <soonick5@yahoo.com.mx>
ssb   rsa3072 2022-06-03 [E] [expires: 2024-06-02]
```

In the example above, `0254A18FE8B483A6D1FFCD89F86AD8F1C196F31F` is the `id` of the key. Your `id` will be different.

For uploading our key to Github, we need the public key in PEM format. To get it, use this command:

```
gpg --armor --export <your key id>
```

This command will generate something similar to:

```
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
=lgLE
-----END PGP PUBLIC KEY BLOCK-----
```

This is our public key. Now we need to upload it to Github.

## Uploading our public key to Github

First, we need to go to the settings for our account:

[<img src="/images/posts/github-settings.png" alt="Github settings" />](/images/posts/github-settings.png)

Then go to `SSH and GPG keys`:

[<img src="/images/posts/github-keys.png" alt="Github keys" />](/images/posts/github-keys.png)

Click on the `New GPG key` button:

[<img src="/images/posts/github-new-gpg-key.png" alt="Github new gpg key" />](/images/posts/github-new-gpg-key.png)

And fill the form:

[<img src="/images/posts/github-gpg-key-form.png" alt="Github new gpg key" />](/images/posts/github-gpg-key-form.png)

Now Github knows we own the private key for the public key we just uploaded.

## Signing commits

The only step that is missing is telling git to sing our commits using GPG.

```
git config commit.gpgsign true
git config user.signingkey <your key id>
```

If everything goes well, from now on, our commits will have a `Verified` mark next to them.

[<img src="/images/posts/github-verified-commit.png" alt="Github verified commit" />](/images/posts/github-verified-commit.png)

## Conclusion

With git, our repositories are secure thanks to SSH, but it allows users to impersonate other users. This can't be prevented at the moment, but it can be made more visible by signing our commits with GPG.
