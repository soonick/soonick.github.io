---
title: The Vim statusline
author: adrian.ancona
layout: post
date: 2019-02-13
permalink: /2019/02/the-vim-statusline/
tags:
  - vim
  - productivity
---

Vim allows us to customize the statusline shown at the bottom of each window. To toggle the statusline visibility, the `laststatus` option can be used. It can be set to any of these values:

```
0: never
1: only if there are at least two windows (default)
2: always
```

If we want to always show the statusline, we can use this command:

```viml
set laststatus=2
```

<!--more-->

## Customizing the statusline

By default, the statusline shows the name of the buffer, but it can be customized quite a bit. To customize the statusline, we can set the `statusline` option:

```viml
set statusline=Hello
```

Because the set command, allows us to set multiple options in one line, spaces have to be escaped:

```viml
set statusline=Hello\ world
```

Many options can be used to customize the statusline (To see all of them, use `help statusline`). I'm going to go over the ones I find more useful.

A useful piece of information to include in the statusline is the path of the file in the current buffer. You can show the full path using `%F`:

```viml
set statusline=%F
```

Because file paths might become very long, you might want to limit the number of characters it can use:

```viml
set statusline=%.40F
```

This will show the last `40` characters of the full path.

I also find useful to know if the file I'm working on has been modified. We can use the `%m` flag for this:

```viml
set statusline=%.40F\ %m
```

The statusline of a buffer with a modified file will look like this:

```
/home/adrian/file.txt [+]
```

As our statusline becomes more complex, it will very quickly become hard to read. To aid reading we can use multiple lines to define it:

```viml
set statusline=%.40F        " Full file path, at most 40 characters
set statusline+=\ %m        " Modified flag
```

Another cool thing we can do is colorize our statusline. To do this we use this format

```viml
set statusline=%.40F        " Full file path, at most 40 characters
set statusline+=%#HLname#   " Use HLname color for content after this
set statusline+=\ %m        " Modified flag
```

`HLname` can be any of the colors returned by the `highlight` command. The actual values vary depending on your current theme and plugins. This is a valid one:

```viml
set statusline=%.40F        " Full file path, at most 40 characters
set statusline+=%#Error#    " Use Error color for content after this
set statusline+=\ %m        " Modified flag
```

To reset the color to the default one we can use `%*`:

```viml
set statusline=%.40F        " Full file path, at most 40 characters
set statusline+=\           " A space
set statusline+=%#Error#    " Use Error color for content after this
set statusline+=%m          " Modified flag
set statusline+=%*          " Restore default highlight
```

If you don't like any of the colors returned by the `highlight` command, you can create your own color:

```viml
highlight MyCustomColor ctermfg=Green ctermbg=Gray
```

To see the available colors, you can use `help cterm-colors`. Now you can use that color:

```viml
set statusline=%.40F                " Full file path, at most 40 characters
set statusline+=\                   " A space
set statusline+=%#MyCustomColor#    " Use MyCustomColor for content after this
set statusline+=%m                  " Modified flag
set statusline+=%*                  " Restore default highlight
```

One last thing I'm going to add, is the current line and column number, but I want this information to be on the right side instead of the left.

First lets look at how to show the current line and column number, as well as the total number of lines in the file. To get the current column number we can use `%c`, for the line number `%l`, and for the total number of lines `%L`. Let's put this together:

```viml
set statusline=%l,                " Line number
set statusline+=\                 " A space
set statusline+=%3c               " Column number
set statusline+=\ \|\             " A separator
set statusline+=%L                " Total number of lines
```

I used `%3c` for the colum number to always reserve at least 3 characters for the column number. I did this because I don't want my statusline to be jumping around too much when I'm moving in a file.

To split the status bar into a left and a right side, we just need to use `%=`:

```viml
set statusline=%.40F                " Full file path, at most 40 characters
set statusline+=\                   " A space
set statusline+=%#MyCustomColor#    " Use MyCustomColor for content after this
set statusline+=%m                  " Modified flag
set statusline+=%*                  " Restore default highlight
set statusline+=%=                  " Split the left and right sides
set statusline+=%l,                 " Line number
set statusline+=\                   " A space
set statusline+=%3c                 " Column number
set statusline+=\ \|\               " A separator
set statusline+=%L                  " Total number of lines
```

As a last touch, I added some colors:

```viml
highlight StatuslineFilename ctermfg=Black ctermbg=DarkGreen
highlight StatuslineModified ctermfg=DarkMagenta ctermbg=LightGreen
highlight StatuslineNumbers ctermfg=Black ctermbg=DarkYellow

set statusline=%#StatuslineFilename#   " Set color for file path
set statusline+=%F                     " Full file path, at most 40 characters
set statusline+=\                      " A space
set statusline+=%#StatuslineModified#  " Set color for modified flag
set statusline+=%m                     " Modified flag
set statusline+=%#StatuslineFilename#  " Set color for the rest of the bar
set statusline+=%=                     " Split the left and right sides
set statusline+=%#StatuslineNumbers#   " Set color for line numbers
set statusline+=%l,                    " Line number
set statusline+=\                      " A space
set statusline+=%-3c                    " Column number
set statusline+=\ \|\                  " A separator
set statusline+=%L                     " Total number of lines
```

This is how this statusline looks:

[<img src="/images/posts/vim-statusline.png" alt="Custom Vim statusline" />](/images/posts/vim-statusline.png)

## Nerdtree

If you use Nerdtree like me, you probably noticed, that the nerdtree buffer adds some information to its statusline, but because it is so narrow, it is impossible to read. To get rid of it, you can add this to your `.vimrc`:

```viml
let g:NERDTreeStatusline = '%#NonText#'
```
