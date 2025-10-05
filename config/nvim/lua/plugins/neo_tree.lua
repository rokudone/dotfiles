local M = {}

local keymap_registered = false
local highlight_group_registered = false

local highlight_targets = {
  'NeoTreeGitModified',
  'NeoTreeGitAdded',
  'NeoTreeGitUntracked',
  'NeoTreeGitUnstaged',
  'NeoTreeGitStaged',
  'NeoTreeGitRenamed',
  'NeoTreeModified',
}

local highlight_color = '#FF6666'

local function override_highlight(name)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok then
    return
  end

  local current = type(hl) == 'table' and vim.deepcopy(hl) or {}
  current.fg = highlight_color
  current.bg = 'NONE'
  current.ctermbg = 'NONE'
  current.default = nil

  vim.api.nvim_set_hl(0, name, current)
end

local function apply_status_highlights()
  for _, name in ipairs(highlight_targets) do
    override_highlight(name)
  end
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

local function open_and_close(state)
  local node = state.tree:get_node()
  if not node then
    return
  end
  if node.type == 'directory' then
    state.commands['toggle_node'](state)
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
    filesystem = {
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      window = {
        mappings = {
          ['h'] = 'close_node',
          ['l'] = 'open',
          ['<CR>'] = open_and_close,
          ['J'] = 'move_node',
          ['K'] = 'move_node',
          ['<Space>'] = 'toggle_node',
          ['-'] = 'navigate_up',
          ['.'] = 'toggle_hidden',
          ['Y'] = copy_node_path,
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

return M
