local M = {}

function M.setup()
  vim.g.previm_disable_default_css = 1
  vim.g.previm_custom_css_path = vim.fn.expand('~/.config/nvim/templates/previm/github.css')
end

return M
