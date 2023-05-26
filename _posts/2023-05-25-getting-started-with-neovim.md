---
title: Getting Started With Neovim
author: adrian.ancona
layout: post
date: 2023-05-25
permalink: /2023/05/getting-started-with-neovim
tags:
  - vim
  - productivity
  - programming
---

I've known about neovim for a long time, but I've never tried it out. My goal for this article is to try to replicate my current vim configuration:

- File explorer
- Grep
- Fuzzy file finder
- Syntax highlight
- .vimrc configuration

If Neovim is as good as people say, I should be able to do that, and it should run faster.

## Installation

Neovim is already [packaged for most OS](https://github.com/neovim/neovim/wiki/Installing-Neovim). Sadly, the version included in Ubuntu is too old for most plugins out there. For this reason, we'll have to build from source.

Install prerequisites:

```
sudo apt-get install ninja-build gettext cmake unzip curl
```

<!--more-->

Get code:

```
git clone https://github.com/neovim/neovim
```

Build and install:

```
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

Once installed, we can start it using `nvim` command. You might need to open a new terminal for your PATH to be refreshed.

## Package manager

I don't use a package manager in Vim, but most tutorials I have read, recommend them, so I'm going to follow the crowd and install one. A quick search tells me that [Lazy](https://github.com/folke/lazy.nvim) is the most loved one at the moment.

First we need to create a file called init.lua:

```
mkdir ~/.config/nvim/
touch ~/.config/nvim/init.lua
```

Then add the following code to that file:

```lua
-- Setup lazy plugin manager
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

## File Explorer

The most popular File Explorer seems to be [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua/wiki/Installation). 

To install the plugin we need to create the file `~/.config/nvim/lua/plugins/nvim-tree.lua`. There are a few default behaviors that I didn't like so I ended up with this content:

```lua
local function open_nvim_tree()
  require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      actions = {
        remove_file = {
          close_window = true,
        },
      },
      on_attach = function(bufnr)
        local api = require('nvim-tree.api')

        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- This part removes f and F mappings which conflict with telescope
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.del('n', 'f', { buffer = bufnr })
        vim.keymap.del('n', 'F', { buffer = bufnr })

        -- Opens nvim-tree when a new tab is created
        local openTreeGrp = vim.api.nvim_create_augroup("AutoOpenTree", { clear = true })
        vim.api.nvim_create_autocmd("TabNew", {
          command = "NvimTreeFindFile",
          group = openTreeGrp,
        })

        -- Closes nvim-tree if it's the last open buffer
        vim.o.confirm = true
        vim.api.nvim_create_autocmd("BufEnter", {
          group = vim.api.nvim_create_augroup("NvimTreeClose", {clear = true}),
          callback = function()
            local layout = vim.api.nvim_call_function("winlayout", {})
            if layout[1] == "leaf" and
                vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree"
                and layout[3] == nil then
              vim.cmd("quit")
            end
          end
        })

        -- Open file in new tab or focus existing buffer if it already exists
        -- When we open a file in a new tab, the old window title stays as nvim-tree.lua
        -- because that was the last buffer for that tab. This fixes it by adding
        -- a Ctrl + T keymap
        local swap_then_open_tab = function()
          local node = api.tree.get_node_under_cursor()
          if node.type == 'file' then
            vim.cmd("wincmd l")
          end
          api.node.open.tab(node)
        end
        vim.keymap.set("n", "<CR>", swap_then_open_tab, opts("Tab drop"))
      end
    })
  end,
}
```

For the icons to render correctly I had to install a [nerd font](https://www.nerdfonts.com/font-downloads) and configure my terminal to use it:

![Nvim-tree](/images/posts/nvim-tree.png)

## Fuzzy File Finder and Grep

[Telescope](https://github.com/nvim-telescope/telescope.nvim) seems to be the most popular plugin for this. To install we need to create `~/.config/nvim/lua/plugins/telescope.lua`, and add this content:

```lua
return {
  'nvim-telescope/telescope.nvim', tag = '0.1.1',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-fzf-native.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    local actions = require("telescope.actions")
    local builtin = require('telescope.builtin')

    -- Open files in new tab or focus on the tab if already open
    require('telescope').setup({
      defaults = {
        mappings = {
          i = {
            ['<CR>'] = function(bufnr)
              require("telescope.actions.set").edit(bufnr, "tab drop")
            end,
          }
        }
      }
    })

    -- ff to find files, fg to grep in files
    vim.keymap.set('n', 'ff', builtin.find_files, {})
    vim.keymap.set('n', 'fg', builtin.live_grep, {})
  end
}
```

This enables fuzzy file finding and grep. To open the file finder we just need to type `ff` to grep, we use `fg`:

![Nvim-telescope](/images/posts/nvim-telescope.png)

## Migrating .vimrc

I've been using vim for a while, so I already have a .vimrc file which I like. Since we are using init.lua as our configuration file, I had translate the configuration to lua. Here is what my configuration looks like now:

```lua
--- No incremental search (only show search results after clicking enter)
vim.opt.incsearch = false;

-- zx centers the cursor 30 lines below the top. I use this sometimes on vertical monitors
vim.api.nvim_set_keymap('n', 'zx', 'zt30k', {})

-- " <Ctrl-j> Pretty formats curent buffer as JSON "
vim.api.nvim_set_keymap('n', '<C-j>', ':%!python -m json.tool<CR>', {})

-- Show tabs and trailing spaces
vim.opt.listchars = {
  trail = '·',
  tab = '→ ',
}
vim.opt.list = true

-- Spell checking
vim.opt.spell = false
vim.opt.spelllang = {'en_us'}
vim.api.nvim_create_autocmd(
  {
    'BufEnter',
    'BufWinEnter'
  },
  {
    pattern = {
      '*.md',
    },
    command = [[:setlocal spell]]
  }
)

-- Highlight current line
vim.opt.cursorline = true
vim.api.nvim_set_hl(
  0,
  'CursorLine',
  {
    bold = true,
    bg = '#333333',
    ctermbg = 235,
  }
)

-- Treat long lines as break lines (useful when moving around in them)
vim.api.nvim_set_keymap('n', 'j', 'gj', {})
vim.api.nvim_set_keymap('n', 'k', 'gk', {})

-- Disallow use of arrow keys to move. Use hjkl instead
vim.api.nvim_set_keymap('n', '<up>', '<nop>', {})
vim.api.nvim_set_keymap('n', '<down>', '<nop>', {})
vim.api.nvim_set_keymap('n', '<left>', '<nop>', {})
vim.api.nvim_set_keymap('n', '<right>', '<nop>', {})

-- Make y(y) and paste(p) operations use the system clipboard
vim.opt.clipboard = 'unnamedplus'

-- Shift+Tab unindents a line
vim.api.nvim_set_keymap('i', '<S-Tab>', '<Esc><<i', {})
vim.api.nvim_set_keymap('n', '<S-Tab>', '<<', {})

-- Visual mode tab/untab identation
vim.api.nvim_set_keymap('v', '<S-Tab>', '<gv', {})
vim.api.nvim_set_keymap('v', '<Tab>', '>gv', {})

-- Replace tabs with spaces
vim.opt.expandtab = true
vim.opt.smarttab = true

-- Set tab size to 2
local TAB_WIDTH = 2
vim.opt.tabstop = TAB_WIDTH
vim.opt.shiftwidth = TAB_WIDTH

-- Set tab size to 4 spaces for Python
vim.api.nvim_create_autocmd("FileType", {
  pattern = "py",
  callback = function()
    local PY_TAB_WIDTH = 2
    vim.opt_local.shiftwidth = PY_TAB_WIDTH
    vim.opt_local.tabstop = PY_TAB_WIDTH
  end
})

-- " For Golang use tabs "
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
  end
})

-- Show line numbers
vim.opt.number = true

-- Highlight column 81
vim.opt.colorcolumn = '81'

-- Search case insensitive if term is all lowercase
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Setup lazy plugin manager
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

## Conclusion

Migrating from `vim` to `neovim` was a little harder than I expected. Plugins exist for all my needs, but configuring them to work the way I want took me a good amount of time. Translating my `.vimrc` to lua was also time consuming since most examples on the internet still use vimscript.

Now that I have it working, I'm happy with the experience. The file browser looks prettier than nerdtree, the file finder and grep modals are easy to use and there are a lot of plugins that make it easy to further configure the experience. I even played a bit with LSP, but I still need to do a little more research into it.
