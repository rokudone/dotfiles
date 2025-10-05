local M = {}

function M.setup()
  vim.g.php_cs_fixer_rules = '@PSR12'
  vim.g.php_cs_fixer_cache = '.php_cs.cache'
  vim.g.php_cs_fixer_config_file = '.php_cs'
  vim.g.php_cs_fixer_php_path = 'php'
  vim.g.php_cs_fixer_enable_default_mapping = 0
  vim.g.php_cs_fixer_dry_run = 0
  vim.g.php_cs_fixer_verbose = 0
end

return M
