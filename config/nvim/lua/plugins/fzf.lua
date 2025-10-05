local M = {}

local fn = vim.fn
local cmd = vim.api.nvim_create_user_command
local map = vim.keymap.set

local function systemlist(cmdline)
  local result = fn.systemlist(cmdline)
  if vim.v.shell_error ~= 0 or not result or #result == 0 then
    return nil
  end
  return result[1]
end

local function ensure_functions()
  vim.cmd([[silent! delfunction FzfBuildQuickfixList]])
  vim.cmd([[silent! delfunction FzfInsertEmoji]])
  vim.cmd([[silent! delfunction FzfEmoji]])
  vim.cmd([[silent! delfunction FzfGetJumplist]])
  vim.cmd([[silent! delfunction FzfGoToJump]])
  vim.cmd([[silent! delfunction FzfJump]])

  vim.cmd([[function! FzfBuildQuickfixList(lines) abort
    if len(a:lines) == 1
      execute 'edit ' . a:lines[0]
    elseif len(a:lines) > 1
      call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
      copen
    endif
  endfunction]])

  vim.cmd([[function! FzfInsertEmoji(line) abort
    let splitted = split(a:line)
    if empty(splitted)
      return
    endif
    if splitted[0] == '*'
      if len(splitted) > 1
        call FzfEmoji(splitted[1])
      endif
    else
      let pos = getpos('.')
      execute 'normal! i' . splitted[1]
      call setpos('.', pos)
    endif
  endfunction]])

  vim.cmd([[function! FzfEmoji(...) abort
    if a:0 >= 1
      let file = a:1
    else
      let file = '*'
    endif
    call fzf#run({
          \ 'source': 'cat ~/.config/nvim/cheatsheet/emoji/' . file,
          \ 'sink': function('FzfInsertEmoji'),
          \ 'down': '40%'
          \ })
  endfunction]])

  vim.cmd([[function! FzfGetJumplist() abort
    redir => cout
    silent jumps
    redir END
    return reverse(split(cout, "\n")[1:])
  endfunction]])

  vim.cmd([[function! FzfGoToJump(jump) abort
    let jumpnumber = split(a:jump, '\s\+')[0]
    execute 'normal ' . jumpnumber . "\<c-o>"
  endfunction]])

  vim.cmd([[function! FzfJump(...) abort
    call fzf#run({
          \ 'source': FzfGetJumplist(),
          \ 'sink': function('FzfGoToJump'),
          \ 'down': '40%'
          \ })
  endfunction]])
end

local function set_globals()
  local dotfiles_path = vim.g.dotfiles_path
  if not dotfiles_path or dotfiles_path == '' then
    local myvimrc = vim.env.MYVIMRC or fn.stdpath('config') .. '/init.lua'
    local config_dir = fn.fnamemodify(myvimrc, ':p:h')
    dotfiles_path = systemlist('cd ' .. fn.shellescape(config_dir) .. ' && git rev-parse --show-toplevel')
    if not dotfiles_path or dotfiles_path == '' then
      dotfiles_path = config_dir
    end
  end
  vim.g.dotfiles_path = dotfiles_path

  local claude_path = vim.g.claude_code_config_path or fn.expand('~/projects/claude-code-config')
  vim.g.claude_code_config_path = claude_path

  local memolist_path = vim.g.memolist_path or fn.expand('~/memo/Inbox')
  vim.g.memolist_path = memolist_path

  vim.g.fzf_action = {
    enter = fn['FzfBuildQuickfixList'],
    ['ctrl-m'] = 'open',
    ['ctrl-t'] = 'tab split',
    ['ctrl-s'] = 'split',
    ['ctrl-v'] = 'vsplit',
  }
  vim.g.fzf_buffers_jump = 1
  vim.g.fzf_tags_command = 'ctags --exclude=node_modules --exclude=vendor'
  vim.g.fzf_layout = { down = '70%' }
  vim.g.fzf_colors = {
    fg = { 'fg', 'Normal' },
    bg = { 'bg', 'Normal' },
    hl = { 'fg', 'Comment' },
    ['fg+'] = { 'fg', 'CursorLine', 'CursorColumn', 'Normal' },
    ['bg+'] = { 'bg', 'CursorLine', 'CursorColumn' },
    ['hl+'] = { 'fg', 'Statement' },
    info = { 'fg', 'PreProc' },
    border = { 'fg', 'Ignore' },
    prompt = { 'fg', 'Conditional' },
    pointer = { 'fg', 'Exception' },
    marker = { 'fg', 'Keyword' },
    spinner = { 'fg', 'Label' },
    header = { 'fg', 'Comment' },
  }
end

local function files_with_query(query)
  query = query or ''
  local spec = fn['fzf#wrap']({
    source = 'fd',
    options = { '--query', query },
  })
  fn['fzf#run'](spec)
