local M = {}

function M.setup()
  local map = vim.keymap.set
  local opts = { silent = true }

  map('n', '<Leader>r', '[rails]', { remap = true, silent = true })

  local mappings = {
    { 'n', '[rails]r', ':A<CR>', 'Rails alternate file' },
    { 'n', '[rails]R', ':R<CR>', 'Rails related file' },
    { 'n', '[rails]c', ':Econtroller<CR>', 'Edit controller' },
    { 'n', '[rails]e', ':Eenvironment<CR>', 'Edit environment' },
    { 'n', '[rails]F', ':Efixture<CR>', 'Edit fixture' },
    { 'n', '[rails]h', ':Ehelper<CR>', 'Edit helper' },
    { 'n', '[rails]i', ':Einitializer<CR>', 'Edit initializer' },
    { 'n', '[rails]j', ':Ejavascript<CR>', 'Edit javascript' },
    { 'n', '[rails]l', ':Elayout<CR>', 'Edit layout' },
    { 'n', '[rails]L', ':Elib<CR>', 'Edit lib' },
    { 'n', '[rails]o', ':Elocale<CR>', 'Edit locale' },
    { 'n', '[rails]m', ':Emigration<CR>', 'Edit migration' },
    { 'n', '[rails]M', ':Emailer<CR>', 'Edit mailer' },
    { 'n', '[rails]s', ':Eschema<CR>', 'Edit schema' },
    { 'n', '[rails]S', ':Estylesheet<CR>', 'Edit stylesheet' },
    { 'n', '[rails]t', ':Efunctionaltest<CR>', 'Edit functional test' },
    { 'n', '[rails]T', ':Etask<CR>', 'Edit task' },
    { 'n', '[rails]u', ':Eunittest<CR>', 'Edit unit test' },
    { 'n', '[rails]v', ':Eview<CR>', 'Edit view' },
  }

  for _, m in ipairs(mappings) do
    map(m[1], m[2], m[3], vim.tbl_extend('keep', { desc = m[4] }, opts))
  end
end

return M
