local M = {}

local helpers = require('tests.helpers')
local assert_eq = helpers.assert_eq
local assert_truthy = helpers.assert_truthy

local function get_autocmd_count(opts)
  return #vim.api.nvim_get_autocmds(opts)
end

local function make_tempfile(lines, mode)
  local tmp = vim.fn.tempname()
  vim.fn.writefile(lines, tmp)
  if mode then
    vim.loop.fs_chmod(tmp, mode)
  end
  return tmp
end

local function cleanup(path)
  if vim.fn.isdirectory(path) == 1 then
    vim.fn.delete(path, 'rf')
  else
    vim.fn.delete(path)
  end
end

function M.run()
  local autocmds = require('core.autocmds')
  autocmds.setup()
  require('core.keymaps').setup()

  assert_eq(type(autocmds.ensure_parent_dir), 'function', 'ensure_parent_dir should be exposed')
  assert_eq(type(autocmds.ensure_executable), 'function', 'ensure_executable should be exposed')
  assert_eq(type(autocmds.restore_last_position), 'function', 'restore_last_position should be exposed')

  assert_truthy(get_autocmd_count({ event = 'BufWritePre', group = 'CoreAutoMkdir' }) > 0, 'AutoMkdir autocmd must exist')
  assert_truthy(get_autocmd_count({ event = 'BufWritePost', group = 'CoreShebangExec' }) > 0, 'Shebang execute autocmd must exist')
  assert_truthy(get_autocmd_count({ event = 'BufReadPost', group = 'CoreRestoreCursor' }) > 0, 'Restore cursor autocmd must exist')
  assert_truthy(get_autocmd_count({ event = 'WinEnter', group = 'CoreTerminal' }) > 0, 'Terminal autocmd must exist')

  local tmpdir = vim.fn.tempname()
  local target_dir = tmpdir .. '/nested/path'
  vim.fn.delete(tmpdir, 'rf')

  autocmds.ensure_parent_dir({ file = target_dir .. '/file.txt', bang = false })
  assert_eq(vim.fn.isdirectory(target_dir), 1, 'ensure_parent_dir should create directories')

  local shebang_file = make_tempfile({ '#!/bin/sh', 'echo hello' }, tonumber('644', 8))
  vim.fn.setfperm(shebang_file, 'rw-r--r--')
  autocmds.ensure_executable({ file = shebang_file, buf = 0 })
  assert_eq(vim.fn.getfperm(shebang_file):sub(3, 3), 'x', 'ensure_executable should add execute bit')
  cleanup(shebang_file)

  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { 'line1', 'line2', 'line3', 'line4' })
  vim.api.nvim_buf_set_mark(buf, '"', 3, 0, {})
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  autocmds.restore_last_position({ buf = buf })
  local cursor = vim.api.nvim_win_get_cursor(0)
  assert_eq(cursor[1], 3, 'restore_last_position should jump to stored mark')

  local function has_terminal_mapping(lhs, rhs)
    for _, map in ipairs(vim.api.nvim_get_keymap('t')) do
      if map.lhs == lhs and map.rhs == rhs then
        return true
      end
    end
    return false
  end

  assert_truthy(has_terminal_mapping('<Esc>', '<C-\\><C-N>'), 'terminal <Esc> mapping should exist')
  assert_truthy(has_terminal_mapping('<C-[>', '<C-\\><C-N>'), 'terminal <C-[> mapping should exist')

  assert_truthy(get_autocmd_count({ event = 'BufEnter', group = 'CoreLargeFile' }) > 0, 'Large file autocmd must exist')
  assert_truthy(get_autocmd_count({ event = 'CmdlineEnter', group = 'CoreSearchHighlight' }) > 0, 'Search highlight autocmd must exist')
  assert_truthy(get_autocmd_count({ event = 'BufReadPre', group = 'CorePersistentUndo' }) > 0, 'Persistent undo autocmd must exist')
  assert_truthy(get_autocmd_count({ event = 'WinEnter', group = 'CoreChecktime' }) > 0, 'Checktime autocmd must exist')
  assert_truthy(get_autocmd_count({ event = 'User', group = 'CoreLumenReload', pattern = 'LumenLight' }) > 0, 'LumenLight autocmd must exist')
  assert_truthy(get_autocmd_count({ event = 'User', group = 'CoreLumenReload', pattern = 'LumenDark' }) > 0, 'LumenDark autocmd must exist')

  cleanup(tmpdir)
  vim.api.nvim_buf_delete(buf, { force = true })
end

return M
