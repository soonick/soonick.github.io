---
title: Setting up LSP in Vim
author: adrian.ancona
layout: post
date: 2021-12-22
permalink: /2021/12/setting-up-lsp-in-vim
tags:
  - open_source
  - productivity
  - programming
---

In a previous article, I explained a little about [how Language Server Protocol clients work](/2021/12/implementing-a-language-server-protocol-client). This time I'm going to explain how we can take advantage of this protocol in Vim.

## Installing vim-lsp

Configuring [`vim-lsp`](https://github.com/prabirshrestha/vim-lsp) is a little more complicated than installing other plugins, because it requires many pieces to be put together in order for it to work correctly.

Let's start by installing `vim-lsp`:

```sh
cd ~/.vim/pack/my-plugins/start
git clone https://github.com/prabirshrestha/vim-lsp.git
```

<!--more-->

Before we can use the plugin, we need to do some configuration. More specifically, we need to tell the plugin where it can find the language server for a particular programming language.

Let's try to get this to work with for Java. We can find instructions for downloading the Java Language Server binary in my [Implementing a Language Server Protocol client](/2021/12/implementing-a-language-server-protocol-client) article.

We can tell `vim-lsp` to use the our Java Language Server by adding something like this to our `vimrc` file:

```vim
au User lsp_setup call lsp#register_server({
        \   'name': 'eclipse-jdt-ls',
        \   'cmd': {server_info->[
        \     'java',
        \     '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        \     '-Dosgi.bundles.defaultStartLevel=4',
        \     '-Declipse.product=org.eclipse.jdt.ls.core.product',
        \     '-Dlog.level=ALL',
        \     '-noverify',
        \     '-Xmx1G',
        \     '-jar',
        \       expand('~/bin/jdt-server/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar'),
        \     '-configuration',
        \       expand('~/bin/jdt-server/config_linux'),
        \     '-data',
        \       expand('~/bin/jdt-server/data'),
        \     '--add-modules=ALL-SYSTEM',
        \     '--add-opens',
        \       expand('~/bin/jdt-server/java.base/java.util=ALL-UNNAMED'),
        \     '--add-opens',
        \       expand('~/bin/jdt-server/java.base/java.lang=ALL-UNNAMED')
        \   ]},
        \   'allowlist': ['java'],
        \ })
```

This should be enough to get some functionality working. For example, when we are working on a `java` file, we can put our cursor on top of a type and use:

```vim
:LspDefinition
```

To open the file where that type is defined. This is just one of the many commands that are available to us now.

Typing these commands can be time consuming, so we might want to create shortcuts for them. For example, we can make it so `gd` takes us to the declaration by adding this to our `vimrc`:

```vim
nmap gd :LspDefinition<CR>
```

This can be done for any command we intend to use often.

## Autocomplete

This is probably one of the most desired features in an IDE. Sadly, `vim-lsp` doesn't provide code completion by itself.

To enable code completion in vim, we need [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim). This plugin takes care of listening to our keystrokes and showing auto-complete suggestions in a pop-up.

To install it:

```bash
cd ~/.vim/pack/my-plugins/start
git clone https://github.com/prabirshrestha/asyncomplete.vim.git
```

To integrate with `vim-lsp`, we also need this other plugin:

```bash
cd ~/.vim/pack/my-plugins/start
git clone https://github.com/prabirshrestha/asyncomplete-lsp.vim.git
```

This is all we need for autocomplete suggestions to start popping up as we type:

[<img src="/images/posts/vim-code-completion.png" alt="Vim code completion" />](/images/posts/vim-code-completion.png)

We can navigate the options with the arrow keys and select the one we want by pressing `enter`.

While in theory, this is all that's needed, I found the performance of the automatic pop-up was really bad for me, so I decided to disable it by adding this to my `~/.vimrc`:

```vim
let g:asyncomplete_auto_popup = 0
```

To trigger the pop-up manually, we can type `Ctrl+n`. This combination also works to cycle forward through the options in the pop-up. We can use `Ctrl+p` to cycle backwards. Once we find the option we want, we can just continue typing and the highlighted option will be selected.

## Automatically configure language servers

In the beginning of this article we downloaded the LSP for java and configured our `.vimrc` so vim knows how to use it. Configuring the LSP requires knowledge about the specific server options, so it can be complicated for some languages.

If we want to support multiple programming languages, configuring each of them manually can be a lot of work. For this reason [vim-lsp-settings](https://github.com/mattn/vim-lsp-settings) was created.

This plugin takes care of automatically installing and configuring LSP servers for different languages.

To install the plugin:

```bash
cd ~/.vim/pack/my-plugins/start
git clone https://github.com/mattn/vim-lsp-settings.git
```

When we open a file with an extension supported by `vim-lsp-settings`, that we haven't already installed, we'll see a message like this one at the bottom of the screen:

```vim
Please do :LspInstallServer to enable Language Server typescript-language-server
```

We can then use the `:LspInstallServer` command to have the server be automatically installed and configured for us.

## Conclusion

Getting LSP to work on vim has been a struggle for me for a few years, so I'm really happy I finally achieved it.

The tests I have done look promising, but I did notice that the performance is not great. It takes some time for the server to load and to perform some actions. If I find any insights to improve the performance I'll try to write about them.
