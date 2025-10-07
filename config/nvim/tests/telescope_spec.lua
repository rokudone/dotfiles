local M = {}

local helpers = require('tests.helpers')
local assert_truthy = helpers.assert_truthy
local assert_eq = helpers.assert_eq

function M.run()
  package.loaded['plugins.telescope'] = nil
  package.loaded['telescope'] = nil
  package.loaded['telescope.actions'] = nil
  package.loaded['telescope.builtin'] = nil

  local select_all = function() end
  local config_opts
  local live_grep_calls = {}

  package.preload['telescope'] = function()
    return {
      setup = function(opts)
        config_opts = opts
      end,
      load_extension = function() end,
    }
  end

  local function make_action(name)
    local mt
    local action = { __name = name or 'anonymous' }
    mt = {
      __call = function() end,
      __add = function(left, right)
        return make_action(string.format('%s+%s', left.__name, right.__name))
      end,
    }
    return setmetatable(action, mt)
  end

  package.preload['telescope.actions'] = function()
    return {
      move_selection_next = make_action(),
      move_selection_previous = make_action(),
      toggle_selection = make_action(),
      select_all = select_all,
      cycle_history_next = make_action(),
      cycle_history_prev = make_action(),
      smart_send_to_qflist = make_action('smart_send_to_qflist'),
      send_selected_to_qflist = make_action('send_selected_to_qflist'),
      open_qflist = make_action('open_qflist'),
    }
  end

  local toggle_called = { drop = false, select = false }
  package.preload['telescope.actions.state'] = function()
    return {
      get_current_picker = function()
        return {
          get_multi_selection = function()
            if toggle_called.drop then
              return {}
            end
            toggle_called.drop = true
            return { { value = 1 } }
          end,
        }
      end,
    }
  end

  package.preload['telescope.builtin'] = function()
    local noop = function() end
    return {
      find_files = noop,
      live_grep = function(opts)
        live_grep_calls[#live_grep_calls + 1] = { opts = opts }
      end,
      buffers = noop,
      marks = noop,
      current_buffer_fuzzy_find = noop,
      search_history = noop,
      help_tags = noop,
      jumplist = noop,
      symbols = noop,
    }
  end

  local original_keymap_set = vim.keymap.set
  local registered_maps = {}
  vim.keymap.set = function(mode, lhs, rhs, opts)
    registered_maps[lhs] = { mode = mode, rhs = rhs, opts = opts }
  end

  local original_feedkeys = vim.api.nvim_feedkeys
  local feedkeys_calls = {}
  vim.api.nvim_feedkeys = function(keys, mode, escape)
    feedkeys_calls[#feedkeys_calls + 1] = { keys = keys, mode = mode, escape = escape }
  end

  local original_replace_termcodes = vim.api.nvim_replace_termcodes
  vim.api.nvim_replace_termcodes = function(str)
    return str
  end

  local original_expand = vim.fn.expand

  require('plugins.telescope').setup()

  assert_truthy(config_opts, 'telescope.setup が呼び出されること')
  local mappings = config_opts.defaults.mappings
  assert_truthy(mappings, 'デフォルトマッピングが設定されること')
  assert_truthy(type(mappings.i['<C-y>']) == 'function', '<C-y> は関数であること (insert)')
  assert_truthy(type(mappings.n['<C-y>']) == 'function', '<C-y> は関数であること (normal)')
  assert_truthy(mappings.i['<C-j>'], '<C-j> (insert) が設定されていること')
  assert_truthy(mappings.i['<C-k>'], '<C-k> (insert) が設定されていること')
  assert_truthy(mappings.n['<C-j>'], '<C-j> (normal) が設定されていること')
  assert_truthy(mappings.n['<C-k>'], '<C-k> (normal) が設定されていること')
  assert_truthy(mappings.i['<C-q>'], '<C-q> (insert) が設定されていること')
  assert_eq(mappings.i['<C-q>'].__name, 'smart_send_to_qflist+open_qflist', '<C-q> (insert) は quickfix を開くアクションであること')
  assert_truthy(mappings.n['<C-q>'], '<C-q> (normal) が設定されていること')
  assert_eq(mappings.n['<C-q>'].__name, 'smart_send_to_qflist+open_qflist', '<C-q> (normal) は quickfix を開くアクションであること')

  local leader_a = registered_maps['<Leader>a']
  assert_truthy(leader_a, '<Leader>a が登録されていること')
  leader_a.rhs()
  assert_eq(#live_grep_calls, 0, '<Leader>a は live_grep を直接呼ばないこと')
  assert_eq(#feedkeys_calls, 1, '<Leader>a はコマンドラインに入力すること')
  assert_eq(feedkeys_calls[1].keys, ':Rg ', '<Leader>a は :Rg コマンドを投入すること')

  local leader_A = registered_maps['<Leader>A']
  assert_truthy(leader_A, '<Leader>A が登録されていること')
  vim.fn.expand = function(arg)
    if arg == '<cword>' then
      return 'current_word'
    end
    return ''
  end
  leader_A.rhs()
  assert_eq(#live_grep_calls, 0, '<Leader>A は live_grep を直接呼ばないこと')
  assert_eq(#feedkeys_calls, 2, '<Leader>A はコマンドラインに入力すること')
  assert_eq(feedkeys_calls[2].keys, ':Rg current_word ', '<Leader>A は :Rg コマンドを投入すること')

  vim.keymap.set = original_keymap_set
  vim.api.nvim_feedkeys = original_feedkeys
  vim.api.nvim_replace_termcodes = original_replace_termcodes
  vim.fn.expand = original_expand

  package.preload['telescope'] = nil
  package.preload['telescope.actions'] = nil
  package.preload['telescope.actions.state'] = nil
  package.preload['telescope.builtin'] = nil
  package.loaded['plugins.telescope'] = nil
end

return M
