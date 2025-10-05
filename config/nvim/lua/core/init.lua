local M = {}

local modules = {
  'core.bootstrap',
  'core.options',
  'core.keymaps',
  'core.commands',
  'core.autocmds',
  'core.plugins',
}

function M.setup()
  for _, mod in ipairs(modules) do
    local ok, value = pcall(require, mod)
    if not ok then
      vim.notify(string.format('Failed to load %s: %s', mod, value), vim.log.levels.ERROR)
    elseif type(value) == 'table' and value.setup then
      value.setup()
    end
  end
end

return M
