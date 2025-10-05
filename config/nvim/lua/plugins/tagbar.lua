local M = {}

local function set_highlights()
  local group = vim.api.nvim_create_augroup('TagbarHighlightLua', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = function()
      vim.cmd('hi link TagbarVisibilityPublic Type')
      vim.cmd('hi link TagbarVisibilityProtected String')
      vim.cmd('hi link TagbarVisibilityPrivate Todo')
      vim.cmd('hi TagbarHighlight term=underline cterm=underline gui=underline')
    end,
  })
end

function M.setup()
  vim.g.tagbar_show_linenumbers = 1
  vim.g.tagbar_iconchars = { '▸', '▾' }
  vim.g.tagbar_autofocus = 1
  vim.g.tagbar_sort = 0
  vim.g.tagbar_width = 60

  vim.g.tagbar_type_yaml = {
    ctagstype = 'yaml',
    kinds = {
      'a:anchors',
      's:section',
      'e:entry',
    },
    sro = '.',
    scope2kind = {
      section = 's',
      entry = 'e',
    },
    kind2scope = {
      s = 'section',
      e = 'entry',
    },
    sort = 0,
  }

  set_highlights()

  vim.keymap.set('n', '<Leader>O', '<cmd>TagbarToggle<CR>', { silent = true, desc = 'Toggle Tagbar' })
end

return M
