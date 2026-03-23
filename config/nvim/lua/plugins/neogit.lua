local M = {}

local function notify_missing(name)
  vim.notify(name .. ' を読み込めませんでした', vim.log.levels.WARN, { title = 'Neogit' })
end

local function safe_require(module)
  local ok, value = pcall(require, module)
  if not ok then
    notify_missing(module)
    return nil
  end
  return value
end

local function set_keymaps(neogit)
  local map = vim.keymap.set

  map('n', '[Git]s', function() neogit.open({ kind = 'replace' }) end, { silent = true, desc = 'Neogit ステータス' })
  map('n', '[Git]c', function() vim.cmd('Neogit commit') end, { silent = true, desc = 'Neogit コミット' })
  map('n', '[Git]w', ':DiffviewOpen HEAD<CR>', { silent = true, desc = 'HEAD と現在との差分を表示' })
end

function M.setup()
  local neogit = safe_require('neogit')
  if not neogit then
    return
  end

  neogit.setup({
    integrations = {
      diffview = true,
      telescope = false,
    },
    disable_hint = true,
    use_magit_keybindings = true,
    use_per_project_settings = false,
  })

  set_keymaps(neogit)
end

return M
