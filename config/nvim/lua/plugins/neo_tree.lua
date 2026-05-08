local M = {}

local keymap_registered = false
local highlight_group_registered = false

local status_colors = {
  NeoTreeGitModified = '#FF6666',
  NeoTreeGitAdded = '#FF6666',
  NeoTreeGitUntracked = '#FF6666',
  NeoTreeGitUnstaged = '#888888',
  NeoTreeGitRenamed = '#FF6666',
  NeoTreeGitDeleted = '#CC3333',
  NeoTreeModified = '#FF6666',
  NeoTreeGitStaged = '#5f87ff',
  NeoTreeGitPartiallyStaged = '#E0A346',
}

local base_name_component
local base_git_status_component

local function fallback_name_component(config, node, state)
  local highlight = config.highlight or (node.type == 'directory' and 'NeoTreeDirectoryName' or 'NeoTreeFileName')

  if config.use_git_status_colors and state and state.components then
    local git_status_component = state.components.git_status
    if type(git_status_component) == 'function' then
      local git_status = git_status_component({}, node, state)
      if git_status and git_status.highlight then
        highlight = git_status.highlight
      end
    end
  end

  return {
    text = node.name,
    highlight = highlight,
  }
end

local function get_base_name_component()
  if base_name_component ~= nil then
    return base_name_component
  end

  local ok, components = pcall(require, 'neo-tree.sources.common.components')
  if ok and type(components) == 'table' and type(components.name) == 'function' then
    base_name_component = components.name
  else
    base_name_component = fallback_name_component
  end

  return base_name_component
end

local function fallback_git_status_component()
  return function()
    return {}
  end
end

local function get_base_git_status_component()
  if base_git_status_component ~= nil then
    return base_git_status_component
  end

  local ok, components = pcall(require, 'neo-tree.sources.common.components')
  if ok and type(components) == 'table' and type(components.git_status) == 'function' then
    base_git_status_component = components.git_status
  else
    base_git_status_component = fallback_git_status_component()
  end

  return base_git_status_component
end

local staged_index_codes = {
  A = true,
  C = true,
  D = true,
  M = true,
  R = true,
  T = true,
}

local function staging_state(status)
  if type(status) ~= 'string' or status == '' then
    return nil
  end

  if status == '??' or status == '!!' then
    return 'unstaged'
  end

  local index = status:sub(1, 1)
  local worktree = status:sub(2, 2)

  local has_staged = staged_index_codes[index] or false
  local has_worktree = worktree ~= nil and worktree ~= '' and worktree ~= ' '
    and not worktree:match('%d')

  if has_staged and not has_worktree then
    return 'staged'
  elseif has_staged and has_worktree then
    return 'partial'
  elseif worktree == 'D' then
    return 'deleted'
  else
    return 'unstaged'
  end
end

local function is_fully_staged(status)
  return staging_state(status) == 'staged'
end

local function is_partially_staged(status)
  return staging_state(status) == 'partial'
end

local function name_component(config, node, state)
  local component = get_base_name_component()(config, node, state)

  if node.type ~= 'file' then
    return component
  end

  local lookup = state and state.git_status_lookup
  if not lookup then
    return component
  end

  local status = lookup[node.path]
  local state_type = staging_state(status)

  if state_type == 'staged' then
    if type(component) == 'table' and component.highlight then
      component.highlight = 'NeoTreeGitStaged'
    end
  elseif state_type == 'partial' then
    if type(component) == 'table' and component.highlight then
      component.highlight = 'NeoTreeGitPartiallyStaged'
    end
  end

  return component
end

local change_highlights = {
  NeoTreeGitModified = true,
  NeoTreeGitRenamed = true,
  NeoTreeGitAdded = true,
  NeoTreeGitDeleted = true,
  NeoTreeGitConflict = true,
  NeoTreeGitUnstaged = true,
}

