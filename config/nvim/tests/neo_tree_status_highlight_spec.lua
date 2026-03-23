local M = {}

local helpers = require('tests.helpers')
local assert_eq = helpers.assert_eq
local assert_truthy = helpers.assert_truthy

if not package.preload['neo-tree.sources.common.components'] then
  package.preload['neo-tree.sources.common.components'] = function()
    local function fake_git_status(config, node, state)
      local lookup = state.git_status_lookup or {}
      local status = lookup[node.path]
      if type(status) ~= 'string' then
        return {}
      end

      if status == '??' then
        return {
          {
            text = (config.symbols and config.symbols.untracked) or '?',
            highlight = 'NeoTreeGitUntracked',
          },
        }
      end

      local index = status:sub(1, 1)
      local worktree = status:sub(2, 2)
      local components = {}
      local symbols = config.symbols or {}

      if index and index ~= '' and index ~= ' ' then
        table.insert(components, {
          text = symbols.staged or 'S',
          highlight = 'NeoTreeGitStaged',
        })

        if index == 'M' then
          table.insert(components, {
            text = symbols.modified or '●',
            highlight = 'NeoTreeGitModified',
          })
        elseif index:match('R') then
          table.insert(components, {
            text = symbols.renamed or 'R',
            highlight = 'NeoTreeGitRenamed',
          })
        elseif index:match('[ACT]') then
          table.insert(components, {
            text = symbols.added or '+',
            highlight = 'NeoTreeGitAdded',
          })
        end
      end

      if worktree and worktree ~= '' and worktree ~= ' ' then
        table.insert(components, {
          text = symbols.unstaged or 'U',
          highlight = 'NeoTreeGitUnstaged',
        })
      end

      return components
    end

    local function fake_name(config, node, state)
      local highlight = config.highlight or (node.type == 'directory' and 'NeoTreeDirectoryName' or 'NeoTreeFileName')

      if config.use_git_status_colors and state then
        local lookup = state.git_status_lookup or {}
        local status = lookup[node.path]
        if type(status) == 'string' then
          if status == '??' then
            highlight = 'NeoTreeGitUntracked'
          else
            local index = status:sub(1, 1)
            local worktree = status:sub(2, 2)
            if index:match('R') then
              highlight = 'NeoTreeGitRenamed'
            elseif index:match('[ACT]') then
              highlight = 'NeoTreeGitAdded'
            elseif index == 'M' then
              highlight = 'NeoTreeGitModified'
            end
            if worktree and worktree ~= '' and worktree ~= ' ' then
              highlight = 'NeoTreeGitUnstaged'
            end
          end
        end
      end

      return {
        text = node.name,
        highlight = highlight,
      }
    end

    return {
      name = fake_name,
      git_status = fake_git_status,
    }
  end
end

local expected_colors = {
  NeoTreeGitModified = '#FF6666',
  NeoTreeGitAdded = '#FF6666',
  NeoTreeGitUntracked = '#FF6666',
  NeoTreeGitUnstaged = '#FF6666',
  NeoTreeGitRenamed = '#FF6666',
  NeoTreeModified = '#FF6666',
  NeoTreeGitStaged = '#5f87ff',
  NeoTreeGitPartiallyStaged = '#E0A346',
}

local function build_node(opts)
  local node = {
    name = opts.name or 'sample.lua',
    path = opts.path or '/tmp/sample.lua',
    type = opts.type or 'file',
    filtered_by = nil,
  }

  function node:get_depth()
    return opts.depth or 2
  end

  function node:is_expanded()
    return false
  end

  return node
end

local function build_state(node, status, highlight)
  local lookup = {}
  if status then
    lookup[node.path] = status
  end

  return {
    git_status_lookup = lookup,
    components = {
      git_status = function()
        return { highlight = highlight or 'NeoTreeFileName' }
      end,
    },
  }
end

