local M = {}

local function notify_failure(err)
  if vim.notify then
    vim.notify('ayu colorscheme を読み込めませんでした: ' .. tostring(err), vim.log.levels.WARN, {
      title = 'plugins.ayu',
    })
  end
end

function M.setup()
  local ok, ayu = pcall(require, 'ayu')
  if ok and type(ayu.setup) == 'function' then
    ayu.setup({
      mirage = false,
    })
  end

  local success, err = pcall(vim.cmd, 'colorscheme ayu')
  if not success then
    notify_failure(err)
  end
end

return M
