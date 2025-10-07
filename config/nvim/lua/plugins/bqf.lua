local M = {}

function M.setup()
  local ok, bqf = pcall(require, 'bqf')
  if not ok then
    vim.notify('nvim-bqf is not available', vim.log.levels.WARN, { title = 'plugins.bqf' })
    return
  end

  bqf.setup({
    auto_enable = true,
    preview = {
      auto_preview = true,
      win_height = 15,
      win_vheight = 15,
      delay_syntax = 50,
      show_title = false,
    },
    func_map = {
      open = '',
      openc = 'o',
      openv = 'v',
      open_split = 's',
      ptoggleauto = 'P',
    },
  })
end

return M
