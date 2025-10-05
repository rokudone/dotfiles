local M = {}

function M.setup()
  local map = vim.keymap.set

  map('n', '<Leader>g', '[git]', { remap = true, silent = true })

  map('n', '[git]g', ':GFiles?<CR>', { silent = true, desc = 'Fugitive git files' })
  map('n', '[git]f', ':GFiles?<CR>', { silent = true, desc = 'Fugitive git files' })
  map('n', '[git]w', ':Git status<CR>', { silent = true, desc = 'Git status' })
  map('n', '[git]c', ':Git commit<CR>', { silent = true, desc = 'Git commit' })
  map('n', '[git]d', ':Gdiff<CR>', { silent = true, desc = 'Git diff' })
  map('n', '[git]b', ':Git blame<CR>', { silent = true, desc = 'Git blame' })
  map('n', '[git]B', ':GBrowse<CR>', { silent = true, desc = 'Open in browser' })
  map('v', '[git]B', ":'<,'>GBrowse<CR>", { silent = true, desc = 'Open selection in browser' })
end

return M
