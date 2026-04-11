local group = vim.api.nvim_create_augroup('coremosearch-nvim', { clear = true })
local cs = require('coremosearch-nvim')

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter', 'FocusGained', 'ColorScheme' }, {
  group = group,
  callback = function() cs.refresh_hightlights(cs.split_regexp(cs.strip_magic(vim.fn['getreg']('/')))) end,
})

vim.api.nvim_create_user_command('CoremoSearchAdd', cs.add, { nargs = '*', range = true })
vim.api.nvim_create_user_command('CoremoSearchRemove', cs.remove, { nargs = '*', range = true })

vim.api.nvim_create_user_command(
  'CoremoSearchRefresh',
  function() cs.refresh_hightlights(cs.split_regexp(cs.strip_magic(vim.fn['getreg']('/')))) end,
  { nargs = '*', range = true }
)

vim.api.nvim_create_user_command('CoremoSearchClear', cs.clear, {})

vim.api.nvim_create_user_command('CoremoSearchEdit', cs.edit, {})
