local M = {}

local fn = vim.fn
local api = vim.api
local map = vim.keymap.set
local cmd = api.nvim_create_user_command
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local function split_words(prompt)
  local utils = require('telescope.utils')
  if not prompt or prompt == '' then
    return {}
  end
  return utils.max_split(prompt, '%s+')
end

local function multiword_fzy_sorter()
  local sorters = require('telescope.sorters')
  local fzy = require('telescope.algos.fzy')
  local OFFSET = -fzy.get_score_floor()

  local function basename(text)
    if not text or text == '' then
      return ''
    end
    return text:match('([^/\\]+)$') or text
  end

  local function score_word(word, target)
    if not target or target == '' or not fzy.has_match(word, target) then
      return nil
    end
    local raw = fzy.score(word, target)
    if raw == fzy.get_score_min() then
      return 1
    end
    return 1 / (raw + OFFSET)
  end

  -- ファイル名にマッチしたスコアを優先する
  local function compute_score(words, line)
    local total = 0
    local count = 0
    local name = basename(line)

    for _, word in ipairs(words) do
      if word ~= '' then
        count = count + 1
        local score_name = score_word(word, name)
        local score_line = score_word(word, line)

        if not score_name and not score_line then
          return -1
        end

        local best = math.max(score_line or 0, (score_name or 0) * 1.25)
        total = total + best
      end
    end

    if count == 0 then
      return 1
    end
    return total / count
  end

  return sorters.Sorter:new({
    discard = true,
    scoring_function = function(_, prompt, line)
      if not line or line == '' then
        return -1
      end
      local words = split_words(prompt)
      if #words == 0 then
        return 1
      end
      return compute_score(words, line)
    end,
    highlighter = function(_, prompt, display)
      local highlights = {}
      for _, word in ipairs(split_words(prompt)) do
        if word ~= '' then
          local positions = fzy.positions(word, display)
          for _, pos in ipairs(positions) do
            if pos then
              table.insert(highlights, { start = pos, finish = pos })
            end
          end
        end
      end
      table.sort(highlights, function(a, b)
        if a.start == b.start then
          return (a.finish or a.start) < (b.finish or b.start)
        end
        return a.start < b.start
      end)
      return highlights
    end,
  })
end

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
      file_sorter = multiword_fzy_sorter,
      generic_sorter = multiword_fzy_sorter,
      vimgrep_arguments = {
        'rg',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
        '--hidden',
        '--no-ignore',
      },
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
    pickers = {
      find_files = {
        hidden = true,
        no_ignore = true,
        no_ignore_parent = true,
        follow = true,
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = false,
        override_file_sorter = false,
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
    feed_commandline('Rg ' .. word)
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
