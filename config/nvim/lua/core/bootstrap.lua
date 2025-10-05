local M = {}

function M.setup()
  -- 基本設定や他モジュールよりも先に必要な初期化処理をまとめる
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  vim.g.use_legacy_plugin_manager = 0
  vim.g.use_coc = 0
  vim.g.airline_theme = 'dark_minimal'
  vim.g.ayucolor = 'dark'

  local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable',
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
end

return M
