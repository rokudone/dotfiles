local M = {}

local function set_defaults()
  vim.g.EasyMotion_do_mapping = 0
  vim.g.EasyMotion_smartcase = 1
  vim.g.EasyMotion_use_migemo = 1
  vim.g.EasyMotion_startofline = 0
  vim.g.EasyMotion_use_upper = 1
  vim.g.EasyMotion_enter_jump_first = 1
  vim.g.EasyMotion_space_jump_first = 1
  vim.g.EasyMotion_do_shade = 0
  vim.g.EasyMotion_keys = 'AWEFJIOPTYUSDKLZXCVBNMGH;'
end

local function set_keymaps()
  local map = vim.keymap.set
  local opts = { silent = true, remap = true }

  map({ 'n', 'v', 'o' }, 'f', '<Plug>(easymotion-fl)', opts)
  map({ 'n', 'v', 'o' }, 'F', '<Plug>(easymotion-Fl)', opts)
  map({ 'n', 'v', 'o' }, 't', '<Plug>(easymotion-tl)', opts)
  map({ 'n', 'v', 'o' }, 'T', '<Plug>(easymotion-Tl)', opts)

  map('n', '<Leader>[', '<Plug>(easymotion-overwin-f2)', opts)
  map('v', '<Leader>[', '<Plug>(easymotion-bd-f2)', opts)

  map({ 'n', 'v', 'o' }, '<Leader>j', '<Plug>(easymotion-j)', opts)
  map({ 'n', 'v', 'o' }, '<Leader>k', '<Plug>(easymotion-k)', opts)
end

function M.setup()
  set_defaults()
  set_keymaps()
end

return M
