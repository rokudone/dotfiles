local specs = {
  'tests.options_spec',
  'tests.keymaps_spec',
  'tests.commands_spec',
  'tests.autocmds_spec',
  'tests.lsp_spec',
  'tests.lsp_references_spec',
  'tests.telescope_spec',
  'tests.neo_tree_status_highlight_spec',
  'tests.colors_spec',
}

local M = {}

function M.run()
  for _, name in ipairs(specs) do
    local mod = require(name)
    if type(mod.run) == 'function' then
      mod.run()
    end
  end
end

return M
