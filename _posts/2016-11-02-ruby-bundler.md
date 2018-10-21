---
id: 3931
title: Ruby Bundler
date: 2016-11-02T11:24:01+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3931
permalink: /2016/11/ruby-bundler/
tags:
  - bundler
  - programming
  - ruby
---
I&#8217;m working on a Rails project at the moment, and being new to the Ruby ecosystem I decided to learn a little about [Bundler](http://bundler.io/), a framework for managing your project dependencies (similar to npm, composer or pip).

You can install Bundler with the gem command:

```
gem install bundler
```

This will make the bundle command available on your system.

As with other dependency management systems it all starts by creating a file where you specify your dependencies. The file Bundler looks for by default is **Gemfile**.

The Gemfile must specify at least one source where the gems will be downloaded from:

```
source 'https://rubygems.org'
```

<!--more-->

And then a list of dependencies:

```
gem 'nokogiri'
gem 'rails', '5.0.0.1'
```

The Gemfile would look like this:

```
source 'https://rubygems.org'

gem 'nokogiri'
gem 'rails', '5.0.0.1'
```

Once you have the Gemfile in your project folder you can install the dependencies:

```
bundle install
```

After the command finishes you will see a new file called Gemfile.lock. This file contains the exact versions that were installed for each of the dependencies. This file should be checked into version control so all developers use exactly the same versions. When bundle install is ran and Gemfile.lock is found, the vesions in Gemfile.lock will be used.

By default Bundler installs dependencies to Rubygem&#8217;s default directory. To find out what this directory is, you can use:

```
gem env
```

You will get a line similar to this one:

```
 - INSTALLATION DIRECTORY: /home/anovelo/.gem/ruby
```

You can see the gems currently installed on your system with something like this:

```
ls /home/anovelo/.gem/ruby/gems/
```

If you are working on multiple projects in the same machine, having all the dependencies installed in the same place might not be what you want. If you want to create a deployable from your project, it is very helpful to have the dependencies in the project folder. Luckily, Bundler makes this pretty easy, just use this command:

```
bundle install --path vendor
```

This will install all your dependencies inside a folder called **vendor** in your project directory. Some people commit this directory to version control and other people prefer to .gitignore it. They both have advantages and disadvantages, so you can decide whichever you prefer.

Since you are installing your dependencies in a random directory ruby doesn&#8217;t know about, you need to use bundler to execute your script:

```
bundle exec rails main_file
```

This command will make sure that all your dependencies are available to your script and you can **include** them with the require command.

Bundler knows where your dependencies live thanks to the file **.bundle/config** that it generates when you run **bundle install**. If you commit your vendor folder to your version control, then you should also commit the **.bundle** folder so they stay in sync. Otherwise you can give your team the flexibility to install their dependencies wherever they want and only vendor the dependencies on CI when generating an artifact.
