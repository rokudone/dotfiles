local M = {}

local helpers = require('tests.helpers')
local assert_eq = helpers.assert_eq
local assert_truthy = helpers.assert_truthy

local function assert_command_exists(name)
  local commands = vim.api.nvim_get_commands({ builtin = false })
  assert_truthy(commands[name], string.format('command %s must exist', name))
end

function M.run()
  local commands = require('core.commands')
  commands.setup()

  for _, name in ipairs({
    'Reload',
    'Code',
    'SyntaxInfo',
    'SyntaxInfoAll',
    'PWD',
    'CD',
    'Num',
    'Nonum',
    'Jq',
    'ClearRegs',
    'PrettyCsv',
    'UnprettyCsv',
    'Nfc',
    'ProfileCursorMove',
  }) do
    assert_command_exists(name)
  end

  vim.o.number = true
  vim.cmd('Nonum')
  assert_eq(vim.o.number, false, 'Nonum should disable line numbers')
  vim.cmd('Num')
  assert_eq(vim.o.number, true, 'Num should enable line numbers')

  vim.fn.setreg('a', 'hello')
  vim.fn.setreg('/', 'pattern')
  vim.cmd('ClearRegs')
  assert_eq(vim.fn.getreg('a'), '', 'ClearRegs should empty register a')
  assert_eq(vim.fn.getreg('/'), '', 'ClearRegs should empty search register')

  local tmpdir = vim.fn.tempname()
  vim.fn.mkdir(tmpdir)
  local original_cwd = vim.fn.getcwd()
  vim.cmd('silent! CD ' .. vim.fn.fnameescape(tmpdir))
  local resolved = vim.loop.fs_realpath(vim.fn.getcwd())
  local expected = vim.loop.fs_realpath(tmpdir)
  assert_eq(resolved, expected, 'CD should change current directory')
  vim.fn.chdir(original_cwd)
  vim.fn.delete(tmpdir, 'rf')
end

return M
