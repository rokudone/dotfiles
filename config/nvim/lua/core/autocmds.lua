local M = {}

local api = vim.api
local fn = vim.fn

local function notify_error(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = 'core.autocmds' })
end

local function dirname(path)
  return fn.fnamemodify(path, ':p:h')
end

function M.ensure_parent_dir(opts)
  local file = opts.file or ''
  if file == '' then
    return
  end

  local dir = dirname(file)
  if dir == '' or fn.isdirectory(dir) == 1 then
    return
  end

  local ok, err = pcall(fn.mkdir, dir, 'p')
  if not ok then
    notify_error(string.format('Failed to create directory %s: %s', dir, err))
  end
end

local function read_first_line(bufnr, file)
  if bufnr and bufnr ~= 0 and api.nvim_buf_is_valid(bufnr) then
    local line = api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
    if line then
      return line
    end
  end

  if file and file ~= '' then
    local ok, lines = pcall(fn.readfile, file, '', 1)
    if ok then
      return lines[1]
    end
  end
end

local function ensure_executable_permission(file)
  if fn.executable('chmod') == 0 then
    notify_error('chmod not available to set executable bit')
    return
  end

  fn.system({ 'chmod', '+x', file })
  if vim.v.shell_error ~= 0 then
    notify_error(string.format('chmod +x failed for %s', file))
  end
end

function M.ensure_executable(opts)
  local file = opts.file or ''
  if file == '' or fn.filereadable(file) == 0 then
    return
  end

  local first_line = read_first_line(opts.buf, file)
  if not first_line or not first_line:match('^#!') then
    return
  end

  local perm = fn.getfperm(file)
  if perm:sub(3, 3) == 'x' then
    return
  end

  ensure_executable_permission(file)
end

local function find_window_for_buffer(bufnr)
  for _, win in ipairs(api.nvim_list_wins()) do
    if api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
end

function M.restore_last_position(opts)
  local bufnr = opts.buf or api.nvim_get_current_buf()
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end

  local mark = api.nvim_buf_get_mark(bufnr, '"')
  local line = mark[1]
  if line <= 0 or line > api.nvim_buf_line_count(bufnr) then
    return
  end

  local win = api.nvim_get_current_win()
  if api.nvim_win_get_buf(win) ~= bufnr then
    win = find_window_for_buffer(bufnr) or win
  end

  pcall(api.nvim_win_set_cursor, win, { line, mark[2] })
end

local function startinsert_terminal(opts)
  local bufnr = opts.buf or 0
  if bufnr ~= 0 and not api.nvim_buf_is_valid(bufnr) then
    return
  end

  local target_buf = bufnr ~= 0 and bufnr or api.nvim_get_current_buf()
  if api.nvim_get_option_value('buftype', { buf = target_buf }) == 'terminal' then
    vim.schedule(function()
      if vim.fn.has('nvim') == 1 then
        vim.cmd('startinsert')
      else
        vim.cmd('normal i')
      end
    end)
  end
end

local function detect_macos_background()
  if fn.has('macunix') == 0 then
    return
  end
  local ok, output = pcall(fn.system, 'defaults read -g AppleInterfaceStyle 2>/dev/null')
  if ok and type(output) == 'string' and output:match('Dark') then
    vim.opt.background = 'dark'
  else
    vim.opt.background = 'light'
  end
end

