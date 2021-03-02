---
title: The Language Server Protocol for IDE features
author: adrian.ancona
layout: post
# date: 2021-01-13
# permalink: /2021/01/introduction-to-aws-dynamo-db
tags:
  - open_source
  - productivity
  - programming
  - vim
---

I've been a vim user for a while and I like how easy it makes it for me to write code. I use various plugins for things like grepping for text, finding files in a project, etc. I feel very comfortable with what I have, but sometimes I wonder how it would be to have some powerful features included in most IDEs:

- Auto complete
- Go to definition
- Find references

I have tried a few times to make those features work in vim, but I always fail. This time, I decided to start by learning about a technology that powers vim plugins that offer those features.

## Language Server Protocol (LSP)

There are a lot of IDEs out there that offer features like auto complete or go to definition. Traditionally each IDE has logic for parsing and understanding code in a project and plugs this understanding into its UI. How good the IDE's understanding of a particular language together with their user experience are their most powerful selling points. Different IDEs that support the same language have their own proprietary code for performing these tasks.

[LSP](https://microsoft.github.io/language-server-protocol/) is an open source protocol created by Microsoft defines for a program that understands a programming language to talk to another program (typically an IDE) that wants to take advantage of these features. This protocol allows anybody to build a server that understands a language and make it available to the world. Tool creators can consume information from this server without having to duplicate the same effort.

## The server

There are various [server implementations](https://microsoft.github.io/language-server-protocol/implementors/servers/) out there and they vary widely in the number of features they support. Some servers might 

At a high level

One of the most popular server implementations is [Eclipse JDT Language Server](https://github.com/eclipse/eclipse.jdt.ls/) for Java.
