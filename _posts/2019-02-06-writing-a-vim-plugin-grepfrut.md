---
title: Writing a vim plugin - Grepfrut
author: adrian.ancona
layout: post
date: 2019-02-06
permalink: /2019/02/writing-a-vim-plugin-grepfrut/
tags:
  - automation
  - programming
  - projects
  - vim
---

I use [grep.vim](https://github.com/vim-scripts/grep.vim) to grep in multiple files within vim. It usually works pretty well, but I recently needed a little more freedom in how I specify the files in which I want to search, and found that it can't do what I want. I looked at the code and found that modifying it to do what I want would be hard with the current design, so I decided to create my own plugin.

The plugin I'm going to create is going to be very simple. It is going to provide simple greping functionality with a similar UI to grep.vim, but will allow more freedom on filtering which files to search.

<!--more-->

## VimL - Vimscript

VimL (or Vimscript) is the language used by Vim for mostly everything. The `.vimrc` file used for configuring Vim is written in VimL. VimL is the only way to write a plugin for Vim, so it is necessary to get familiar with it before we start.

### Introduction

If you have written a `.vimrc` file, you already know how to create a comment in VimL:

```viml
" This is a comment in VimL
```

A command that will be useful for debugging while writing our plugin is `echomsg`. This command will output a message to the user, and it will also save it to the message history. The command can be used like this:

```viml
echomsg "This is a message"
```

We can execute any command from within a Vim session by preceding it with `:`, for example:

```viml
:echomsg "This is a message"
```

To see the message history we can use:

```viml
:messages
```

We can get more information about any command with the `help` command:

```viml
:help messages
```

### Variables

VimL is a scripting programming language, so it has variables, conditions, loops, etc. Let's explore them.

To create a variable, we use the `let` command:

```viml
let some_variable = "some value"
```

If we want to modify the value of the variable, we have to use the `let` command too:

```viml
" This is an error:
some_variable = "some value"

" This is correct:
let some_variable = "another value"
```

Variables can be accessed by their name:

```viml
echomsg some_variable
```

We can also access vim options, by preceding them with `&`:

```viml
echomsg &number
```

The `number` option tells us if line numbers are enabled in the current buffer. If line numbers are enabled, it will print `1`, otherwise it will print `0`. We can also set options programatically using `let`:

```viml
let &number = 1
```

The code above enables line numbers in the current buffer.

### Conditions

As most other programming languages, VimL uses `if` for writing conditionals:

```viml
if 0
  echomsg "some message"
elseif 1
  echomsg "some other message"
else
  echomsg "last message"
endif
```

In the example above `some other message` will be printed. As expected, 0 is false and 1 is true. VimL always uses numbers to evaluate truthness of a value. If the value is 0, then it's false, any other number is true. If a string is used in a condition, it will be converted to a number and evaluated using the same rules:

```
0 -> false
1 -> true
20 -> true
"hello" -> false
"0 something" -> false
"7 dwarfs" -> true
```

You can also use comparisons on conditionals. For the most part they work as expected:

```viml
if 22 > 10
  echomsg "yes"
endif

if 22 == 22
  echomsg "yes"
endif

if "abc" != "def"
 echomsg "yes"
endif
```

All these conditions evaluate to true. One thing to keep in mind is that string comparisons might or might not be case-sensitive depending on user settings. Because of this, we should always use `==? (case-insensitive comparison)` and `==# (case-sensitive comparison)` when comparing strings.

### Functions

Functions are defined by using the `function` keyword:

```viml
function Something()
  echomsg "Something"
endfunction
```

Functions should always start with a capital letter. To run it we use `call`:

```viml
call Something()
```

Functions are more useful when they take arguments and return values:

```viml
function Hello(name)
  return "Hello " . a:name
endfunction
```

The function receives a single argument called `name`. Inside the function body it is accessed by preceding it with `a:`. This is the scope of the variable, there are different scopes a variable can have. Another new thing is the concatenation operator `.`, it adds two strings together.

We can call this function:

```viml
call Hello("world")
```

Functions can also be used in expressions:

```viml
let output = Hello("world")
```

`output` now contains the string `Hello world`.

### Commands

Something that we will need if we are creating a plugin, is to define commands. Commands can be used by the user from normal mode, for example `help` is a built in command:

```viml
:help messages
```

The signature for defining a command is:

```viml
:command {attributes} {name} {replacement}
```

I'm not going to go in a lot of depth into it, because you can get good information with `:help command`, but this is an example:

```viml
:command -nargs=0 Hello echo "Hello everybody!"
```

What `-nargs=0` means is that this command doesn't expect any arguments. If you give it any arguments, an error will be shown. All the command does is echo `Hello everybody!` when the `Hello` command is used.

User defined commands must start with a capital letter.

## Writing a plugin

Hopefully, at this point we know enough about `VimL` to be able to write our plugin.

The plugin that I'm going to write is going to be very simple. It will allow us to search for a string in multiple files in a directory (using grep). I used [grep.vim](https://github.com/vim-scripts/grep.vim) as an example to learn how many things work, but my plugin is a lot simpler. I decided to name it `Grepfrut`

In Vim 8, plugins that will be loaded when Vim is started are located inside `~/.vim/pack/my-plugins/start`. We will be creating a new folder called `grepfrut`, and inside the folder we'll have this structure:

```
grepfrut/
|-- README.md
|-- plugin/
    |--- grepfrut.vim
```

All the code will be in grepfrut.vim. README.md will be used for documentation.

Before we start to write code, we have to decide what it will do. I want to keep it very simple. To use the plugin we will start with the `Gf` command:

```viml
:Gf <search string>
```

The user will be then prompted for the directory where they want to search (current directory will be prefilled):

```
Start searching from directory: /current/directory
```

Then we'll allow the user to filter which files to search:

```
Search files matching pattern (Empty will match all):
```

And lastly, which files to not search:

```
Exclude files matching pattern (Empty will not exclude any file):
```

The results will be shown in a quickfix window and pressing enter on any of the results will open a tab with that file on the correct line.

We start by creating the command:

```viml
command! -nargs=1 Gf call s:Grepfrut(<f-args>)
```

The command receives only one argument (even if there are spaces, it will be read as a single argument) and that argument will be passed to a function called `Grepfut`. The `s` preceding the function name means that the funtion is local to the file (`:help internal-variables` to learn about scopes).

Let's now define `s:Grepfrut`, which will basically take care of the UI:

```viml
" Entry point for the plugin
" search_string is the string we are going to grep for
function s:Grepfrut(search_string)
  " Ask user which directory they want to search
  let cwd = getcwd()
  let search_dir = input("Start searching from directory: ", cwd, "dir")

  " Which files to search
  let search_files = input("Search files matching pattern (Empty will match all): ")

  " Which files to not search
  let exclude_files = input("Exclude files matching pattern (Empty will not exclude any file): ")

  " Run the command
  echo "\r"
  let cmd = s:BuildGrepCommand(a:search_string, search_dir, search_files, exclude_files)
  call s:RunCommand(cmd)
endfunction
```

This function will basically show the correct prompts to the user and then leave the actual execution work to `s:BuildGrepCommand` and `s:RunCommand`.

```viml
" Builds the command to grep for the search_string in all files
" search_string - The string we are searching for
" dir - The directory where the search will start
" include_files - Only files in `dir` matching this pattern will be grepped. If
"                 include_files is empty, all files will be grepped
" exclude_files - Files matching this pattern will not be grepped. If empty, all
"                 files will be grepped
function s:BuildGrepCommand(search_string, dir, include_files, exclude_files)
  let cmd = "find " . a:dir . " -type f "

  if a:include_files != ""
    let cmd = cmd . " | grep \"" . a:include_files . "\""
  endif

  if a:exclude_files != ""
    let cmd = cmd . " | grep -v \"" . a:exclude_files . "\""
  endif

  let cmd = cmd . " | xargs grep -n \"" . a:search_string . "\""

  return cmd
endfunction
```

This function builds the correct grep command based on the user input. For example, if the user is searching for `something` in `/some/dir` in all `cpp` files, except the ones with `test` in the name, it will generate this command:

```bash
find /some/dir -type f | grep "cpp" | grep -v "test" | xargs grep -n "something"
```

The last thing left is to execute the command and add it to the quickfix:

```viml
" Run the command and show results in quickfix
" cmd - The grep command that will be executed
function s:RunCommand(cmd)
  let cmd_output = system(a:cmd)

  " Open the output in a quickfix window
  cgetexpr cmd_output
  copen
endfunction
```

That's it. A simple Vim plugin. I uploaded the [Grepfrut plugin to Github](https://github.com/soonick/grepfrut) in case you want to try it or see all the code together.
