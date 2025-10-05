local M = {}

function M.setup()
  vim.g.asciidoctor_executable = 'asciidoctor'
  vim.g.asciidoctor_folding = 1
  vim.g.asciidoctor_fold_options = 1
  vim.g.asciidoctor_syntax_conceal = 1
  vim.g.asciidoctor_syntax_indented = 0
  vim.g.asciidoctor_fenced_languages = { 'python', 'c', 'javascript' }

  local group = vim.api.nvim_create_augroup('AsciidoctorMappings', { clear = true })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = group,
    pattern = { '*.adoc', '*.asciidoc' },
    callback = function(args)
      vim.keymap.set('n', '[Adoc]', ':AsciidoctorOpenPDF<CR>', { buffer = args.buf, silent = true })
    end,
  })
end

return M
