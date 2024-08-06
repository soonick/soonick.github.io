---
title: Neovim as ESP32 IDE with Clangd LSP
author: adrian.ancona
layout: post
# date: 2024-04-10
# permalink: /2024/04/asynchronous-programming-with-tokio/
tags:
  - arduino
  - c++
  - electronics
  - esp32
  - productivity
  - programming
  - vim
---

In this article, I'm going to explain how to configure Neovim to work as an IDE for ESP32.

Before we start, we need to have ESP-IDF in our system. You can follow my [Introduction to ESP32 development](/2024/08/introduction-to-esp32-development) article for instructions on how to install it.

## Lazy vim

I use [lazy](https://github.com/folke/lazy.nvim) to manage my Neovim plugins, so let's make sure it's configured correctly. To do that, we need to add these lines to our `init.lua` (usually at `~/.config/nvim/init.lua`):

```lua
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins')
```

<!--more-->

## Plugins

We'll be using a few plugins to configure Neovim. We will be putting our plugin files in `~/.config/nvim/lua/plugins/`.

### [Nvim-LspConfig](https://github.com/neovim/nvim-lspconfig)

This plugin is used to configure our LspClient. To configure it, we'll create `~/.config/nvim/lua/plugins/nvim-lspconfig.lua` with this content:

```lua
return {
  "neovim/nvim-lspconfig",
  config = function()
    require('lspconfig').clangd.setup {}
  end
}
```

### [Mason](https://github.com/williamboman/mason.nvim)

This plugin helps us to install different packages needed by other plugins. To configure it, we'll create `~/.config/nvim/lua/plugins/mason.lua` with this content:

```lua
return {
  'williamboman/mason.nvim',
  build = ":MasonUpdate",
  config = function()
    require("mason").setup()
  end
}
```

### [Mason-LspConfig](https://github.com/williamboman/mason-lspconfig.nvim)

This plugin makes it easier to use Mason and Nvim-LspConfig together. It will make sure our LSP server is downloaded first (by mason) and then configured correctly (by nvim-lspconfig). To configure it, we'll create `~/.config/nvim/lua/plugins/mason-lspconfig.lua` with this content:

```lua
return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    'williamboman/mason.nvim',
  },
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = {
        'clangd',
      }
    })
  end
}
```

### [Nvim-Cmp](https://github.com/hrsh7th/nvim-cmp)

This plugin enables IDE-like auto-completion inside of Neovim. To configure it, we'll create `~/.config/nvim/lua/plugins/nvim-cmp.lua` with this content:

```lua
return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp'
  },
  config = function()
    local cmp = require("cmp")
    cmp.setup({
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-o>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
      }),
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      }, {
        { name = 'buffer' },
      }),
    })
  end
}
```

## Keyboard shortcuts

This step is optional, but it sets up some of my preferred keyboard shortcuts. Since these shortcuts are LSP specific, I put them inside `~/.config/nvim/lua/plugins/nvim-lspconfig.lua`:

```lua
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    -- Go to definition
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', {buffer = event.buf})

    -- Return to previous location after going to definition
    vim.api.nvim_set_keymap('n', 'gb', '<C-t>', {})

    -- Go to definition in new tab
    vim.api.nvim_set_keymap('n', 'gdt', '<C-w><C-]><C-w>T', {})

    -- Code completion
    vim.api.nvim_set_keymap('i', '<C-Space>', '<C-x><C-o>', {})

    -- Don't open an empty buffer when triggering autocomplete
    vim.o.completeopt = 'menu'

    -- Show documentation for symbol
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', {buffer = event.buf})

    -- Format code
    vim.keymap.set('n', 'F', '<cmd>lua vim.lsp.buf.format()<cr>', {buffer = event.buf})

    -- Rename symbol
    vim.keymap.set('n', '3r', '<cmd>lua vim.lsp.buf.rename()<cr>', {buffer = event.buf})
  end
})
```

## ESP-IDF Virtual Environment

ESP-IDF requires a `virtual environment` to work correctly. To ensure Neovim is running inside this environment, we need to use this command (replace `/path-to-esp-idf` with the path where you installed esp-idf):

```bash
. /path-to-esp-idf/export.sh
```

## compile_commands.json

The `clangd` Language Server requires a file named `compile_commands.json`. This file is generated by CMake automatically. We can generate it manually by running CMake for our project.

This is commonly done with these commands:

```
mkdir build
cmake ..
```

## Enjoy

The last step is to start Neovim from our project's root and enjoy. The first time we start Neovim after making these changes, `mason` will need to download the `clangd` Language Server. This might take a couple of minutes, but won't be necessary for future sessions.

## Conclusion

Since ESP32 uses standard C/C++ tooling (CMake), configuring LSP was surprisingly easy. The only important gotcha is the need for the `esp-idf` virtual environment.

If you want an easy way to see it in action, I have added a ready to use example to [my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/neovim-as-esp32-ide-with-clangd-lsp).
