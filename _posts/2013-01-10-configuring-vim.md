---
id: 1057
title: Configuring Vim
date: 2013-01-10T04:38:40+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=1057
permalink: /2013/01/configuring-vim/
tags:
  - linux
  - productivity
  - programming
  - vim
---
In order to make Vim work the way I like I had to install some plugins:

## Pathogen

Makes it easy to manage your plugins. To install:

```
mkdir -p ~/.vim/autoload ~/.vim/bundle; \
curl -Sso ~/.vim/autoload/pathogen.vim \
    https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim
```

And add this to your .vimrc:

```
call pathogen#infect()
```

<!--more-->


  
## NERDTree and NERDTree tabs

Adds a file system navigator to the left of your vim window so you can browse your files. To install:

```
cd ~/.vim/bundle
git clone https://github.com/scrooloose/nerdtree.git
```

NERDTree tabs allows you to have the file browser on the left of the windows independently of which tab you are on:

```
cd ~/.vim/bundle
git clone https://github.com/jistr/vim-nerdtree-tabs.git
```

To show the file browser every time you start vim add this to your vimrc file:

```
let g:nerdtree_tabs_open_on_console_startup=1
```

Now that we have our NERDTree that works good with tabs installed there is some stuff we need to know. The left part of the window that will show your file system is a vim buffer as the area were your working file is. You can have may buffers open at the same time in vim and you can move between them using:

```
Ctrl+ww
```

When you are browsing files you can open a file in a new tab by pressing **t**, else it will be opened in the current work buffer.

## Command-T

> I don&#8217;t use Command-T anymore. I switched to [CtrlP](http://kien.github.io/ctrlp.vim/ "CtrlP") because it&#8217;s easier to install and doesn&#8217;t require ruby

Provides a very fast way of opening files similar to what TextMate&#8217;s Command+T shortcut does. You can get it from: <https://wincent.com/products/command-t> and install following the instruction in here <http://git.wincent.com/command-t.git/blob_plain/HEAD:/doc/command-t.txt>

If you have problems during the installation it could be because you don&#8217;t have ruby or rubygems installed:

```
sudo apt-get install ruby rubygems ruby-dev
```

Once you have the plugin installed you can start using with this command: **:CommandT** or with the shortcut **<leader>T** (the leader key is **\** by default). Then you can start typing and it will look for files that match what you typed.

One thing to have in mind is that the plugin will start searching for files from the current vim path (the path you were on when you opened vim), so you will probably want to invoke vim from inside the project folder you are going to be working on.

If you started searching for a file but you want to cancel the search and go back to the file you were working on you can do so by using the **Ctrl+C** shortcut.

To move from the prompt to the file list and back you can use the **Tab** key.

To open a file you can just click enter when it is highlighted but you may want to add this to your vimrc file so it always opens in a new tab:

```
let g:CommandTAcceptSelectionTabMap = '<CR>'
```

## Find in files (Grep)

Another essential tool for developers is the ability to search for a string inside all files in a project. For this job we have grep.vim. To install we just need run these commands:

```
mkdir -p ~/.vim/plugin
curl -Sso ~/.vim/plugin/grep.vim \
    https://raw.githubusercontent.com/vim-scripts/grep.vim/master/plugin/grep.vim
```

Now you can use **Rgrep** to do recursive searches with this format:

```
:Rgrep  [<grep_options>] [<search_pattern> [<file_name(s)>]]
```

A common way I use it is:

```
:Rgrep -i someMethod *
```

It is important to mention that using this syntax you can&#8217;t find strings with spaces, if you want to do so you should just do:

```
:Rgrep -i
```

And then you will be prompted for the string you want to search for, and the search path.

After executing a search you will see the results in a quickfix buffer. You can see the results and move through the list using the arrow keys on your keyboard. If you press enter the selected occurrence will be opened in the current window you were working on. This is not a behavior I like so to make it open in a new tab instead you will need to add this line to your .vimrc file:

```
set switchbuf+=usetab,newtab
```

Also a few things you may need to know are: To close the quickfix buffer use **:ccl**, to reopen the quickfix buffer or to go back to it after selecting a result **:copen**.

## Nerd Commenter

Allows you to rapidly comment or uncomment multiple lines of code. To install

```
cd ~/.vim/bundle
git clone https://github.com/scrooloose/nerdcommenter.git
```

Then add this to your .vimrc file:

```
filetype plugin on
```

Now you can comment lines with **<leader>cc** and uncomment them with **<leader>cu**. You can do this either in normal or in visual mode.

## Tagbar

Provides a sidebar to navigate the classes, attributes, methods, etc&#8230; of a source code file. This plugin depends on **Exuberant Ctags** so we need to install it first. In Ubuntu based systems you can use this command to install it:

