local M = {}

local helpers = require('tests.helpers')
local assert_truthy = helpers.assert_truthy

function M.run()
  local captured_spec

  local original_lazy = package.loaded['lazy']
  local original_preload_lazy = package.preload['lazy']
  local original_core_plugins = package.loaded['core.plugins']

  local function cleanup()
    package.loaded['lazy'] = original_lazy
    package.preload['lazy'] = original_preload_lazy
    package.loaded['core.plugins'] = original_core_plugins
  end

  local ok, err = pcall(function()
    package.loaded['lazy'] = nil
    package.preload['lazy'] = function()
      return {
        setup = function(spec)
          captured_spec = spec
        end,
      }
    end

    package.loaded['core.plugins'] = nil
    local plugins = require('core.plugins')
    plugins.setup()

    local has_over = false
    if type(captured_spec) == 'table' then
      for _, plugin in ipairs(captured_spec) do
        local name = plugin
        if type(plugin) == 'table' then
          name = plugin[1]
        end
        if name == 'osyo-manga/vim-over' then
          has_over = true
          break
        end
      end
    end

    assert_truthy(
      not has_over,
      'vim-over プラグインは lazy.nvim のセットアップ対象から除外すること'
    )
  end)

  cleanup()
  assert_truthy(ok, err)
end

return M
