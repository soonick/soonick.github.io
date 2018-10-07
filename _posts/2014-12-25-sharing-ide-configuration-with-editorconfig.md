---
id: 2444
title: Sharing IDE configuration with EditorConfig
date: 2014-12-25T00:42:27+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=2444
permalink: /2014/12/sharing-ide-configuration-with-editorconfig/
categories:
  - Vim
tags:
  - productivity
  - vim
---
It has happened multiple times that I am doing a code review and I find issues like trailing white space or tabs instead of spaces. This annoys me because it is something that your editor should do for you for free. It annoys me even more when I ask the developer to configure their editor to remove trailing white space and they tell me they don&#8217;t know how to do it. In most scenarios they are using Eclipse or some other fancy IDE that I am not familiar with, so I can&#8217;t help them much. EditorConfig will help me with that problem.

From now on I plan to add an .editorconfig file to all my projects and simply ask my colleagues to install the plugin on their IDE.

Lets see how to install the plugin for VIM. Assuming you have pathogen installed you should only need this:

<!--more-->

```
cd ~/.vim/bundle
git clone https://github.com/editorconfig/editorconfig-vim.git
```

Now you can add a file named .editorconfig to the root of your project. I&#8217;m going to start with something like this for my JS projects:

```
root = true

[*]
end_of_line = lf
insert_final_newline = true
charset = utf-8
indent_style = space
indent_size = 2
trim_trailing_whitespace = true
```

Currently there is a very short list of things you can configure, and their support varies from plug-in to plug-in. Even so I think this will become a very useful tool for my projects.
