local M = {}

local helpers = require('tests.helpers')
local assert_eq = helpers.assert_eq
local assert_truthy = helpers.assert_truthy

local function with_stubbed_ayu(callback)
  local original_module = package.loaded.ayu
  local original_colors = package.loaded['ayu.colors']
  local setup_called = false

  local colors_stub = { bg = '#0F1419' }

  package.loaded.ayu = {
    setup = function(opts)
      setup_called = true
      callback.on_setup(opts)
    end,
  }
  package.loaded['ayu.colors'] = colors_stub

  local ok, err = pcall(callback.run)

  package.loaded.ayu = original_module
  if original_colors == nil then
    package.loaded['ayu.colors'] = nil
  else
    package.loaded['ayu.colors'] = original_colors
  end

  if not ok then
    error(err)
  end

  return setup_called
end

function M.run()
  local colors = require('plugins.ayu')

  local command_called
  local original_cmd = vim.cmd

  vim.cmd = function(cmd)
    command_called = cmd
  end

  local setup_called = with_stubbed_ayu({
    on_setup = function(opts)
      assert_eq(opts.mirage, false, 'mirage オプションは false のままにする')
      assert_eq(opts.overrides, nil, 'overrides は指定しない')
    end,
    run = function()
      colors.setup()
    end,
  })

  vim.cmd = original_cmd

  assert_truthy(setup_called, 'ayu.setup が呼び出されること')
  assert_eq(command_called, 'colorscheme ayu', 'colorscheme ayu を実行すること')
end

return M
