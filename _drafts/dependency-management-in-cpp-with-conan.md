---
title: Dependency management in C++ with Conan
author: adrian.ancona
layout: post
tags:
  - c++
  - programming
  - dependency_management
  - automation
  - productivity
---

I consider [dependency management](/tag/dependency_management) something that I need to figure out before I start any serious software project. Once you start writing software that depends on other code, it can quickly become unmanageable to do dependency management by hand (manually download everything the project needs).

Since C++ has been out for a while, I expected there to be a stable way to do dependency management. Looking around I found that there is no community agreed way of doing it. The project I found has most support is [Conan](https://conan.io/), so I decided to give it a try.

## Conan

Conan is a project owned by [JFrog](https://jfrog.com/). JFrog has been a major player in package/dependency management in the Java world, so it has a lot of experience on this environment.

As with most package managers out there, you can host your own private repository if you need it. For my use case, I will only be working with open source, so I can use [Bintray](https://bintray.com/), which is a public repository for open source software.

## Installing Conan

In order to use Conan, we need to first intall the command line utility. Since Conan is built in python, the preferred way to install it is using PIP. You can look at my [Introduction to PIP](/2015/08/introduction-to-pip/) article to get an idea of how it works.

```python
pip install conan
```

In Linux, you might need to use `sudo` for the installation to go through. If you have trouble, I recommend you take a look at the [official install documentation for Conan](https://docs.conan.io/en/latest/installation.html).


###### Need to write an article about CMake
