local M = {}

function M.setup()
  vim.g.vim_markdown_folding_disabled = 1
  vim.g.vim_markdown_no_default_key_mappings = 1
  vim.g.vim_markdown_new_list_item_indent = 0
  vim.g.vim_markdown_conceal = 0

  local group = vim.api.nvim_create_augroup('MarkdownCustomMaps', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'markdown',
    callback = function(args)
      local opts = { buffer = args.buf, silent = true }
      vim.keymap.set('n', '+', function()
        vim.cmd('.HeaderIncrease')
      end, opts)
      vim.keymap.set('n', '-', function()
        vim.cmd('.HeaderDecrease')
      end, opts)
      vim.keymap.set('v', '+', ":'<,'>HeaderIncrease<CR>", opts)
      vim.keymap.set('v', '-', ":'<,'>HeaderDecrease<CR>", opts)

      vim.keymap.set('n', '<Leader>\\', function()
        local path = vim.fn.expand('%:p')
        if path ~= '' then
          vim.fn.jobstart({ 'open', path }, { detach = true })
        end
      end, opts)
    end,
  })
end

return M
