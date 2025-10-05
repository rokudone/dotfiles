local fn = vim.fn

local cwd = fn.getcwd()
local config_path = cwd .. '/config/nvim'

if not string.find(vim.o.runtimepath, config_path, 1, true) then
  vim.opt.runtimepath:append(config_path)
  vim.opt.runtimepath:append(config_path .. '/after')
end

package.path = table.concat({
  config_path .. '/?.lua',
  config_path .. '/?/init.lua',
  config_path .. '/lua/?.lua',
  config_path .. '/lua/?/init.lua',
  config_path .. '/tests/?.lua',
  package.path,
}, ';')

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
