local M = {}

local helpers = require('tests.helpers')
local assert_truthy = helpers.assert_truthy
local assert_eq = helpers.assert_eq

local function load_lsp_module()
  package.loaded['plugins.lsp'] = nil
  package.preload['plugins.lsp'] = function()
    return dofile(vim.fn.stdpath('config') .. '/lua/plugins/lsp.lua')
  end
  return require('plugins.lsp')
end

function M.run()
  local lsp = load_lsp_module()

  local original_keymap_set = vim.keymap.set
  vim.diagnostic = vim.diagnostic or {}
  local original_open_float = vim.diagnostic.open_float

  local stored_map
  local float_called = 0

  vim.keymap.set = function(mode, lhs, rhs, opts)
    if mode == 'n' and lhs == 'gh' then
      stored_map = { rhs = rhs, opts = opts }
    end
  end

  vim.diagnostic.open_float = function(...)
    float_called = float_called + 1
    if original_open_float then
      return original_open_float(...)
    end
  end

  local target_bufnr = 0
  lsp.on_attach(nil, target_bufnr)

  assert_truthy(stored_map, 'gh のマッピングが登録されること')
  assert_truthy(type(stored_map.rhs) == 'function', 'gh のマッピングは関数であること')
  assert_eq(stored_map.opts.buffer, target_bufnr, 'gh のマッピングはバッファローカルであること')

  local ok, err = pcall(stored_map.rhs)
  assert_truthy(ok, err)
  assert_truthy(float_called > 0, '診断用フロートが開かれること')

  vim.keymap.set = original_keymap_set
  vim.diagnostic.open_float = original_open_float
  package.preload['plugins.lsp'] = nil
  package.loaded['plugins.lsp'] = nil
end

return M
