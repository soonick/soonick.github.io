---
title: Spell and Grammar checking on vim
author: adrian.ancona
layout: post
date: 2018-12-12
permalink: /2018/12/binary-search-trees/
tags:
  - vim
  - productivity
---

I recently moved my blog to Jekyll, which means I now write my posts in my favorite editor. One problem I encountered is that vim doesn't check my spelling by default, which means I probably had a lot of mistakes in the last posts I wrote.

Because I prefer people thinking I know how to write, I decided to look for a tool that would help me with this.

## Installation

The first thing I had to do was install Java Runtime:

```
sudo apt install default-jre
```

<!--more-->

Then I had to download `LanguageTool`. I used this command, but you might want to get the latest version:

```
wget https://www.languagetool.org/download/LanguageTool-4.3.zip
unzip LanguageTool-4.3.zip
```

The next step is to download the vim plugin. Because I have vim 8, I used these commands:

```
cd ~/.vim/pack/my-plugins/start
git clone https://github.com/dpelle/vim-LanguageTool.git
```

Finally, I added this line to .vimrc:

```
:let g:languagetool_jar='<path to>/languagetool-commandline.jar'
```

## Usage

While in vim, you can use `:LanguageToolCheck` to start checking the current buffer. You will see something like this:

[<img src="/images/posts/language-tool.png" alt="VIM language tool" width="700" />](/images/posts/language-tool.png)

The UI highlites the errors and shows a buffer in the bottom with a description of the errors and suggestions for fixing them. You can move to the next error by using `:lne`. You can move between buffers using `Ctrl + ww`.

Once you are done, you can use `:LanguageToolClear` to close the language checker.

## Conclusion

That's all it takes. LanguageTool takes a little long to run, but it's better than copying the text into an online checker.