```
sudo apt-get install exuberant-ctags
```

Now we can go ahead and install tagbar:

```
cd ~/.vim/bundle
git clone git://github.com/majutsushi/tagbar.git
```

Once installed you may want to add this to your vimrc file:

```
nmap <F8> :TagbarOpen fj<CR>
```

This will allow you to open the tagbar sidebar using the F8 key. To go back to edit the file you were working on you can just select a function and click enter while having it selected.

## Snipmate

Allows you to create shortcuts for rapidly including code snippets in a file. To install:

```
cd ~/.vim/bundle
git clone git://github.com/msanders/snipmate.vim.git
```

Once installed you will have access to a set of snippets that come shipped with the plugin by default. You can see the snippets in the folder ~/.vim/bundle/snipmate.vim/snippets . There is a different file for each supported programming language. You can open any file and see which snippets are supported by default for that language. The syntax is pretty simple so if you want to modify a snippet or add your own you can do that. To use a snippet you just need to type the trigger text and then press the tab key while working on a file that uses the desired programming language.

For example if you are on a .php file and you enter **php** and then hit tab you will get this snippet:

```
<?php

?>
```

## Syntastic

Syntastic is a plugin that checks for syntax errors on different programming languages so you see them on your editor before you try to compile or execute your code. To install:

```
cd ~/.vim/bundle
git clone https://github.com/scrooloose/syntastic.git
```

Now vim will tell you when you have a syntax error while working on a source code file.

## Make shift+tab unindent a line

Add this to your .vimrc file

```
imap <S-Tab> <Esc><<i
nmap <S-tab> <<
```

This would normally be all you need to do, but since SnipMate uses Shift+Tab by default to move backwards on a snippet we need to configure SnipMate to use something else. Luckily SnipMate makes it very easy for us, we just need to modify ~/.vim/bundle/snipmate.vim/after/plugin/snipMate.vim. There is a section that says &#8220;You can safely adjust these mappings to your preferences&#8221; near the beginning of the file where the shortcuts are defined. I modified both s-tab mappings to look like this:

```
ino <silent> <s-F12> <c-r>=BackwardsSnippet()<cr>
snor <silent> <s-F12> <esc>i<right><c-r>=BackwardsSnippet()<cr>
```

## Troubleshooting

I have run into some issues in some operating systems when installing some plugins mostly because my version of vim is too old or/and doesn&#8217;t have ruby support. You can find a solution for this in [How to Install Vim 7.3 on Ubuntu 10.04 With Ruby and Python Support](http://www.davidxia.com/2012/03/how-to-install-vim-7-3-on-ubuntu-10-04-with-ruby-and-python-support/ " How to Install Vim 7.3 on Ubuntu 10.04 With Ruby and Python Support")

## My .vimrc file

```vim
" I want my files to be utf-8 "
set encoding=utf-8

" Automatic syntax highlight "
syntax on

" Necessary for NerdCommenter to work "
filetype plugin on

" Reload files modified outside of Vim "
set autoread

" Stop vim from creating automatic backups "
set noswapfile
set nobackup
set nowb

" Replace tabs with spaces "
set expandtab

" Make tabs 4 spaces wide "
set tabstop=4
set shiftwidth=4

" If I am in an indented block of code, keep the indentation level when I "
" press enter "
set autoindent

" Show line numbers "
set number

" Highlight all occurrences of a search "
set hlsearch

" Highlight column 81 to help keep lines of code 80 characters or less "
set colorcolumn=81

" Allows normal mode to autocomplete paths using tab like bash does "
set wildmenu
set wildmode=list:longest

" Show tabs and trailing spaces "
set list listchars=tab:→\ ,trail:·

" When choosing a file from a quickfix buffer, open in a new tab or in "
" an already opened tab "
set switchbuf+=usetab,newtab

" Shift+Tab unindents a line "
imap <S-Tab> <Esc><<i
nmap <S-tab> <<

" Allow the use of 256 colors in the terminal "
set t_Co=256

" Set color scheme "
colorscheme summerfruit256

" Remove trailing spaces when saving a file "
autocmd BufWritePre * :%s/\s\+$//e

" Start pathogen plugins "
call pathogen#infect()

" Open the tagbar plugin by pressing F8 "
nmap <F8> :TagbarOpen fj<CR>

" Open nerdtree plugin when vim starts "
let g:nerdtree_tabs_open_on_console_startup=1

" When pressing enter while in a Command-T list, the file will open in a new tab "
let g:CommandTAcceptSelectionTabMap = '<CR>'

" Fix backspace not working "
set backspace=indent,eol,start
```
