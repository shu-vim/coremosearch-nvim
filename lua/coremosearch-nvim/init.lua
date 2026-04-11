local M = {}

M.config = {
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
  nohlsearch = true,
}

local function escape(s) return vim.fn['escape'](s, [[\$.*/[]^"]]) end

local function get_word_under_cursor() return vim.fn['expand']('<cword>') end

-----

function M.setup(args)
  M.config = vim.tbl_deep_extend('force', M.config, args or {})

  if M.config.nohlsearch then vim.o.hlsearch = false end
end

function M.strip_magic(expr)
  local stripped = vim.fn['substitute'](expr, [=[\v^\\[vVmM]]=], '', '')
  return stripped
end

function M.init_highlights()
  for i, hi in ipairs(M.config.highlights) do
    vim.cmd('highlight clear CoremoSearch' .. tostring(i))
    pcall(vim.cmd, 'syntax clear CoremoSearch' .. tostring(i))
    vim.api.nvim_set_hl(0, 'CoremoSearch' .. tostring(i), hi)
  end
  vim.api.nvim_set_hl(0, 'CoremoSearch', M.config.highlight_exceeded)
end

function M.refresh_hightlights(words)
  if vim.o.hlsearch then return end

  local lazyredraw = vim.o.lazyredraw
  vim.o.lazyredraw = true
  M.init_highlights()

  for i, word in ipairs(words) do
    vim.notify('highlight ' .. tostring(i) .. ' ' .. word, 'debug')
    if i <= #M.config.highlights then
      vim.cmd('syntax match CoremoSearch' .. tostring(i) .. ' "' .. word .. '" containedin=ALL')
    else
      vim.cmd('syntax match CoremoSearch' .. ' "' .. word .. '" containedin=ALL')
    end
  end
  vim.o.lazyredraw = lazyredraw
end

function M.split_regexp(expr)
  local all = vim.fn['split'](expr, [[\V\\\@<!\\|]]) -- split by '\|' NOT next to '\': abc\|def\\|ghi
  return all
end

function M.add_search(words)
  local sreg = M.strip_magic(vim.fn['getreg']('/'))
  local all = M.split_regexp(sreg)
  vim.notify('all: ' .. vim.inspect(all), 'debug')
  for _, word in ipairs(words) do
    if not vim.tbl_contains(all, word) then table.insert(all, word) end
  end
  vim.notify('all: ' .. vim.inspect(all), 'debug')

  vim.fn['setreg']('/', [[\V]] .. table.concat(all, [[\|]]))
  M.refresh_hightlights(all)
end

function M.remove_search(words)
  local sreg = M.strip_magic(vim.fn['getreg']('/'))
  local all = M.split_regexp(sreg)
  vim.notify('all: ' .. vim.inspect(all), 'debug')
  all = vim.tbl_filter(function(item)
    for _, word in ipairs(words) do
      if item == word or item == '\\<' .. word .. '\\>' then return false end
    end
    return true
  end, all)
  vim.notify('all: ' .. vim.inspect(all), 'debug')

  if #all == 0 then
    M.clear()
    return
  end

  vim.fn['setreg']('/', [[\V]] .. table.concat(all, [[\|]]))
  M.refresh_hightlights(all)
end

function M.add(opts)
  local words = {}
  if #opts.fargs > 0 then
    words = opts.fargs
  elseif opts.range > 0 then
    local sels = vim.fn.getpos("'<")
    local sele = vim.fn.getpos("'>")
    local lines = vim.api.nvim_buf_get_text(0, sels[2] - 1, sels[3] - 1, sele[2] - 1, sele[3], {})
    table.insert(words, table.concat(lines, '\n'))
  else
    local word = escape(get_word_under_cursor())
    if word == '' then return end
    table.insert(words, word)
  end

  M.add_search(words)
end

function M.remove(opts)
  local words = {}
  if #opts.fargs > 0 then
    words = opts.fargs
  elseif opts.range > 0 then
    local sels = vim.fn.getpos("'<")
    local sele = vim.fn.getpos("'>")
    local lines = vim.api.nvim_buf_get_text(0, sels[2] - 1, sels[3] - 1, sele[2] - 1, sele[3], {})
    table.insert(words, table.concat(lines, '\n'))
  else
    local word = escape(get_word_under_cursor())
    if word == '' then return end
    table.insert(words, word)
  end

  M.remove_search(words)
end

function M.clear()
  vim.fn['setreg']('/', '')
  M.refresh_hightlights({})
end

function M.nohighlight() M.init_highlights() end

function M.edit()
  local words = M.split_regexp(M.strip_magic(vim.fn['getreg']('/')))
  table.insert(words, 1, '# edit search words')
  table.insert(words, 2, '# <C-S>: apply')
  table.insert(words, 3, '# Esc, q: cancel')

  local menu_close = function(win) vim.api.nvim_win_close(win, false) end
  local redraw = function(win)
    local maxwid = 0
    for _, word in ipairs(words) do
      local wid = vim.fn['strdisplaywidth'](word)
      if maxwid < wid then maxwid = wid end
    end
    vim.api.nvim_win_set_width(win, maxwid)
    vim.api.nvim_win_set_height(win, #words)

    vim.api.nvim_buf_set_lines(vim.api.nvim_win_get_buf(win), 0, -1, true, words)

    vim.cmd('normal 4gg')
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-L>', true, true, true), 'n', true)

    local ui = vim.api.nvim_list_uis()[1]
    local config = vim.api.nvim_win_get_config(win)
    config.relative = 'editor'
    config.row = math.ceil((ui.height - #words) / 2)
    config.col = math.ceil((ui.width - maxwid) / 2)
    vim.api.nvim_win_set_config(win, config)
  end

  -- cancel if any floating window exists
  for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).zindex then
      local ok, _ = pcall(vim.api.nvim_win_get_var, win, 'CoremoSearch__list')
      if ok then return end
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = 1,
    height = 1,
    border = (vim.o.ambiwidth == 'double' and { '*', '-', [[\]], '|', '/', '-', [[\]], '|' }) or 'rounded',
    noautocmd = true,
  })
  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = buf,
    callback = function() menu_close(win) end,
  })
  vim.fn.matchadd('Comment', [[\v^#.+]], 0, -1, { window = win })
  vim.api.nvim_win_set_option(win, 'number', false)
  vim.api.nvim_win_set_option(win, 'relativenumber', false)
  vim.api.nvim_win_set_option(win, 'wrap', false)
  vim.api.nvim_win_set_option(win, 'cursorline', false)
  vim.api.nvim_win_set_var(win, 'CoremoSearch__list', {})

  -- keymap
  vim.keymap.set('n', '<Esc>', function() menu_close(win) end, { buffer = buf })
  vim.keymap.set('n', 'q', function() menu_close(win) end, { buffer = buf })
  vim.keymap.set({ 'n', 'i' }, '<C-S>', function()
    local newwords = vim.api.nvim_buf_get_lines(0, 0, -1, {})
    newwords = vim.tbl_filter(function(word) return string.sub(word, 1, 1) ~= '#' and word ~= '' end, newwords)
    vim.fn['setreg']('/', [[\V]] .. table.concat(newwords, [[\|]]))
    menu_close(win)
    M.refresh_hightlights(newwords)
  end, { buffer = buf })

  redraw(win)
end

return M

-- vim: set et ft=lua sts=2 sw=2 ts=2 :
