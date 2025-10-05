local M = {}

local helpers = require('tests.helpers')
local assert_eq = helpers.assert_eq
local assert_truthy = helpers.assert_truthy

local targets = {
  'NeoTreeGitModified',
  'NeoTreeGitAdded',
  'NeoTreeGitUntracked',
  'NeoTreeGitUnstaged',
  'NeoTreeGitStaged',
  'NeoTreeGitRenamed',
  'NeoTreeModified',
}

function M.run()
  local neo_tree = require('plugins.neo_tree')

  local original_get_hl = vim.api.nvim_get_hl
  local original_set_hl = vim.api.nvim_set_hl

  local requested = {}
  local applied = {}

  vim.api.nvim_get_hl = function(_, opts)
    requested[opts.name] = true
    return { fg = 0xABCDEF, bold = true }
  end

  vim.api.nvim_set_hl = function(_, name, value)
    applied[name] = value
  end

  neo_tree.apply_status_highlights()

  for _, name in ipairs(targets) do
    assert_truthy(requested[name], name .. ' ハイライトを参照していること')
    assert_truthy(applied[name], name .. ' ハイライトを上書きしていること')
    assert_eq(applied[name].fg, '#FF6666', '前景色を赤にする')
    assert_eq(applied[name].bg, 'NONE', '背景色を解除する')
    assert_eq(applied[name].ctermbg, 'NONE', 'cterm 背景を解除する')
    assert_truthy(applied[name].bold, '既存属性を維持する')
  end

  vim.api.nvim_get_hl = original_get_hl
  vim.api.nvim_set_hl = original_set_hl
end

return M
