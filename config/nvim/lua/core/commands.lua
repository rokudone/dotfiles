local M = {}

local api = vim.api
local fn = vim.fn

local function register(name, callback, opts)
  api.nvim_create_user_command(name, callback, opts or {})
end

local function syntax_info(transparent)
  local synid = fn.synID(fn.line('.'), fn.col('.'), 1)
  if transparent then
    synid = fn.synIDtrans(synid)
  end
  local function attrs(id)
    return {
      name = fn.synIDattr(id, 'name'),
      ctermfg = fn.synIDattr(id, 'fg', 'cterm'),
      ctermbg = fn.synIDattr(id, 'bg', 'cterm'),
      guifg = fn.synIDattr(id, 'fg', 'gui'),
      guibg = fn.synIDattr(id, 'bg', 'gui'),
    }
  end
  local base = attrs(synid)
  local linked = attrs(fn.synIDtrans(synid))
  vim.notify(string.format(
    'name: %s ctermfg: %s ctermbg: %s guifg: %s guibg: %s\nlink to\nname: %s ctermfg: %s ctermbg: %s guifg: %s guibg: %s',
    base.name, base.ctermfg, base.ctermbg, base.guifg, base.guibg,
    linked.name, linked.ctermfg, linked.ctermbg, linked.guifg, linked.guibg
  ), vim.log.levels.INFO, { title = 'SyntaxInfo' })
end

local function reload()
  vim.cmd('nohlsearch')
  vim.cmd('doautocmd ColorScheme')
end

local function code_open()
  local repo = fn.system('cd ' .. fn.shellescape(fn.expand('%:p:h')) .. ' && git rev-parse --show-toplevel')
  repo = repo:gsub('[\n\r]+', '')
  if repo ~= '' then
    fn.jobstart({ 'code', '-r', repo }, { detach = true })
  end
  fn.jobstart({ 'code', '-r', fn.expand('%:p') }, { detach = true })
end

local function echo_pwd()
  local path = fn.expand('%')
  api.nvim_echo({ { path, 'Directory' } }, false, {})
end

local function change_directory(opts)
  local target
  if opts.args == '' then
    target = fn.expand('%:p:h')
  else
    target = fn.fnamemodify(opts.args, ':p')
  end

  if target == '' then
    return
  end

  vim.cmd('lcd ' .. fn.fnameescape(target))
  if not opts.bang then
    vim.cmd('pwd')
  end
end

local function set_number()
  vim.opt.number = true
end

local function clear_number()
  vim.opt.number = false
end

local function jq_filter(opts)
  local filter = opts.args ~= '' and opts.args or '.'
  vim.cmd(string.format('%%! jq %s', fn.shellescape(filter)))
end

local function clear_registers()
  for byte = string.byte('a'), string.byte('z') do
    fn.setreg(string.char(byte), '')
  end
  for byte = string.byte('A'), string.byte('Z') do
    fn.setreg(string.char(byte), '')
  end
  for byte = string.byte('0'), string.byte('9') do
    fn.setreg(string.char(byte), '')
  end
  fn.setreg('/', '')
end

local function unpretty_csv()
  vim.cmd([[silent! %s/\v,\s+/,/g]])
end

local function pretty_csv()
  unpretty_csv()
  vim.cmd([[silent execute "%!perl -pe 's/,(\s+[^,]*)/,\"\1\"/g;s/,/,	/g;' | column -t -s='	' 2>/dev/null"]])
end

local function nfc_transform()
  vim.cmd([[silent %!/usr/local/bin/nkf -w --ic=UTF8-MAC]])
end

local function profile_cursor_move()
  local profile_file = fn.expand('~/log/vim-profile.log')
  if fn.filereadable(profile_file) == 1 then
    fn.delete(profile_file)
  end

  vim.cmd('normal! gg')
  vim.cmd('normal! zR')

  vim.cmd('profile start ' .. fn.fnameescape(profile_file))
  vim.cmd('profile func *')
  vim.cmd('profile file *')

  local group = api.nvim_create_augroup('ProfileCursorMove', { clear = true })
  api.nvim_create_autocmd('CursorHold', {
    group = group,
    buffer = 0,
    callback = function()
      vim.cmd('profile pause')
      vim.cmd('quit')
    end,
  })

  for _ = 1, 100 do
    fn.feedkeys('j', 'n')
  end
end

M.clear_registers = clear_registers
M.pretty_csv = pretty_csv
M.unpretty_csv = unpretty_csv

function M.setup()
  register('Reload', reload, {})
  register('Code', code_open, {})
  register('SyntaxInfo', function()
    syntax_info(false)
  end, {})
  register('SyntaxInfoAll', function()
    vim.cmd('source $VIMRUNTIME/syntax/hitest.vim')
  end, {})
  register('PWD', echo_pwd, {})
  register('CD', change_directory, { nargs = '?', complete = 'dir', bang = true })
  register('Num', set_number, {})
  register('Nonum', clear_number, {})
  register('Jq', jq_filter, { nargs = '?', complete = 'file' })
  register('ClearRegs', clear_registers, {})
  register('PrettyCsv', function()
    pretty_csv()
  end, {})
  register('UnprettyCsv', function()
    unpretty_csv()
  end, {})
  register('Nfc', nfc_transform, {})
  register('ProfileCursorMove', profile_cursor_move, {})
end

return M
