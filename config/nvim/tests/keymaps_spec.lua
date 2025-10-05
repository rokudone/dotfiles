local M = {}

local helpers = require('tests.helpers')
local assert_eq = helpers.assert_eq
local assert_truthy = helpers.assert_truthy

local function find_map(mode, lhs)
  local alt = lhs:upper()
  for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
    if map.lhs == lhs or map.lhs == alt then
      return map
    end
  end
end

function M.run()
  local keymaps = require('core.keymaps')
  keymaps.setup()

  local mark_prefix = find_map('n', '[Mark]')
  assert_truthy(mark_prefix, '[Mark] mapping should exist')
  assert_truthy(mark_prefix.rhs == '<Nop>' or mark_prefix.rhs == '', '[Mark] should map to <Nop> or empty rhs')

  local mark_trigger = find_map('n', 'm')
  assert_truthy(mark_trigger, 'm remapping should exist')
  assert_eq(mark_trigger.rhs, '[Mark]', 'm should remap to [Mark]')

  local indent_up = find_map('n', '<C-k>')
  assert_truthy(indent_up and indent_up.callback, '<C-k> mapping should call Lua callback')

  local indent_down = find_map('n', '<C-j>')
  assert_truthy(indent_down and indent_down.callback, '<C-j> mapping should call Lua callback')

  local neo_tree_called = false
  local neo_tree_config
  local original_preload = package.preload['neo-tree']
  package.preload['neo-tree'] = function()
    return {
      setup = function(opts)
        neo_tree_called = true
        neo_tree_config = opts
      end,
    }
  end

  local neo_tree = require('plugins.neo_tree')
  neo_tree.setup()
  assert_truthy(neo_tree_called, 'neo-tree setup should be invoked')
  assert_truthy(neo_tree_config, 'neo-tree setup should receive configuration')

  local neo_tree_map = find_map('n', 'ge')
  assert_truthy(neo_tree_map and neo_tree_map.callback, 'ge mapping should invoke Neo-tree toggle')

  if original_preload then
    package.preload['neo-tree'] = original_preload
  else
    package.preload['neo-tree'] = nil
  end
end

return M
