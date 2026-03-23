local M = {}

local function notify_missing()
  vim.notify('diffview.nvim を読み込めませんでした', vim.log.levels.WARN, { title = 'Diffview' })
end

local function pick_commit(prompt_title, callback)
  local ok_fzf, fzf = pcall(require, 'fzf-lua')
  if not ok_fzf then
    vim.notify('fzf-lua が必要です', vim.log.levels.WARN, { title = 'Diffview' })
    return
  end

  fzf.git_commits({
    prompt = prompt_title .. '> ',
    actions = {
      ['default'] = function(selected)
        if not selected or #selected == 0 then return end
        local hash = selected[1]:match('^%s*(%x+)')
        if hash then
          callback(hash)
        end
      end,
    },
  })
end


local function diffview_from_commit()
  pick_commit('Base commit', function(base)
    vim.cmd('DiffviewOpen ' .. base)
  end)
end

local function set_keymaps()
  local map = vim.keymap.set
  map('n', '[Git]H', ':DiffviewFileHistory<CR>', { silent = true, desc = 'リポジトリ履歴を開く' })
  map('n', '[Git]z', ':DiffviewFileHistory %<CR>', { silent = true, desc = '現在ファイルの履歴を開く' })
  map('n', '[Git]h', diffview_from_commit, { silent = true, desc = 'コミットからHEADまでのdiffを開く' })
end

function M.setup()
  local ok, diffview = pcall(require, 'diffview')
  if not ok then
    notify_missing()
    return
  end

  local actions = require('diffview.actions')

  local function select_entry_and_focus_editable()
    actions.select_entry()
    vim.schedule(function()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        if not name:match('^diffview://') and name ~= ''
          and vim.api.nvim_get_option_value('buftype', { buf = buf }) == '' then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
    end)
  end

  diffview.setup({
    enhanced_diff_hl = false,
    keymaps = {
      file_panel = {
        { 'n', '<CR>', select_entry_and_focus_editable, { desc = '変更可能なバッファで開く' } },
      },
    },
    view = {
      default = {
        winbar_info = true,
      },
      merge_tool = {
        layout = 'diff3_horizontal',
      },
    },
    hooks = {
      view_opened = function()
        vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#031924' })
        vim.api.nvim_set_hl(0, 'DiffDelete', { fg = '#636A72', bg = '#330202' })
        vim.api.nvim_set_hl(0, 'DiffChange', {})
        vim.api.nvim_set_hl(0, 'DiffText', { bg = '#031924' })
        local group = vim.api.nvim_create_augroup('DiffviewEditable', { clear = true })
        vim.api.nvim_create_autocmd('BufEnter', {
          group = group,
          callback = function()
            local bufnr = vim.api.nvim_get_current_buf()
            local name = vim.api.nvim_buf_get_name(bufnr)
            if not name:match('^diffview://') and name ~= '' then
              vim.bo.modifiable = true
              vim.bo.readonly = false
            end
          end,
        })
        -- Staged changes を自動で fold する
        vim.defer_fn(function()
          local ok, lib = pcall(require, 'diffview.lib')
          if not ok then return end
          local view = lib.get_current_view()
          if not view or not view.panel then return end
          local panel = view.panel
          if panel.components and panel.components.staged then
            local staged = panel.components.staged
            local target = staged.comp or staged
            if target.folded ~= nil then
              target.folded = true
              panel:render()
              panel:redraw()
            end
          end
        end, 100)
      end,
      view_closed = function()
        pcall(vim.api.nvim_del_augroup_by_name, 'DiffviewEditable')
      end,
    },
  })

  set_keymaps()
end

return M