local function apply_highlight_preferences()
  local set_hl = vim.api.nvim_set_hl

  set_hl(0, 'Normal', { bg = 'NONE', ctermbg = 'NONE' })
  set_hl(0, 'Visual', { bg = '#3A3208' })

  local function make_transparent(group)
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok and type(hl) == 'table' then
      hl.bg = 'NONE'
      hl.ctermbg = 'NONE'
      set_hl(0, group, hl)
    else
      set_hl(0, group, { bg = 'NONE', ctermbg = 'NONE' })
    end
  end

  make_transparent('Comment')
  make_transparent('@comment')
  make_transparent('@comment.documentation')
  make_transparent('FzfLuaDirPart')

  set_hl(0, 'GitSignsAdd', { fg = '#4CAF50', bg = 'NONE' })
  set_hl(0, 'GitSignsChange', { fg = '#42A5F5', bg = 'NONE' })
  set_hl(0, 'GitSignsDelete', { fg = '#EF5350', bg = 'NONE' })
  set_hl(0, 'GitSignsStagedAdd', { fg = '#EFD75A', bg = 'NONE' })
  set_hl(0, 'GitSignsStagedChange', { fg = '#E7C64C', bg = 'NONE' })
  set_hl(0, 'GitSignsStagedDelete', { fg = '#E7C64C', bg = 'NONE' })
end

function M.setup()
  detect_macos_background()
  apply_highlight_preferences()

  local auto_mkdir = api.nvim_create_augroup('CoreAutoMkdir', { clear = true })
  api.nvim_create_autocmd('BufWritePre', {
    group = auto_mkdir,
    callback = function(opts)
      M.ensure_parent_dir(opts)
    end,
  })

  local shebang_exec = api.nvim_create_augroup('CoreShebangExec', { clear = true })
  api.nvim_create_autocmd('BufWritePost', {
    group = shebang_exec,
    callback = function(opts)
      M.ensure_executable(opts)
    end,
  })

  local restore_cursor = api.nvim_create_augroup('CoreRestoreCursor', { clear = true })
  api.nvim_create_autocmd('BufReadPost', {
    group = restore_cursor,
    callback = function(opts)
      M.restore_last_position(opts)
    end,
  })

  local terminal = api.nvim_create_augroup('CoreTerminal', { clear = true })
  api.nvim_create_autocmd('WinEnter', {
    group = terminal,
    callback = startinsert_terminal,
  })

  local large_file = api.nvim_create_augroup('CoreLargeFile', { clear = true })
  api.nvim_create_autocmd('BufEnter', {
    group = large_file,
    callback = function()
      if fn.line('$') > 10000 then
        vim.cmd('syntax clear')
      end
    end,
  })

  local search_highlight = api.nvim_create_augroup('CoreSearchHighlight', { clear = true })
  api.nvim_create_autocmd('CmdlineEnter', {
    group = search_highlight,
    pattern = { '/', '?' },
    callback = function()
      vim.opt.hlsearch = true
    end,
  })

  if fn.has('persistent_undo') == 1 then
    local persistent = api.nvim_create_augroup('CorePersistentUndo', { clear = true })
    api.nvim_create_autocmd('BufReadPre', {
      group = persistent,
      pattern = { '~/*' },
      callback = function(opts)
        vim.bo[opts.buf].undofile = true
      end,
    })
  end

  local checktime = api.nvim_create_augroup('CoreChecktime', { clear = true })
  api.nvim_create_autocmd('WinEnter', {
    group = checktime,
    callback = function()
      vim.cmd('checktime')
    end,
  })

  local lumen = api.nvim_create_augroup('CoreLumenReload', { clear = true })
  api.nvim_create_autocmd('User', {
    group = lumen,
    pattern = { 'LumenLight', 'LumenDark' },
    callback = function()
      local config_path = fn.stdpath('config') .. '/init.lua'
      vim.cmd('source ' .. fn.fnameescape(config_path))
    end,
  })

  local open_folds = api.nvim_create_augroup('CoreOpenFolds', { clear = true })
  api.nvim_create_autocmd('BufWinEnter', {
    group = open_folds,
    callback = function()
      vim.opt_local.foldlevel = 99
    end,
  })

  local colorscheme = api.nvim_create_augroup('CoreColorScheme', { clear = true })
  api.nvim_create_autocmd('ColorScheme', {
    group = colorscheme,
    callback = function()
      vim.schedule(apply_highlight_preferences)
    end,
  })

end

return M
