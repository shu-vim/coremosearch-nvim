# coremosearch-nvim

Neovim plugin to search and highlight multiple words.


## Install

### lazy.nvim

```lua
return { "shu-vim/coremosearch-nvim" }
```

## Usage

Enabled by default on startup.

## Comands

- CoremoSearchAdd
  - `:CoremoSearchAdd [word ...]`
  - add search words
  - or a word under the cursor
  - or selected text
- CoremoSearchRemove
  - `:CoremoSearchRemove [word ...]`
  - remove search words
  - or a word under the cursor
  - or selected text
- CoremoSearchEdit
  - edit search words in a pop-up window
- CoremoSearchClear
  - clear all search words
- CoremoSearchRefresh
  - redraw highlights for search words

## Setup/Config

### Full config

```lua
return {
  "shu-vim/coremosearch-nvim",
  opts = {
    highlights = {
      { bg = '#BB0000', fg = 'white' },
      { bg = '#00BB50', fg = 'white' },
      { bg = '#BB00BB', fg = 'white' },
      { bg = '#50BB00', fg = 'white' },
      { bg = '#0000BB', fg = 'white' },
      { bg = '#BB5000', fg = 'white' },
      { bg = '#00BBBB', fg = 'white' },
      { bg = '#BB0050', fg = 'white' },
      { bg = '#00BB00', fg = 'white' },
      { bg = '#5000BB', fg = 'white' },
      { bg = '#BBBB00', fg = 'white' },
      { bg = '#0050BB', fg = 'white' },
    },
    nohlsearch = true
  },
}
```

### keymaps

```lua
vim.keymap.set('n', 'n', 'n:CoremoSearchRefresh<CR>', { silent = true })
vim.keymap.set('n', 'N', 'N:CoremoSearchRefresh<CR>', { silent = true })
```

<!-- vim: set et ft=markdown sts=2 sw=2 ts=2 :  -->
