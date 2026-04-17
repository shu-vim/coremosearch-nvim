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
  - adds search words
  - or a word under the cursor
  - or selected text
- CoremoSearchRemove
  - `:CoremoSearchRemove [word ...]`
  - removes search words
  - or a word under the cursor
  - or selected text
- CoremoSearchEdit
  - opens a words-list, you edit search words in the list window
- CoremoSearchJump
  - opens a jump list
  - `j`, `k`: select a word
  - `h`, `l`: jump to prev/next position
- CoremoSearchClear
  - clears all search words
- CoremoSearchRefresh
  - redraws highlights for search words
- CoremoSearchNoHighlight
  - stops the highlighting like `:noh[lsearch]`
- CoremoSearchQuickFix
  - lists matches in quickfix

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
    highlight_exceeded = { link = 'Search' },
    --
    word_boundary_if_noargs = true,
    -- true: `:CoremoSearchAdd<CR>` adds \<word_under_the_cursor\>
    -- false: adds `word_under_the_cursor`
    --
    nohlsearch = true,
    -- true: set nohls on startup.
    --
    use_search_hook = false,
    -- true: hook / * ? # to use :CoremoSearchAdd
  },
}
```

### keymaps

```lua
vim.keymap.set('n', 'n', 'n:CoremoSearchRefresh<CR>', { silent = true })
vim.keymap.set('n', 'N', 'N:CoremoSearchRefresh<CR>', { silent = true })
```

<!-- vim: set et ft=markdown sts=2 sw=2 ts=2 :  -->
