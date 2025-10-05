local M = {}

local map = vim.keymap.set
local api = vim.api
local fn = vim.fn

local mark_chars = {
  'a','b','c','d','e','f','g','h','i','j','k','l','m',
  'n','o','p','q','r','s','t','u','v','w','x','y','z',
}

local function auto_markrement()
  local ok, pos = pcall(api.nvim_buf_get_var, 0, 'markrement_pos')
  if not ok then pos = -1 end
  pos = (pos + 1) % #mark_chars
  api.nvim_buf_set_var(0, 'markrement_pos', pos)
  vim.cmd('mark ' .. mark_chars[pos + 1])
  vim.notify('marked ' .. mark_chars[pos + 1], vim.log.levels.INFO, { title = 'Mark' })
end

local function jump_same_indent(direction)
  local total_lines = fn.line('$')
  local current = fn.line('.')

  local function indent_pattern(line)
    if line < 1 or line > total_lines then
      return [[^\S]]
    end
    local indent = fn.matchstr(fn.getline(line), [[\v^\s*]])
    return '^' .. indent .. [[\S]]
  end

  if direction == 'up' then
    if current == 1 then
      return
    end
    vim.cmd('normal! k')
    local pattern = indent_pattern(fn.line('.') + 1)
    fn.search(pattern, 'b')
  else
    local pattern = indent_pattern(current)
    fn.search(pattern, '')
  end

  vim.cmd('normal! ^')
end

local function copy_with_path(first_line, last_line)
  local filepath = fn.expand('%:p')
  local lines = {}
  for lnum = first_line, last_line do
    table.insert(lines, string.format('%s:%d %s', filepath, lnum, fn.getline(lnum)))
  end
  fn.setreg('+', table.concat(lines, '\n'))
end

local function open_dictionary()
  local word = fn.expand('<cword>')
  if word ~= '' then
    fn.jobstart({ 'open', 'dict://' .. word }, { detach = true })
  end
end

local function cursor_jump()
  local path = string.format('%s:%d', fn.expand('%:S'), fn.line('.'))
  fn.jobstart({ 'cursor', '-g', path }, { detach = true })
end

local function set_core_keymaps()
  map({ 'n', 'v', 'o' }, '<Leader>', '<Nop>', { silent = true })
  map('n', '<Leader><Leader>', '<Space>', { silent = true })

  map('n', '<ESC><ESC>', ':nohlsearch<CR>', { silent = true })

  map({ 'n', 'v' }, 'j', 'gj', { silent = true })
  map({ 'n', 'v' }, 'k', 'gk', { silent = true })
  map({ 'n', 'v' }, 'gj', 'j', { silent = true })
  map({ 'n', 'v' }, 'gk', 'k', { silent = true })

  map({ 'n', 'v' }, 'gf', 'gF', { silent = true })
  map({ 'n', 'v' }, 'gF', 'gf', { silent = true })

  map({ 'i', 'c' }, '<C-F>', '<Right>', { silent = true })
  map({ 'i', 'c' }, '<C-B>', '<Left>', { silent = true })
  map({ 'i', 'c' }, '<C-[>', '<Esc>', { silent = true })

  map('n', '<C-O>', '<C-O>zz', { silent = true })
  map('n', '<C-I>', '<C-I>zz', { silent = true })

  map('n', '*', '*zz', { silent = true })
  map('n', 'n', 'nzz', { silent = true })
  map('n', 'N', 'Nzz', { silent = true })

  map('n', 'Q', '<Nop>', { silent = true })
  map('n', 'g?', open_dictionary, { silent = true, desc = 'Open macOS dictionary' })

  map({ 'n', 'v', 'o' }, 'zl', 'zo', { silent = true })
  map({ 'n', 'v', 'o' }, 'zL', 'zO', { silent = true })
  map({ 'n', 'v', 'o' }, 'zh', 'zc', { silent = true })
  map({ 'n', 'v', 'o' }, 'zH', 'zC', { silent = true })

  map('n', '<C-c>', '<Nop>', { silent = true })
