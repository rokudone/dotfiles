-- https://qiita.com/delphinus/items/8160d884d415d7425fcc
vim.cmd.packadd "packer.nvim"

require'packer'.startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- use 'hrsh7th/nvim-cmp'
  -- use 'mortepau/codicons.nvim'

  use {
    "mfussenegger/nvim-dap",
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
  }
  -- use {
    -- "williamboman/mason.nvim",
    -- "jayp0521/mason-nvim-dap.nvim",
  -- }
  use {
    "mxsdev/nvim-dap-vscode-js",
    requires = {"mfussenegger/nvim-dap"}
  }
  use {
    "microsoft/vscode-js-debug",
    opt = true,
    run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && npm run compile",
    requires = {"mxsdev/nvim-dap-vscode-js"},
  }
  use {
    "suketa/nvim-dap-ruby",
    requires = {"mfussenegger/nvim-dap"}
  }

  use {
    "nvim-treesitter/nvim-treesitter",
    run = function()
        local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
        ts_update()
    end,
  }

  use {
    "RRethy/nvim-treesitter-endwise",
    requires = {"nvim-treesitter"}
  }

  -- use { 'codota/tabnine-nvim', run = "./dl_binaries.sh" }

  -- use { 'codota/tabnine-nvim', run = "pwsh.exe -file .\\dl_binaries.ps1" }
  use {
    "coder/claudecode.nvim",
    requires = { "folke/snacks.nvim" },
    config = function()
      require("claudecode").setup({
        terminal = {
          provider = "native",  -- snacksの代わりにnativeを使用
        }
      })
      
      -- キーマッピングの設定
      vim.keymap.set("n", "<leader>c", "", { desc = "AI/Claude Code" })
      vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
      vim.keymap.set("n", "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
      vim.keymap.set("n", "<leader>cr", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
      vim.keymap.set("n", "<leader>cC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
      vim.keymap.set("n", "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer" })
      vim.keymap.set("v", "<leader>cs", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
      
      -- ファイルツリー用の設定
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "NvimTree", "neo-tree", "oil" },
        callback = function()
          vim.keymap.set("n", "<leader>cs", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = true, desc = "Add file" })
        end,
      })
      
      -- Diff管理
      vim.keymap.set("n", "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
      vim.keymap.set("n", "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })
    end,
  }
end)

-- tabnine
-- require('tabnine').setup({
--   disable_auto_comment=false,
--   accept_keymap="<C-F>",
--   dismiss_keymap = "<C-]>",
--   debounce_ms = 800,
--   suggestion_color = {gui = "#808080", cterm = 244},
--   exclude_filetypes = {"TelescopePrompt"},
--   log_file_path = nil, -- absolute path to Tabnine log file
-- })

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

-- treesitter
require('plugins/treesitter')