local function ensure_status_highlights()
  local neo_tree = require('plugins.neo_tree')

  local original_get_hl = vim.api.nvim_get_hl
  local original_set_hl = vim.api.nvim_set_hl

  local requested = {}
  local applied = {}

  vim.api.nvim_get_hl = function(_, opts)
    requested[opts.name] = true
    return { fg = 0xABCDEF, bold = true }
  end

  vim.api.nvim_set_hl = function(_, name, value)
    applied[name] = value
  end

  neo_tree.apply_status_highlights()

  for name, color in pairs(expected_colors) do
    assert_truthy(requested[name], name .. ' ハイライトを参照していること')
    assert_truthy(applied[name], name .. ' ハイライトを上書きしていること')
    assert_eq(applied[name].fg, color, '前景色を期待する色に更新する')
    assert_eq(applied[name].bg, 'NONE', '背景色を解除する')
    assert_eq(applied[name].ctermbg, 'NONE', 'cterm 背景を解除する')
    assert_truthy(applied[name].bold, '既存属性を維持する')
  end

  local cursor_line = applied.NeoTreeCursorLine
  assert_truthy(cursor_line, 'NeoTreeCursorLine ハイライトを設定すること')
  assert_eq(cursor_line.link, 'Visual', 'NeoTreeCursorLine を Visual にリンクする')
  assert_eq(cursor_line.default, false, 'NeoTreeCursorLine の default を false にする')

  vim.api.nvim_get_hl = original_get_hl
  vim.api.nvim_set_hl = original_set_hl
end

local function ensure_name_component_highlight()
  local neo_tree = require('plugins.neo_tree')

  local node = build_node({})
  local config = { use_git_status_colors = true }

  local staged_state = build_state(node, 'M', 'NeoTreeGitModified')
  local staged = neo_tree._filesystem_name_component(config, node, staged_state)
  assert_eq(staged.highlight, 'NeoTreeGitStaged', '完全にステージされた変更は NeoTreeGitStaged を使うこと')

  local added_state = build_state(node, 'A', 'NeoTreeGitAdded')
  local added = neo_tree._filesystem_name_component(config, node, added_state)
  assert_eq(added.highlight, 'NeoTreeGitStaged', '新規追加がステージ済みなら NeoTreeGitStaged を使うこと')

  local renamed_state = build_state(node, 'R100', 'NeoTreeGitRenamed')
  local renamed = neo_tree._filesystem_name_component(config, node, renamed_state)
  assert_eq(renamed.highlight, 'NeoTreeGitStaged', 'リネームがステージ済みなら NeoTreeGitStaged を使うこと')

  local mixed_state = build_state(node, 'MM', 'NeoTreeGitModified')
  local mixed = neo_tree._filesystem_name_component(config, node, mixed_state)
  assert_eq(mixed.highlight, 'NeoTreeGitPartiallyStaged', 'ステージと未ステージが混在する場合は NeoTreeGitPartiallyStaged を使うこと')

  local unstaged_state = build_state(node, ' M', 'NeoTreeGitUnstaged')
  local unstaged = neo_tree._filesystem_name_component(config, node, unstaged_state)
  assert_eq(unstaged.highlight, 'NeoTreeGitUnstaged', '未ステージの変更は既存ハイライトを維持すること')

  local untracked_state = build_state(node, '??', 'NeoTreeGitUntracked')
  local untracked = neo_tree._filesystem_name_component(config, node, untracked_state)
  assert_eq(untracked.highlight, 'NeoTreeGitUntracked', '未追跡ファイルは既存ハイライトを維持すること')

  local no_status_state = build_state(node, nil, 'NeoTreeFileName')
  local normal = neo_tree._filesystem_name_component(config, node, no_status_state)
  assert_eq(normal.highlight, 'NeoTreeFileName', 'ステータスが無いファイルは既存ハイライトを維持すること')
end

