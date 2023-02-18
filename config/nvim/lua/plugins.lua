-- https://qiita.com/delphinus/items/8160d884d415d7425fcc
vim.cmd.packadd "packer.nvim"

require'packer'.startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use 'mortepau/codicons.nvim'

  use {
    "mfussenegger/nvim-dap",
    "rcarriga/nvim-dap-ui",
  }
  -- use {
    -- "williamboman/mason.nvim",
    -- "jayp0521/mason-nvim-dap.nvim",
  -- }
  -- use {
  --   "mxsdev/nvim-dap-vscode-js",
  --   requires = {"mfussenegger/nvim-dap"}
  -- }
  -- use {
  --   "microsoft/vscode-js-debug",
  --   opt = true,
  --   run = "npm install --legacy-peer-deps && npm run compile",
  -- }
  use {
    "suketa/nvim-dap-ruby",
    requires = {"mfussenegger/nvim-dap"}
  }
end)

-- dap
require('plugins/nvim-dap')

vim.keymap.set('n', '<F3>', ':lua dapui_reload()<CR>');
vim.keymap.set('n', '<F4>', ':lua require"dapui".toggle()<CR>');
vim.keymap.set('n', '<F5>', ':lua require"dap".continue()<CR>');
vim.keymap.set('n', '<F6>', ':lua require"dap".close()<CR>');
vim.keymap.set('n', '<F9>', ':lua require"dap".toggle_breakpoint()<CR>');
vim.keymap.set('n', '<F10>', ':lua require"dap".step_over()<CR>');
vim.keymap.set('n', '<F11>', ':lua require"dap".step_into()<CR>');
vim.keymap.set('n', '<S-F11>', ':lua require"dap".step_out()<CR>');
