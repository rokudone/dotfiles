local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup('CuculusJump', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'ruby',
    callback = function(args)
      vim.keymap.set('n', '%', function()
        vim.cmd('call cuculus#jump()')
      end, { buffer = args.buf, silent = true })
      vim.b[args.buf].did_ftplugin = 1
    end,
  })
end

return M
