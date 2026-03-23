local M = {}

local helpers = require('tests.helpers')
local assert_eq = helpers.assert_eq
local assert_truthy = helpers.assert_truthy

local function with_stubbed_ayu(callback)
  local original_module = package.loaded.ayu
  local original_colors = package.loaded['ayu.colors']
  local setup_called = false

  local colors_stub = {
    special = '#FFEEAA',
    comment = '#666666',
    bg = '#0F1419',
    generate = function() end,
  }

  package.loaded.ayu = {
    setup = function(opts)
      setup_called = true
      callback.on_setup(opts, colors_stub)
    end,
  }
  package.loaded['ayu.colors'] = colors_stub

  local ok, err = pcall(callback.run)

  package.loaded.ayu = original_module
  if original_colors == nil then
    package.loaded['ayu.colors'] = nil
  else
    package.loaded['ayu.colors'] = original_colors
  end

  if not ok then
    error(err)
  end

  return setup_called
end

function M.run()
  local colors = require('plugins.ayu')

  local command_called
  local original_cmd = vim.cmd

  vim.cmd = function(cmd)
    command_called = cmd
  end

  local setup_called = with_stubbed_ayu({
    on_setup = function(opts, colors_stub)
      assert_eq(opts.mirage, false, 'mirage オプションは false のままにする')

      assert_truthy(opts.overrides, 'overrides を設定すること')
      assert_eq(type(opts.overrides), 'function', 'overrides は関数で渡す')

      local generate_called_with
      colors_stub.generate = function(mirage)
        generate_called_with = mirage
        colors_stub.comment = '#737373'
      end

      local overrides = opts.overrides()
      assert_eq(generate_called_with, false, 'colors.generate には mirage 値をそのまま渡す')

      local comment_override = overrides.Comment
      assert_truthy(comment_override, 'Comment の override を設定すること')
      assert_eq(comment_override.bg, 'NONE', 'Comment の背景は常に透過にする')
      assert_eq(comment_override.ctermbg, 'NONE', 'Comment の cterm 背景も透過にする')
      assert_eq(comment_override.fg, '#737373', 'Comment の前景色を落ち着いたグレーにする')
      assert_eq(comment_override.italic, true, 'Comment の italic スタイルを維持する')

      local ts_comment_override = overrides['@comment']
      assert_truthy(ts_comment_override, '@comment の override を設定すること')
      assert_eq(ts_comment_override.bg, 'NONE', '@comment の背景は透過にする')
      assert_eq(ts_comment_override.ctermbg, 'NONE', '@comment の cterm 背景も透過にする')
      assert_eq(ts_comment_override.fg, '#737373', '@comment の前景色を Comment と揃える')

      local doc_comment_override = overrides['@comment.documentation']
      assert_truthy(doc_comment_override, '@comment.documentation の override を設定すること')
      assert_eq(doc_comment_override.bg, 'NONE', '@comment.documentation の背景は透過にする')
      assert_eq(doc_comment_override.ctermbg, 'NONE', '@comment.documentation の cterm 背景も透過にする')
      assert_eq(doc_comment_override.fg, '#737373', '@comment.documentation の前景色を Comment と揃える')

      local fzf_dir_override = overrides.FzfLuaDirPart
      assert_truthy(fzf_dir_override, 'FzfLuaDirPart の override を設定すること')
      assert_eq(fzf_dir_override.bg, 'NONE', 'FzfLuaDirPart の背景は透過にする')
      assert_eq(fzf_dir_override.ctermbg, 'NONE', 'FzfLuaDirPart の cterm 背景も透過にする')
      assert_eq(fzf_dir_override.fg, '#737373', 'FzfLuaDirPart の前景色を落ち着いたグレーにする')
    end,
    run = function()
      colors.setup()
    end,
  })

  vim.cmd = original_cmd

  assert_truthy(setup_called, 'ayu.setup が呼び出されること')
  assert_eq(command_called, 'colorscheme ayu', 'colorscheme ayu を実行すること')
end

return M