end

local function set_extended_keymaps()
  map('n', '[Mark]', '<Nop>', { silent = true })
  map('n', 'm', '[Mark]', { silent = true })

  map('n', 'gm', auto_markrement, { silent = true, desc = 'Auto mark increment' })
  map('n', ']m', "]`", { silent = true })
  map('n', '[m', "[`", { silent = true })

  map('n', '<C-w>n', ':tabnext<CR>', { silent = true })
  map('n', '<C-w><C-n>', ':tabnext<CR>', { silent = true })
  map('n', '<C-w>p', ':tabprevious<CR>', { silent = true })
  map('n', '<C-w><C-p>', ':tabprevious<CR>', { silent = true })
  map('n', '<C-w>t', ':tabnew<CR>:tabmove<CR>', { silent = true })
  map('n', '<C-w><C-t>', ':tabnew<CR>:tabmove<CR>', { silent = true })
  map('n', '<C-w><C-w>', ':tabclose<CR>', { silent = true })

  for i = 1, 9 do
    map('n', ('<A-%d>'):format(i), ('<C-w>%dw'):format(i), { silent = true })
  end

  map('v', 'Y', function()
    copy_with_path(fn.line("'<"), fn.line("'>"))
  end, { silent = true, desc = 'Yank with file path' })

  api.nvim_create_user_command('YankPathLines', function(opts)
    local first = opts.range ~= 0 and opts.line1 or fn.line('.')
    local last = opts.range ~= 0 and opts.line2 or fn.line('.')
    copy_with_path(first, last)
  end, { range = true })

  map('n', '<Leader>es', function()
    vim.cmd('source ' .. fn.stdpath('config') .. '/init.lua')
  end, { silent = true, desc = 'Source init.lua' })
  map('n', '<Leader>ev', function()
    vim.cmd('edit ' .. fn.stdpath('config') .. '/init.lua')
  end, { silent = true, desc = 'Edit init.lua' })
  map('n', '<Leader>et', function()
    vim.cmd('edit ~/.config/nvim/dein.toml')
  end, { silent = true, desc = 'Edit dein.toml' })
  map('n', '<Leader>eu', ':Lazy sync<CR>', { silent = true, desc = 'Lazy sync' })

  map('n', '<Leader>c', cursor_jump, { silent = true, desc = 'Open cursor location' })

  map('n', '<Leader>q', ':q<CR>', { silent = true })
  map('n', '<Leader>Q', ':qa!<CR>', { silent = true })
  map('n', '<C-s>', ':w<CR>', { silent = true })
  map('n', '<C-w>w', ':q<CR>', { silent = true })
  map('n', '<C-w><C-w>', ':q<CR>', { silent = true })
  map('n', '<C-w>W', ':qa!<CR>', { silent = true })

  map('t', '<Esc>', '<C-\\><C-n>', { silent = true })
  map('t', '<C-[>', '<C-\\><C-n>', { silent = true })

  map('n', '<C-k>', function()
    jump_same_indent('up')
  end, { silent = true, desc = 'Jump to previous line with same indent' })
  map('n', '<C-j>', function()
    jump_same_indent('down')
  end, { silent = true, desc = 'Jump to next line with same indent' })

  map('n', '<leader>s', ':%s/\v', { silent = false })
  map('v', '<leader>s', ":'<,'>s/\v", { silent = false })
  vim.cmd([[cnoreabbrev <expr> s getcmdtype() .. getcmdline() ==# ':s' ? [getchar(), ''][1] .. "%s///g<Left><Left>" : 's']])

  api.nvim_set_keymap('c', '<C-R><C-E>', "<C-R>=expand('%:t:r')<CR>", { noremap = true })
end

function M.setup()
  vim.g.markrement_char = vim.g.markrement_char or mark_chars
  set_core_keymaps()
  set_extended_keymaps()
end

return M
