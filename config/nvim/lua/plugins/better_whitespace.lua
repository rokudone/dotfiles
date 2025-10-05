local M = {}

local function apply_colors()
  if vim.o.background == 'dark' then
    vim.g.better_whitespace_ctermcolor = '14'
    vim.g.better_whitespace_guicolor = '#3a453e'
  else
    vim.g.better_whitespace_ctermcolor = '4'
    vim.g.better_whitespace_guicolor = '#ABB0B6'
  end
end

function M.setup()
  vim.g.better_whitespace_enabled = 1
  vim.g.better_whitespace_filetypes_blacklist = {
    'diff', 'gitcommit', 'qf', 'help', 'dein', 'denite', 'vaffle', 'defx',
  }

  apply_colors()

  local group = vim.api.nvim_create_augroup('BetterWhitespaceLua', { clear = true })
  vim.api.nvim_create_autocmd({ 'OptionSet', 'ColorScheme' }, {
    group = group,
    pattern = '*',
    callback = apply_colors,
  })
end

return M
