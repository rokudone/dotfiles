--aaa require("mason").setup()
-- require("mason-nvim-dap").setup({
--   ensure_installed = {"chrome", "node2", "php"},
--   automatic_installation = true,
--   automatic_setup = true,
-- })

local dap = require('dap')
dap.adapters.node2 = {
  type = 'executable',
  command = 'node',
  args = {os.getenv('HOME') .. '/dev/microsoft/vscode-node-debug2/out/src/nodeDebug.js'},
}

-- dap.adapters.chrome = {
--   type = "executable",
--   command = "node",
--   args = {os.getenv("HOME") .. "/dev/microsoft/vscode-chrome-debug/out/src/chromeDebug.js"}
-- }

local dap = require("dap")

require('dap').set_log_level('DEBUG')

require("dap-vscode-js").setup({
  debugger_path = vim.fn.stdpath("data") .. "/site/pack/packer/opt/vscode-js-debug",
  debugger_cmd = { "node", vim.fn.stdpath("data") .. "/site/pack/packer/opt/vscode-js-debug/dist/src/vsDebugServer.js" },
  adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }
})

for _, language in ipairs({ "typescript", "javascript", "typescriptreact" }) do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file (TypeScript)",
      program = "${file}",
      cwd = "${workspaceFolder}",
      sourceMaps = true,  -- これを追加
      protocol = "inspector",  -- これを追加
      runtimeExecutable = "node",  -- これを追加
      runtimeArgs = {  -- これを追加
        "--nolazy",  -- これを追加
        "-r", "ts-node/register"  -- これを追加
      },
      outFiles = { "${workspaceFolder}/dist/**/*.js" },  -- これを追加
      console = "integratedTerminal",
      internalConsoleOptions = "openOnSessionStart",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach to Process (TypeScript)",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
      sourceMaps = true,  -- これを追加
      protocol = "inspector",  -- これを追加
      runtimeExecutable = "node",  -- これを追加
      runtimeArgs = {  -- これを追加
        "--nolazy",  -- これを追加
        "-r", "ts-node/register"  -- これを追加
      },
      console = "integratedTerminal",
      internalConsoleOptions = "openOnSessionStart",
    },
  }
end

require('dap-ruby').setup();

local function dapui_setup()
  require("dapui").setup({
  icons = { expanded = "", collapsed = "", current_frame = "" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- Use this to override mappings for specific elements
  element_mappings = {
    -- Example:
    -- stacks = {
    --   open = "<CR>",
    --   expand = "o",
    -- }
  },
  -- Expand lines larger than the window
  -- Requires >= 0.7
  expand_lines = vim.fn.has("nvim-0.7") == 1,
  -- Layouts define sections of the screen to place windows.
  -- The position can be "left", "right", "top" or "bottom".
  -- The size specifies the height/width depending on position. It can be an Int
  -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
  -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
  -- Elements are the elements shown in the layout (in order).
  -- Layouts are opened in order so that earlier layouts take priority in window sizing.
  layouts = {
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40, -- 40 columns
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
  },
  controls = {
    -- Requires Neovim nightly (or 0.8 when released)
    enabled = true,
    -- Display controls in this element
    element = "repl",
    icons = {
      pause = "",
      play = "",
      step_into = "",
      step_over = "",
      step_out = "",
      step_back = "",
      run_last = "",
      terminate = "",
    },
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
    max_value_lines = 100, -- Can be integer or nil.
  }
})
end

dapui_setup();

function dapui_reload()
  dapui_setup();
  require("dapui").open();
end