local function filter_staged_components(components)
  if type(components) ~= 'table' then
    return components
  end

  if components.highlight then
    if change_highlights[components.highlight] then
      return {}
    end
    return components
  end

  local filtered = {}
  for _, item in ipairs(components) do
    if type(item) == 'table' then
      local highlight = item.highlight
      if highlight == nil or not change_highlights[highlight] then
        filtered[#filtered + 1] = item
      end
    end
  end
  return filtered
end

local function dir_aggregate_status(lookup, dir_path)
  local prefix = dir_path .. '/'
  local has_staged = false
  local has_deleted = false
  local has_other_unstaged = false

  for path, status in pairs(lookup) do
    if path:sub(1, #prefix) == prefix then
      local s = staging_state(status)
      if s == 'staged' then
        has_staged = true
      elseif s == 'partial' then
        has_staged = true
        has_other_unstaged = true
      elseif s == 'unstaged' then
        local wt = type(status) == 'string' and status:sub(2, 2) or ''
        if wt == 'D' then
          has_deleted = true
        else
          has_other_unstaged = true
        end
      end
    end
  end

  if not has_staged and not has_deleted and not has_other_unstaged then
    return nil
  end

  if has_staged and not has_deleted and not has_other_unstaged then
    return 'staged'
  elseif has_staged then
    return 'partial'
  elseif has_deleted and not has_other_unstaged then
    return 'deleted'
  else
    return 'unstaged'
  end
end

local function git_status_component(config, node, state)
  local component = get_base_git_status_component()(config, node, state)

  local lookup = state and state.git_status_lookup
  if not lookup then
    return component
  end

  local sstate
  if node.type == 'directory' then
    sstate = dir_aggregate_status(lookup, node.path)
  else
    local status = lookup[node.path]
    sstate = staging_state(status)
  end

  if sstate == 'staged' then
    return {
      { text = ' ✓', highlight = 'NeoTreeGitStaged' },
    }
  elseif sstate == 'partial' then
    return {
      { text = ' ◐', highlight = 'NeoTreeGitPartiallyStaged' },
    }
  elseif sstate == 'deleted' then
    return {
      { text = ' ✗', highlight = 'NeoTreeGitDeleted' },
    }
  elseif sstate == 'unstaged' then
    return {
      { text = ' ·', highlight = 'NeoTreeGitUnstaged' },
    }
  end

  return {}
end

local function override_highlight(name, color)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  local current = (ok and type(hl) == 'table') and vim.deepcopy(hl) or {}
  current.fg = color or current.fg
  current.bg = 'NONE'
  current.ctermbg = 'NONE'
  current.default = nil

  vim.api.nvim_set_hl(0, name, current)
end

local function apply_status_highlights()
  for name, color in pairs(status_colors) do
    override_highlight(name, color)
  end
  vim.api.nvim_set_hl(0, 'NeoTreeCursorLine', { link = 'Visual', default = false })
end

function M.apply_status_highlights()
  apply_status_highlights()
end

local function toggle_explorer()
  vim.cmd('Neotree toggle reveal_force_cwd=true')
end


local function copy_node_path(state)
  local node = state.tree:get_node()
  if not node then
    return
  end
  local path = node:get_id()
  vim.fn.setreg('+', path)
  vim.notify('Copied path: ' .. path, vim.log.levels.INFO, { title = 'Neo-tree' })
end

local function notify_diffview_missing()
  vim.notify('diffview.nvim を読み込めませんでした', vim.log.levels.WARN, { title = 'Neo-tree' })
end

local function open_diffview(state)
  local node = state.tree:get_node()
  if not node then
    return
  end

  local ok, diffview = pcall(require, 'diffview')
  if not ok then
    notify_diffview_missing()
    return
  end

  diffview.open({ '--', node:get_id() })
end

local function open_diffview_history(state)
  local node = state.tree:get_node()
  if not node then
    return
  end

  local ok, diffview = pcall(require, 'diffview')
  if not ok then
    notify_diffview_missing()
    return
  end

  diffview.file_history(nil, { node:get_id() })
end

local narrow_width = 40
local wide_width = 80

local function toggle_width(state)
  local win = state.winid or vim.api.nvim_get_current_win()
  local current = vim.api.nvim_win_get_width(win)
  local target = current >= wide_width and narrow_width or wide_width
  vim.api.nvim_win_set_width(win, target)
end

local function system_open(state)
  local node = state.tree:get_node()
  if not node then
    return
  end
  local path = node:get_id()
  vim.fn.jobstart({ 'open', path }, { detach = true })
end

local function open_and_close(state)
  local node = state.tree:get_node()
  if not node then
    return
  end
  if node.type == 'directory' then
    state.commands['set_root'](state)
  else
    state.commands['open'](state)
    vim.cmd('Neotree close')
  end
end

function M.setup()
  local ok, neotree = pcall(require, 'neo-tree')
  if not ok then
    return
  end

  neotree.setup({
    close_if_last_window = true,
    popup_border_style = 'rounded',
    sources = {
      'filesystem',
      'buffers',
      'git_status',
      'document_symbols',
      'diagnostics',
    },
    default_component_configs = {
      indent = {
        last_indent_marker = '└ ',
      },
      icon = {
        folder_closed = '',
        folder_open = '',
        folder_empty = '',
        default = '',
        highlight = 'NeoTreeFileIcon',
      },
    },
    -- unknownタイプ（削除されたファイル等）用のrendererを追加
    renderers = {
      unknown = {
        { 'indent' },
        { 'icon' },
        {
          'container',
          content = {
            { 'name', zindex = 10 },
            { 'clipboard', zindex = 10 },
            { 'git_status', zindex = 10, align = 'right' },
          },
        },
      },
    },
    filesystem = {
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      components = {
        name = name_component,
        git_status = git_status_component,
      },
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_hidden = false,
      },
      window = {
        mappings = {
          ['o'] = system_open,
          ['h'] = 'close_node',
          ['l'] = 'open',
          ['v'] = 'open_vsplit',
          ['s'] = 'open_split',
          ['<CR>'] = open_and_close,
          ['J'] = 'move',
          ['K'] = 'move',
          ['<Space>'] = 'toggle_node',
          ['-'] = 'navigate_up',
          ['/'] = 'none',  -- use vim native buffer search instead of fuzzy_finder
          ['.'] = 'toggle_hidden',
          ['W'] = toggle_width,
          ['Y'] = copy_node_path,
          ['gd'] = open_diffview,
          ['gH'] = open_diffview_history,
          ['S'] = 'git_add_file',
          ['ga'] = 'git_add_file',
          ['U'] = 'git_unstage_file',
          ['gu'] = 'git_unstage_file',
          ['R'] = 'git_revert_file',
          ['C'] = 'git_commit',
          ['P'] = 'git_push',
          ['gg'] = 'none',
        },
      },
    },
    git_status = {
      components = {
        name = name_component,
        git_status = git_status_component,
      },
      window = {
        position = 'float',
        mappings = {
          ['gd'] = open_diffview,
          ['gH'] = open_diffview_history,
          ['S'] = 'git_add_file',
          ['ga'] = 'git_add_file',
          ['U'] = 'git_unstage_file',
          ['gu'] = 'git_unstage_file',
          ['R'] = 'git_revert_file',
          ['C'] = 'git_commit',
          ['P'] = 'git_push',
          ['v'] = 'open_vsplit',
          ['s'] = 'open_split',
          ['W'] = toggle_width,
          ['gg'] = 'none',
        },
      },
    },
    buffers = {
      window = {
        mappings = {
          ['W'] = toggle_width,
        },
      },
    },
    document_symbols = {
      window = {
        mappings = {
          ['W'] = toggle_width,
        },
      },
    },
    diagnostics = {
      window = {
        mappings = {
          ['W'] = toggle_width,
        },
      },
    },
  })

  M.apply_status_highlights()
  if not highlight_group_registered then
    local group = vim.api.nvim_create_augroup('NeoTreeStatusHighlights', { clear = true })
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = group,
      callback = function()
        M.apply_status_highlights()
      end,
    })
    highlight_group_registered = true
  end

  if not keymap_registered then
    vim.keymap.set('n', 'ge', toggle_explorer, { silent = true, desc = 'Neo-tree: Toggle Explorer' })

    keymap_registered = true
  end
end

M._filesystem_name_component = name_component
M._filesystem_git_status_component = git_status_component
M._is_fully_staged = is_fully_staged
M._is_partially_staged = is_partially_staged

return M
