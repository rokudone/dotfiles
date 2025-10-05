local M = {}

function M.setup()
  vim.cmd('runtime macros/sandwich/keymap/surround.vim')

  vim.keymap.set('x', 'S', '<Nop>', { silent = true })
  vim.keymap.set('x', 's', '<Plug>(operator-sandwich-add)', { silent = true })

  if vim.fn.exists('g:sandwich#default_recipes') == 1 then
    local recipes = vim.fn.deepcopy(vim.g['sandwich#default_recipes'] or {})
    table.insert(recipes, { buns = { '<', '>' } })
    vim.g['sandwich#recipes'] = recipes
  end
end

return M