local function collect_highlights(component)
  if type(component) ~= 'table' then
    return {}
  end

  if component.highlight then
    return { component.highlight }
  end

  local highlights = {}
  for _, item in ipairs(component) do
    if type(item) == 'table' and item.highlight then
      table.insert(highlights, item.highlight)
    end
  end
  return highlights
end

local function ensure_git_status_component()
  local neo_tree = require('plugins.neo_tree')

  local node = build_node({})
  local config = {
    symbols = {
      added = '+',
      deleted = '-',
      modified = '●',
      renamed = 'R',
      untracked = '?',
      unstaged = 'U',
      staged = 'S',
    },
  }

  local function state_with(status)
    return { git_status_lookup = { [node.path] = status } }
  end

  local function contains(tbl, value)
    for _, v in ipairs(tbl) do
      if v == value then
        return true
      end
    end
    return false
  end

  local staged_highlights = collect_highlights(neo_tree._filesystem_git_status_component(config, node, state_with('M')))
  assert_truthy(contains(staged_highlights, 'NeoTreeGitStaged'), '完全なステージでは ✓ アイコンを NeoTreeGitStaged で表示すること')
  assert_truthy(not contains(staged_highlights, 'NeoTreeGitModified'), '完全なステージでは修正シンボルを表示しないこと')

  local rename_highlights = collect_highlights(neo_tree._filesystem_git_status_component(config, node, state_with('R100')))
  assert_truthy(contains(rename_highlights, 'NeoTreeGitStaged'), 'リネーム済みでも ✓ アイコンを NeoTreeGitStaged で表示すること')

  local mixed_highlights = collect_highlights(neo_tree._filesystem_git_status_component(config, node, state_with('MM')))
  assert_truthy(contains(mixed_highlights, 'NeoTreeGitPartiallyStaged'), '一部ステージでは ◐ アイコンを NeoTreeGitPartiallyStaged で表示すること')

  local unstaged_highlights = collect_highlights(neo_tree._filesystem_git_status_component(config, node, state_with(' M')))
  assert_truthy(contains(unstaged_highlights, 'NeoTreeGitUnstaged'), '未ステージの変更を表示すること')

  local untracked_highlights = collect_highlights(neo_tree._filesystem_git_status_component(config, node, state_with('??')))
  assert_truthy(contains(untracked_highlights, 'NeoTreeGitUntracked'), '未追跡ファイルを表示すること')
end

local function ensure_stage_detection()
  local neo_tree = require('plugins.neo_tree')

  assert_truthy(neo_tree._is_fully_staged('M'), 'M は完全にステージ済みとして扱うこと')
  assert_truthy(neo_tree._is_fully_staged('M '), 'M とスペースは完全にステージ済みとして扱うこと')
  assert_truthy(neo_tree._is_fully_staged('R100'), 'R100 は完全にステージ済みとして扱うこと')
  assert_truthy(not neo_tree._is_fully_staged('MM'), 'MM は未ステージ要素を含むため対象外とすること')
  assert_truthy(not neo_tree._is_fully_staged(' M'), '先頭スペースのステータスは未ステージ扱いとすること')
  assert_truthy(not neo_tree._is_fully_staged('??'), '未追跡ファイルは青くしないこと')

  assert_truthy(neo_tree._is_partially_staged('MM'), 'MM は一部ステージ済みとして扱うこと')
  assert_truthy(neo_tree._is_partially_staged('AM'), 'AM は一部ステージ済みとして扱うこと')
  assert_truthy(not neo_tree._is_partially_staged('M'), 'M は完全ステージなので一部ステージではないこと')
  assert_truthy(not neo_tree._is_partially_staged(' M'), '未ステージのみは一部ステージではないこと')
  assert_truthy(not neo_tree._is_partially_staged('??'), '未追跡は一部ステージではないこと')
end

function M.run()
  ensure_status_highlights()
  ensure_name_component_highlight()
  ensure_git_status_component()
  ensure_stage_detection()
end

return M
