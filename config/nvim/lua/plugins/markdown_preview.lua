local M = {}

function M.setup()
  vim.g.mkdp_auto_close = 1
  vim.g.mkdp_refresh_slow = 1
  vim.g.mkdp_page_title = '「${name}」'
end

return M
