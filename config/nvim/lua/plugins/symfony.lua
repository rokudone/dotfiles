local M = {}

function M.setup()
  vim.g.symfony_app_console_caller = 'php'
  vim.g.symfony_app_console_path = 'bin/console'
  vim.g.symfony_enable_shell_mapping = 0
end

return M
