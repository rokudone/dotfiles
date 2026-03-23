local M = {}

local helpers = require('tests.helpers')
local assert_eq = helpers.assert_eq
local assert_truthy = helpers.assert_truthy

local ESC = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)

local function find_map(mode, lhs)
  local alt = lhs:upper()
  local alt_match
  for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
    if map.lhs == lhs then
      return map
    end
    if not alt_match and map.lhs == alt then
      alt_match = map
    end
  end
  return alt_match
end

function M.run()
  local keymaps = require('core.keymaps')
  keymaps.setup()

  local abbrev_output = vim.api.nvim_exec2('cnoreabbrev s', { output = true }).output
  assert_truthy(
    not abbrev_output:find('getchar()', 1, true),
    ':s コマンド補完で getchar() を呼び出してユーザー入力を阻害しないこと'
  )
  assert_eq(
    vim.trim(abbrev_output),
    'No abbreviation found',
    ':s 補完が存在しないことを期待する挙動に合わせること'
  )

  local mark_prefix = find_map('n', '[Mark]')
  assert_truthy(mark_prefix, '[Mark] mapping should exist')
  assert_truthy(mark_prefix.rhs == '<Nop>' or mark_prefix.rhs == '', '[Mark] should map to <Nop> or empty rhs')

  local mark_trigger = find_map('n', 'm')
  assert_truthy(mark_trigger, 'm remapping should exist')
  assert_eq(mark_trigger.rhs, '[Mark]', 'm should remap to [Mark]')

  local indent_up = find_map('n', '<C-k>')
  assert_truthy(indent_up and indent_up.callback, '<C-k> mapping should call Lua callback')

  local indent_down = find_map('n', '<C-j>')
  assert_truthy(indent_down and indent_down.callback, '<C-j> mapping should call Lua callback')

  local leader = vim.g.mapleader or '\\'
  local visual_substitute = find_map('v', leader .. 's')
  assert_truthy(visual_substitute, 'ビジュアルモードの <leader>s マッピングが存在すること')
  assert_eq(
    visual_substitute.rhs,
    ":<C-U>'<lt>,'>s/\\v",
    'ビジュアルモードの <leader>s では余計な範囲指定を付与しないこと'
  )

  local outline_map = find_map('n', leader .. 'o')
  assert_truthy(outline_map, '<leader>o で outline を起動できること')
  assert_truthy(
    outline_map.desc == 'Toggle Outline',
    'Outline 用のキーマップには説明が付いていること'
  )

  local original_gitsigns = package.preload['gitsigns']
  local original_gitsigns_cache = package.preload['gitsigns.cache']
  local original_gitsigns_manager = package.preload['gitsigns.manager']
  local original_loaded_gitsigns = package.loaded['gitsigns']
  local original_loaded_cache = package.loaded['gitsigns.cache']
  local original_loaded_manager = package.loaded['gitsigns.manager']

  local undo_stage_called = false
  local gitsigns_bufnr

  package.preload['gitsigns'] = function()
    return {
      setup = function(opts)
        assert_truthy(type(opts.on_attach) == 'function', 'gitsigns should provide on_attach callback')
        gitsigns_bufnr = vim.api.nvim_create_buf(false, true)
        opts.on_attach(gitsigns_bufnr)
      end,
      preview_hunk = function() end,
      stage_hunk = function() end,
      toggle_current_line_blame = function() end,
      blame_line = function() end,
      next_hunk = function() end,
      prev_hunk = function() end,
      reset_hunk = function() end,
      undo_stage_hunk = function()
        undo_stage_called = true
      end,
    }
  end

  package.preload['gitsigns.cache'] = function()
    return { cache = {} }
  end

  package.preload['gitsigns.manager'] = function()
    return { update = function() end }
  end

  if original_loaded_gitsigns ~= nil then
    package.loaded['gitsigns'] = nil
  end
  if original_loaded_cache ~= nil then
    package.loaded['gitsigns.cache'] = nil
  end
  if original_loaded_manager ~= nil then
    package.loaded['gitsigns.manager'] = nil
  end

  local gitsigns_plugin = require('plugins.gitsigns')
  gitsigns_plugin.setup()

  assert_truthy(gitsigns_bufnr, 'gitsigns setup should attach to buffer')
  local git_maps = vim.api.nvim_buf_get_keymap(gitsigns_bufnr, 'n')
  local git_u_map
  for _, map in ipairs(git_maps) do
    if map.lhs == '[git]u' then
      git_u_map = map
    end
  end
  assert_truthy(git_u_map and git_u_map.callback, '[git]u mapping should exist and use Lua callback')
  git_u_map.callback()
  assert_truthy(undo_stage_called, '[git]u mapping should call gitsigns.undo_stage_hunk')

  undo_stage_called = false

  local git_maps_visual = vim.api.nvim_buf_get_keymap(gitsigns_bufnr, 'x')
  local git_u_visual_map
  for _, map in ipairs(git_maps_visual) do
    if map.lhs == '[git]u' then
      git_u_visual_map = map
      break
    end
  end
  assert_truthy(git_u_visual_map and git_u_visual_map.callback, 'ビジュアルモードでも [git]u が利用できること')
  git_u_visual_map.callback()
  assert_truthy(undo_stage_called, 'ビジュアルモードの [git]u でも undo_stage_hunk を呼び出すこと')

  vim.api.nvim_buf_delete(gitsigns_bufnr, { force = true })

  if original_gitsigns then
    package.preload['gitsigns'] = original_gitsigns
  else
    package.preload['gitsigns'] = nil
  end
  if original_gitsigns_cache then
    package.preload['gitsigns.cache'] = original_gitsigns_cache
  else
    package.preload['gitsigns.cache'] = nil
  end
  if original_gitsigns_manager then
    package.preload['gitsigns.manager'] = original_gitsigns_manager
  else
    package.preload['gitsigns.manager'] = nil
  end

  if original_loaded_gitsigns ~= nil then
    package.loaded['gitsigns'] = original_loaded_gitsigns
  else
    package.loaded['gitsigns'] = nil
  end
  if original_loaded_cache ~= nil then
    package.loaded['gitsigns.cache'] = original_loaded_cache
  else
    package.loaded['gitsigns.cache'] = nil
  end
  if original_loaded_manager ~= nil then
    package.loaded['gitsigns.manager'] = original_loaded_manager
  else
    package.loaded['gitsigns.manager'] = nil
  end

  local neo_tree_called = false
  local neo_tree_config
  local original_preload = package.preload['neo-tree']
  package.preload['neo-tree'] = function()
    return {
      setup = function(opts)
        neo_tree_called = true
        neo_tree_config = opts
      end,
    }
  end

  local neo_tree = require('plugins.neo_tree')
  neo_tree.setup()
  assert_truthy(neo_tree_called, 'neo-tree setup should be invoked')
  assert_truthy(neo_tree_config, 'neo-tree setup should receive configuration')
  local filesystem_cfg = neo_tree_config and neo_tree_config.filesystem
  assert_truthy(filesystem_cfg, 'neo-tree filesystem config should be provided')
  local filesystem_window = filesystem_cfg.window
  assert_truthy(filesystem_window, 'neo-tree filesystem.window should be configured')
  local filesystem_mappings = filesystem_window.mappings
  assert_truthy(filesystem_mappings, 'neo-tree filesystem.window.mappings should be configured')
  assert_eq(filesystem_mappings.v, 'open_vsplit', 'v should open vsplit in filesystem view')
  assert_eq(filesystem_mappings.s, 'open_split', 's should open split in filesystem view')
  assert_eq(filesystem_mappings.S, 'git_add_file', 'S should stage the file from filesystem view')
  assert_eq(filesystem_mappings.U, 'git_unstage_file', 'U should unstage the file from filesystem view')
  assert_eq(filesystem_mappings.R, 'git_revert_file', 'R should revert the file from filesystem view')
  assert_eq(filesystem_mappings.ga, 'git_add_file', 'ga should stage the file from filesystem view')
  assert_eq(filesystem_mappings.gu, 'git_unstage_file', 'gu should unstage the file from filesystem view')
  local filtered_items = filesystem_cfg.filtered_items
  assert_truthy(filtered_items, 'neo-tree filesystem.filtered_items should be configured')
  assert_eq(filtered_items.visible, true, 'neo-tree filtered items should be visible by default')
  assert_eq(filtered_items.hide_dotfiles, false, 'neo-tree should show dotfiles by default')
  assert_eq(filtered_items.hide_hidden, false, 'neo-tree should show hidden files by default')

  local git_status_cfg = neo_tree_config.git_status
  assert_truthy(git_status_cfg, 'neo-tree git_status config should be provided')
  local git_status_window = git_status_cfg.window
  assert_truthy(git_status_window, 'neo-tree git_status.window should be configured')
  assert_eq(git_status_window.position, 'float', 'neo-tree git_status window should use float position')
  local git_status_mappings = git_status_window.mappings
  assert_truthy(git_status_mappings, 'neo-tree git_status.window.mappings should be configured')
  assert_eq(git_status_mappings.S, 'git_add_file', 'S should stage the file in git_status')
  assert_eq(git_status_mappings.U, 'git_unstage_file', 'U should unstage the file in git_status')
  assert_eq(git_status_mappings.R, 'git_revert_file', 'R should revert the file in git_status')
  assert_eq(git_status_mappings.C, 'git_commit', 'C should commit in git_status')
  assert_eq(git_status_mappings.P, 'git_push', 'P should push in git_status')
  assert_eq(git_status_mappings.v, 'open_vsplit', 'v should open vsplit in git_status view')
  assert_eq(git_status_mappings.s, 'open_split', 's should open split in git_status view')
  assert_eq(git_status_mappings.ga, 'git_add_file', 'ga should stage the file in git_status view')
  assert_eq(git_status_mappings.gu, 'git_unstage_file', 'gu should unstage the file in git_status view')

  local neo_tree_map = find_map('n', 'ge')
  assert_truthy(neo_tree_map and neo_tree_map.callback, 'ge mapping should invoke Neo-tree toggle')

  local cursor_map = find_map('n', '<Leader>c') or find_map('n', '\\c')
  assert_truthy(cursor_map and cursor_map.callback, '<Leader>c mapping should open cursor')

  local yank_with_path_map = find_map('n', 'Y')
  assert_truthy(yank_with_path_map and yank_with_path_map.callback, 'Y キーマップが存在し、Lua コールバックを呼び出すこと')

  local original_expand = vim.fn.expand
  local original_line = vim.fn.line
  local original_jobstart = vim.fn.jobstart
  local original_win_get_cursor = vim.api.nvim_win_get_cursor

  local expand_calls = {}
  vim.fn.expand = function(arg)
    table.insert(expand_calls, arg)
    if arg == '%:S' then
      return "'dummy/path'"
    elseif arg == '%:p' then
      return '/abs/dummy/path'
    end
    return original_expand(arg)
  end

  vim.fn.line = function(expr)
    if expr == '.' then
      return 42
    end
    return original_line(expr)
  end

  local job_cmd
  local job_opts
  vim.fn.jobstart = function(cmd, opts)
    job_cmd = cmd
    job_opts = opts
    return 1
  end
  vim.api.nvim_win_get_cursor = function()
    return { 13, 0 }
  end

  local ok, err = pcall(function()
    cursor_map.callback()
  end)

  vim.fn.expand = original_expand
  vim.fn.line = original_line
  vim.fn.jobstart = original_jobstart

  assert_truthy(ok, err)
  assert_truthy(job_cmd, 'cursor コマンドが実行されること')
  assert_eq(job_cmd[1], 'cursor', 'cursor コマンド名が正しいこと')
  assert_eq(job_cmd[2], '-g', '-g オプションを付与すること')
  assert_eq(job_cmd[3], '/abs/dummy/path:42', 'cursor の引数が正しいこと')
  assert_truthy(not job_cmd[3]:find("'", 1, true), 'cursor 引数に単一引用符を含めないこと')
  assert_truthy(job_opts and job_opts.detach, 'cursor コマンドは detach オプションで起動すること')

  local original_getline = vim.fn.getline
  local original_setreg = vim.fn.setreg
  local selection_finalized = false

  local clipboard_payload = {}
  vim.fn.expand = function(expr)
    if expr == '%:p' then
      return '/abs/test/file.lua'
    elseif expr == '%' then
      return 'relative/path.lua'
    end
    return original_expand(expr)
  end
  vim.fn.line = function(expr)
    if expr == '$' then
      return 120
    end
    if expr == '.' then
      return 13
    end
    if expr == "'<" then
      assert_truthy(selection_finalized, 'ビジュアル開始位置は Esc 後に取得すること')
      return 13
    end
    if expr == "'>" then
      assert_truthy(selection_finalized, 'ビジュアル終了位置は Esc 後に取得すること')
      return 13
    end
    return original_line(expr)
  end
  vim.fn.getline = function(lnum)
    if lnum == 13 then
      return 'print("hello world")'
    end
    return original_getline(lnum)
  end
  vim.fn.setreg = function(reg, value)
    clipboard_payload[reg] = value
  end

  local ok_yank, err_yank = pcall(function()
    yank_with_path_map.callback()
  end)

  assert_truthy(ok_yank, err_yank)
  assert_truthy(clipboard_payload['"'], 'デフォルトレジスタへ書き込むこと')
  assert_truthy(clipboard_payload['+'], 'システムクリップボードへ書き込むこと')
  assert_eq(
    clipboard_payload['"'],
    '/abs/test/file.lua:13 print("hello world")',
    'コピー内容にファイルパスと行番号を含めること'
  )
  assert_eq(
    clipboard_payload['+'],
    '/abs/test/file.lua:13 print("hello world")',
    'コピー内容にファイルパスと行番号を含めること'
  )

  local visual_yank_map = find_map('v', 'Y')
  assert_truthy(visual_yank_map and visual_yank_map.callback, 'ビジュアルモードの Y キーマップが存在すること')

  local recorded_cmds = {}
  local original_cmd = vim.cmd
  local esc_cmd = 'normal! ' .. ESC
  vim.cmd = function(cmd)
    recorded_cmds[#recorded_cmds + 1] = cmd
    if cmd == esc_cmd then
      selection_finalized = true
    end
  end

  selection_finalized = false
  local ok_visual_yank, err_visual_yank = pcall(function()
    visual_yank_map.callback()
  end)

  assert_truthy(ok_visual_yank, err_visual_yank)
  assert_truthy(#recorded_cmds > 0, 'ビジュアルモードのコピー後にコマンドが実行されること')
  assert_eq(recorded_cmds[#recorded_cmds], esc_cmd, 'コピー後に選択を解除するため normal! <Esc> を発行すること')

  local reversed_payload = {}
  vim.fn.expand = function(expr)
    if expr == '%:p' then
      return '/abs/test/file.lua'
    elseif expr == '%' then
      return 'relative/path.lua'
    end
    return original_expand(expr)
  end
  vim.fn.line = function(expr)
    if expr == '$' then
      return 200
    elseif expr == "'<" then
      assert_truthy(selection_finalized, 'ビジュアル開始位置は Esc 後に取得すること')
      return 20
    elseif expr == "'>" then
      assert_truthy(selection_finalized, 'ビジュアル終了位置は Esc 後に取得すること')
      return 13
    end
    return original_line(expr)
  end
  vim.fn.getline = function(lnum)
    if lnum >= 13 and lnum <= 20 then
      return string.format('line %d', lnum)
    end
    return original_getline(lnum)
  end
  vim.fn.setreg = function(reg, value)
    reversed_payload[reg] = value
  end

  selection_finalized = false
  local ok_reverse_visual, err_reverse_visual = pcall(function()
    visual_yank_map.callback()
  end)

  assert_truthy(ok_reverse_visual, err_reverse_visual)
  local expected_lines = {}
  for lnum = 13, 20 do
    table.insert(expected_lines, string.format('/abs/test/file.lua:%d line %d', lnum, lnum))
  end
  local expected_payload = table.concat(expected_lines, '\n')
  assert_eq(reversed_payload['"'], expected_payload, '選択範囲を上から下へ並べ替えてコピーすること')
  assert_eq(reversed_payload['+'], expected_payload, '選択範囲を上から下へ並べ替えてコピーすること')

  vim.cmd = original_cmd

  vim.fn.expand = original_expand
  vim.fn.line = original_line
  vim.fn.getline = original_getline
  vim.fn.setreg = original_setreg
  vim.api.nvim_win_get_cursor = original_win_get_cursor

  if original_preload then
    package.preload['neo-tree'] = original_preload
  else
    package.preload['neo-tree'] = nil
  end
end

return M
