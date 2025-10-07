local M = {}

local helpers = require('tests.helpers')
local assert_eq = helpers.assert_eq
local assert_truthy = helpers.assert_truthy

function M.run()
  package.loaded['plugins.lsp'] = nil
  package.loaded['telescope.builtin'] = nil
  local opts_called
  package.preload['telescope.builtin'] = function()
    return {
      lsp_references = function(opts)
        opts_called = opts or {}
      end,
    }
  end
  local stored_map
  local original_keymap_set = vim.keymap.set
  vim.keymap.set = function(mode, lhs, rhs, opts)
    if mode == 'n' and lhs == 'gr' then
      stored_map = { rhs = rhs, opts = opts }
    end
  end

  local lsp = require('plugins.lsp')
  assert_truthy(type(lsp.on_attach) == 'function', 'on_attach 関数を公開していること')

  lsp.on_attach(nil, 0)

  assert_truthy(stored_map, 'gr のキーマップが登録されること')
  assert_truthy(type(stored_map.rhs) == 'function', 'gr のマッピングは関数であること')
  stored_map.rhs()
  assert_truthy(opts_called ~= nil, 'Telescope の lsp_references が呼ばれること')
  assert_eq(stored_map.opts.buffer, 0, 'バッファローカルマップであること')

  vim.keymap.set = original_keymap_set
  package.preload['telescope.builtin'] = nil
  package.loaded['telescope.builtin'] = nil
end

return M