end

local function claude_code_config(bang)
  local opts = fn['fzf#vim#with_preview']()
  local spec = fn['fzf#wrap']({
    source = 'cd ' .. vim.g.claude_code_config_path .. ' && git ls-files',
    dir = vim.g.claude_code_config_path,
    options = opts.options,
  }, bang)
  fn['fzf#run'](spec)
end

function M.setup()
  ensure_functions()
  set_globals()

  cmd('FilesWithQuery', function(opts)
    files_with_query(opts.args)
  end, { nargs = '?', complete = 'dir' })

  cmd('Dotfiles', function(opts)
    fn['fzf#vim#files'](vim.g.dotfiles_path, opts.bang and 1 or 0)
  end, { nargs = '?', complete = 'dir', bang = true })

  cmd('ClaudeCodeConfig', function(opts)
    claude_code_config(opts.bang and 1 or 0)
  end, { nargs = '?', complete = 'dir', bang = true })

  cmd('Emoji', function(opts)
    if opts.args ~= '' then
      fn['FzfEmoji'](opts.args)
    else
      fn['FzfEmoji']()
    end
  end, { nargs = '?' })

  cmd('Ag', function(opts)
    fn['fzf#vim#ag_raw'](opts.args, opts.bang and 1 or 0)
  end, { nargs = '+', bang = true, complete = 'dir' })

  cmd('MemoListFzf', function(opts)
    fn['fzf#vim#files'](vim.g.memolist_path, opts.bang and 1 or 0)
  end, { nargs = '*', bang = true, complete = 'dir' })

  cmd('MemoGrepFzf', function(opts)
    local query_part = ''
    if opts.args ~= '' then
      query_part = ' ' .. opts.args
    end
    local command = string.format(
      'rg --column --line-number --no-heading --color=always --smart-case -M0 -sortr path%s %s',
      query_part,
      vim.g.memolist_path
    )
    fn['fzf#vim#grep'](command, 1,
      opts.bang and fn['fzf#vim#with_preview']('up:60%')
      or fn['fzf#vim#with_preview']('right:50%:hidden'),
      opts.bang and 1 or 0)
  end, { nargs = '*', bang = true, complete = 'dir' })

  cmd('Rg', function(opts)
    local query_part = ''
    if opts.args ~= '' then
      query_part = ' ' .. opts.args
    end
    local command = string.format(
      'rg --column --line-number --no-heading --color=always --smart-case -M0%s',
      query_part
    )
    fn['fzf#vim#grep'](command, 1,
      opts.bang and fn['fzf#vim#with_preview']('up:60%')
      or fn['fzf#vim#with_preview']('right:50%:hidden'),
      opts.bang and 1 or 0)
  end, { nargs = '*', bang = true, complete = 'dir' })

  cmd('Jump', function()
    fn['FzfJump']()
  end, {})

  map('n', '<C-p>', '<cmd>Files<CR>', { silent = true, desc = 'FZF files' })
  map('n', '<Leader>f', function()
    files_with_query(fn.expand('%:t:r'))
  end, { silent = true, desc = 'FZF files with current filename' })
  map('n', '<Leader>F', function()
    files_with_query(fn.expand('<cword>'))
  end, { silent = true, desc = 'FZF files with word' })
  map('n', '<Leader>ee', '<cmd>Dotfiles<CR>', { silent = true, desc = 'FZF dotfiles' })
  map('n', '<Leader>ec', '<cmd>ClaudeCodeConfig<CR>', { silent = true, desc = 'FZF Claude config' })
  map('n', '<Leader>b', '<cmd>Buffers<CR>', { silent = true, desc = 'FZF buffers' })
  map('n', '<Leader>m', '<cmd>Marks<CR>', { silent = true, desc = 'FZF marks' })
  map('n', '<Leader>a', function()
    vim.api.nvim_feedkeys(':Rg ', 'n', false)
  end, { silent = true, desc = 'FZF ripgrep prompt' })
  map('n', '<Leader>A', function()
    local word = fn.expand('<cword>')
    vim.api.nvim_feedkeys(':Rg ' .. word .. ' ', 'n', false)
  end, { silent = true, desc = 'FZF ripgrep word' })
  map('n', '<Leader>/', '<cmd>BLines<CR>', { silent = true, desc = 'FZF buffer lines' })
  map('n', '<Leader>?', '<cmd>Lines<CR>', { silent = true, desc = 'FZF all lines' })
  map('n', '<Leader>h', '<cmd>History<CR>', { silent = true, desc = 'FZF history' })
  map('n', '<Leader>H', '<cmd>Helptags<CR>', { silent = true, desc = 'FZF helptags' })
  map('n', '<Leader>J', '<cmd>Jump<CR>', { silent = true, desc = 'FZF jumplist' })
end

return M
