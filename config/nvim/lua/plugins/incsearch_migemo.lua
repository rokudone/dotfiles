local M = {}

function M.setup()
  vim.keymap.set('n', 'g/', '<Plug>(incsearch-migemo-/)', { silent = true })
end

return M
