local M = {}

local api = vim.api
local fn = vim.fn
local log = vim.log
local path_sep = package.config:sub(1, 1)
local live_state = {}

local function notify(msg, level)
  vim.notify(msg, level or log.levels.INFO, { title = 'GitTools' })
end

local function normalize_path(path)
  if not path or path == '' then
    return nil
  end
  return fn.fnamemodify(path, ':p')
end

local function strip_trailing_sep(path)
  if not path then
    return nil
  end
  if path_sep == '\\' then
    return path:gsub('\\+$', '')
  end
  return path:gsub('/+$', '')
end

local function buffer_file_path()
  local path = api.nvim_buf_get_name(0)
  if path == '' then
    notify('ファイルに保存されていないバッファですわ', log.levels.WARN)
    return nil
  end
  return normalize_path(path)
end

local function git_root(dir, opts)
  local output = fn.systemlist({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' })
  if vim.v.shell_error ~= 0 or not output[1] or output[1] == '' then
    if not (opts and opts.silent) then
      notify('Git 管理下のファイルではありませんわ', log.levels.WARN)
    end
    return nil
  end
  return strip_trailing_sep(output[1])
end

local function to_relative(path, root)
  if not path or not root then
    return nil
  end
  if path:sub(1, #root) == root then
    local idx = #root + 1
    if path:sub(idx, idx) == path_sep then
      idx = idx + 1
    end
    return path:sub(idx)
  end
  return path
end

local function run_git(root, args)
  if not root then
    return nil
  end
  local cmd = { 'git', '-C', root }
  vim.list_extend(cmd, args)
  local output = fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    local message = #output > 0 and table.concat(output, '\n') or 'git コマンドが失敗しましたわ'
    notify(message, log.levels.ERROR)
    return nil
  end
  return output
end

local function create_scratch_window(split_cmd, name)
  split_cmd = split_cmd or 'botright vsplit'
  vim.cmd(split_cmd)
  local win = api.nvim_get_current_win()
  local buf = api.nvim_create_buf(false, true)
  api.nvim_win_set_buf(win, buf)

  local bo = vim.bo[buf]
  bo.buftype = 'nofile'
  bo.bufhidden = 'wipe'
  bo.swapfile = false
  bo.filetype = 'git'
  bo.modifiable = true
  if name then
    api.nvim_buf_set_name(buf, name)
  end
  return win, buf
end

local function write_lines(buf, lines)
  if not lines or vim.tbl_isempty(lines) then
    lines = { '出力がありませんでしたわ' }
  end
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function git_context()
  local file = buffer_file_path()
  if not file then
    return nil
  end
  local dir = fn.fnamemodify(file, ':p:h')
  local root = git_root(dir)
  if not root then
    return nil
  end
  local relative = to_relative(file, root)
  return {
    file = file,
    root = root,
    relative = relative,
  }
end

local function restore_source_window()
  local state = live_state
  if not state.source_win or not api.nvim_win_is_valid(state.source_win) then
    live_state = {}
    return
  end
  if state.source_opts then
    for option, value in pairs(state.source_opts) do
      pcall(api.nvim_win_set_option, state.source_win, option, value)
    end
  end
  live_state = {}
end

local function attach_live_cleanup(buf)
  api.nvim_buf_attach(buf, false, {
    on_detach = function()
      restore_source_window()
    end,
  })
end

local function close_live_blame()
  if live_state.win and api.nvim_win_is_valid(live_state.win) then
    api.nvim_win_close(live_state.win, true)
    return
  end
  if live_state.buf and api.nvim_buf_is_valid(live_state.buf) then
    api.nvim_buf_delete(live_state.buf, { force = true })
  else
    restore_source_window()
  end
end

function M.open_file_blame()
  local ctx = git_context()
  if not ctx then
    return
  end
  local target = ctx.relative or ctx.file
  local lines = run_git(ctx.root, { '-c', 'color.blame=false', 'blame', '--date=short', '--', target })
  if not lines then
    return
  end
  local name = string.format('[blame] %s', target)
  local win, buf = create_scratch_window('botright vsplit', name)
  write_lines(buf, lines)
  api.nvim_win_set_option(win, 'wrap', false)
  api.nvim_win_set_option(win, 'signcolumn', 'no')
end

function M.toggle_live_blame()
  if live_state.win and api.nvim_win_is_valid(live_state.win) then
    close_live_blame()
    return
  end

  local ctx = git_context()
  if not ctx then
    return
  end
  local target = ctx.relative or ctx.file
  local lines = run_git(ctx.root, { '-c', 'color.blame=false', 'blame', '--date=short', '--', target })
  if not lines then
    return
  end

  local source_win = api.nvim_get_current_win()
  local win, buf = create_scratch_window('botright vsplit', '[live blame]')
  write_lines(buf, lines)

  local prev_opts = {
    scrollbind = api.nvim_win_get_option(source_win, 'scrollbind'),
    cursorbind = api.nvim_win_get_option(source_win, 'cursorbind'),
  }

  api.nvim_win_set_option(win, 'wrap', false)
  api.nvim_win_set_option(win, 'number', false)
  api.nvim_win_set_option(win, 'relativenumber', false)
  api.nvim_win_set_option(win, 'signcolumn', 'no')
  api.nvim_win_set_option(win, 'scrollbind', true)
  api.nvim_win_set_option(win, 'cursorbind', true)
  api.nvim_win_set_option(source_win, 'scrollbind', true)
  api.nvim_win_set_option(source_win, 'cursorbind', true)
  api.nvim_set_current_win(source_win)

  live_state = {
    win = win,
    buf = buf,
    source_win = source_win,
    source_opts = prev_opts,
  }
  attach_live_cleanup(buf)
end

function M.show_line_history()
  local ctx = git_context()
  if not ctx then
    return
  end
  local relative = ctx.relative
  if not relative or relative == '' then
    notify('ファイルの相対パスを特定できませんでしたわ', log.levels.ERROR)
    return
  end
  local line = api.nvim_win_get_cursor(0)[1]
  local range = string.format('%d,%d:%s', line, line, relative)
  local lines = run_git(ctx.root, {
    'log',
    '-L',
    range,
    '--decorate',
    '--date=short',
    '--no-color',
  })
  if not lines then
    return
  end
  local name = string.format('[history:%d] %s', line, relative)
  local win, buf = create_scratch_window('botright new', name)
  write_lines(buf, lines)
  api.nvim_win_set_option(win, 'wrap', false)
end

return M
