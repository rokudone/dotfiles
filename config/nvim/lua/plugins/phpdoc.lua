local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup('PhpDocMappings', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'php',
    callback = function(args)
      vim.keymap.set('n', '<Leader>P', function()
        vim.cmd('call PhpDocSingle()')
      end, { buffer = args.buf, silent = true })
      vim.keymap.set('v', '<Leader>P', "<cmd>call PhpDocRange()<CR>", { buffer = args.buf, silent = true })
    end,
  })
end

return M
