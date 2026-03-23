local M = {}

local function notify_missing(module)
  vim.notify(module .. ' を読み込めませんでした', vim.log.levels.WARN, { title = 'Gitlinker' })
end

local function set_keymaps(gitlinker)
  local map = vim.keymap.set

  local function open_in_browser(mode)
    local ok_actions, actions = pcall(require, 'gitlinker.actions')
    if not ok_actions then
      notify_missing('gitlinker.actions')
      return
    end
    gitlinker.get_buf_range_url(mode, { action_callback = actions.open_in_browser })
  end

  map('n', '[Git]l', function()
    open_in_browser('n')
  end, { silent = true, desc = 'GitHub で現在行を開く' })

  map('v', '[Git]l', function()
    open_in_browser('v')
  end, { silent = true, desc = 'GitHub で選択範囲を開く' })
end

function M.setup()
  local ok, gitlinker = pcall(require, 'gitlinker')
  if not ok then
    notify_missing('gitlinker')
    return
  end

  gitlinker.setup({
    mappings = nil,
    router = {
      browse = {
        { '^github%.com', 'default' },
        { '^gitlab%.com', 'default' },
        { '^bitbucket%.org', 'default' },
      },
    },
  })

  set_keymaps(gitlinker)
end

return M
