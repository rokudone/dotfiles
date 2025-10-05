local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup('QfReplaceMaps', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'qf',
    callback = function(args)
      vim.keymap.set('n', 'r', ':Qfreplace<CR>', { buffer = args.buf, silent = true })
    end,
  })
end

return M
