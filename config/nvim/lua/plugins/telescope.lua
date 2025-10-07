local M = {}

local fn = vim.fn
local api = vim.api
local map = vim.keymap.set
local cmd = api.nvim_create_user_command
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local function feed_commandline(command)
  local keys = api.nvim_replace_termcodes(':' .. command, true, false, true)
  api.nvim_feedkeys(keys, 'n', false)
end

local function systemlist(cmdline)
  local output = fn.systemlist(cmdline)
  if vim.v.shell_error ~= 0 or not output or #output == 0 then
    return nil
  end
  return output[1]
end

local function ensure_paths()
  local dotfiles = vim.g.dotfiles_path
  if not dotfiles or dotfiles == '' then
    local myvimrc = vim.env.MYVIMRC or fn.stdpath('config') .. '/init.lua'
    local config_dir = fn.fnamemodify(myvimrc, ':p:h')
    dotfiles = systemlist('cd ' .. fn.shellescape(config_dir) .. ' && git rev-parse --show-toplevel')
    if not dotfiles or dotfiles == '' then
      dotfiles = config_dir
    end
  end
  vim.g.dotfiles_path = dotfiles

  if not vim.g.claude_code_config_path or vim.g.claude_code_config_path == '' then
    vim.g.claude_code_config_path = fn.expand('~/projects/claude-code-config')
  end
end

local function toggle_select_all(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local selections = picker:get_multi_selection()
  if selections and next(selections) ~= nil then
    actions.drop_all(prompt_bufnr)
  else
    actions.select_all(prompt_bufnr)
  end
end

local function setup_extensions(telescope)
  local send_to_qf = actions.smart_send_to_qflist + actions.open_qflist

  telescope.setup({
    defaults = {
      mappings = {
        i = {
          ['<C-j>'] = actions.cycle_history_next,
          ['<C-k>'] = actions.cycle_history_prev,
          ['<C-y>'] = toggle_select_all,
          ['<C-q>'] = send_to_qf,
        },
        n = {
          ['<C-y>'] = toggle_select_all,
          ['<C-j>'] = actions.cycle_history_next,
          ['<C-k>'] = actions.cycle_history_prev,
          ['<C-q>'] = send_to_qf,
        },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = 'smart_case',
      },
    },
  })

  pcall(telescope.load_extension, 'fzf')
end

local function setup_commands()
  local builtin = require('telescope.builtin')

  cmd('FilesWithQuery', function(opts)
    builtin.find_files({ default_text = opts.args })
  end, { nargs = '?', complete = 'file' })

  cmd('Dotfiles', function(opts)
    builtin.find_files({ cwd = vim.g.dotfiles_path, default_text = opts.args })
  end, { nargs = '?', complete = 'file', bang = true })

  cmd('ClaudeCodeConfig', function(opts)
    builtin.find_files({ cwd = vim.g.claude_code_config_path, default_text = opts.args })
  end, { nargs = '?', complete = 'file', bang = true })

  cmd('Rg', function(opts)
    local text = opts.args ~= '' and opts.args or nil
    builtin.live_grep({ default_text = text })
  end, { nargs = '*', complete = 'file', bang = true })

  cmd('Ag', function(opts)
    local text = opts.args ~= '' and opts.args or nil
    builtin.live_grep({ default_text = text })
  end, { nargs = '*', complete = 'file', bang = true })

  cmd('Emoji', function()
    builtin.symbols({ sources = { 'emoji', 'kaomoji', 'gitmoji' } })
  end, {})

  cmd('Jump', function()
    builtin.jumplist()
  end, {})
end

local function setup_keymaps()
  local builtin = require('telescope.builtin')

  map('n', '<C-p>', builtin.find_files, { silent = true, desc = 'Telescope files' })
  map('n', '<Leader>f', function()
    builtin.find_files({ default_text = fn.expand('%:t:r') })
  end, { silent = true, desc = 'Telescope files (buffer name)' })
  map('n', '<Leader>F', function()
    builtin.find_files({ default_text = fn.expand('<cword>') })
  end, { silent = true, desc = 'Telescope files (word)' })
  map('n', '<Leader>ee', function()
    builtin.find_files({ cwd = vim.g.dotfiles_path })
  end, { silent = true, desc = 'Telescope dotfiles' })
  map('n', '<Leader>ec', function()
    builtin.find_files({ cwd = vim.g.claude_code_config_path })
  end, { silent = true, desc = 'Telescope Claude config' })
  map('n', '<Leader>b', function()
    builtin.buffers({ sort_mru = true, ignore_current_buffer = true })
  end, { silent = true, desc = 'Telescope buffers' })
  map('n', '<Leader>m', builtin.marks, { silent = true, desc = 'Telescope marks' })
  map('n', '<Leader>a', function()
    feed_commandline('Rg ')
  end, { silent = true, desc = 'Telescope live ripgrep' })
  map('n', '<Leader>A', function()
    local word = fn.expand('<cword>')
    feed_commandline('Rg ' .. word .. ' ')
  end, { silent = true, desc = 'Telescope live ripgrep (word)' })
  map('n', '<Leader>/', builtin.current_buffer_fuzzy_find, { silent = true, desc = 'Telescope buffer search' })
  map('n', '<Leader>?', function()
    builtin.live_grep({ grep_open_files = true })
  end, { silent = true, desc = 'Telescope search open buffers' })
  map('n', '<Leader>h', builtin.search_history, { silent = true, desc = 'Telescope search history' })
  map('n', '<Leader>H', builtin.help_tags, { silent = true, desc = 'Telescope help tags' })
  map('n', '<Leader>J', builtin.jumplist, { silent = true, desc = 'Telescope jumplist' })
end

function M.setup()
  ensure_paths()

  local ok, telescope = pcall(require, 'telescope')
  if not ok then
    vim.notify('Telescope is not available', vim.log.levels.WARN, { title = 'plugins.telescope' })
    return
  end

  setup_extensions(telescope)
  setup_commands()
  setup_keymaps()
end

return M
