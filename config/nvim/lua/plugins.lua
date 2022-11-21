-- https://qiita.com/delphinus/items/8160d884d415d7425fcc
vim.cmd[[packadd packer.nvim]]

require'packer'.startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use 'mortepau/codicons.nvim'

  -- dap
  require('plugins/nvim-dap')

end)

vim.keymap.set('n', '<F4>', ':lua require"dapui".toggle()<CR>');
vim.keymap.set('n', '<F5>', ':lua require"dap".continue()<CR>');
vim.keymap.set('n', '<F9>', ':lua require"dap".toggle_breakpoint()<CR>');
vim.keymap.set('n', '<F10>', ':lua require"dap".step_over()<CR>');
vim.keymap.set('n', '<F11>', ':lua require"dap".step_into()<CR>');
vim.keymap.set('n', '<S-F11>', ':lua require"dap".step_out()<CR>');
