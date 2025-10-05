local M = {}

function M.setup()
  vim.g.memolist_memo_suffix = 'md'
  vim.g.memolist_path = vim.g.memolist_path or vim.fn.expand('~/memo/Inbox')
  vim.g.memolist_memo_date = '%Y/%m/%d %H:%M:%S'
  vim.g.memolist_filename_date = '%Y%m%d-'
  vim.g.memolist_template_dir_path = vim.fn.expand('~/memo/Templates/default.md')
  vim.g.memolist_prompt_tags = 1
  vim.g.memolist_prompt_categories = 0
  vim.g.memolist_fzf = 1

  local map = vim.keymap.set
  local command = vim.api.nvim_create_user_command

  map('n', '<Leader>mn', '<cmd>MemoNew<CR>', { silent = true, desc = 'Memo new' })
  map('n', '<Leader>ml', '<cmd>MemoListFzf<CR>', { silent = true, desc = 'Memo list' })
  map('n', '<Leader>mg', '<cmd>MemoGrepFzf<CR>', { silent = true, desc = 'Memo grep' })
  map('n', '<Leader>md', '<cmd>MemoDaily<CR>', { silent = true, desc = 'Memo daily' })
  map('n', '<Leader>mi', '<cmd>MemoNew<CR>', { silent = true, desc = 'Memo new (alias)' })

  command('MemoDaily', function()
    local path = vim.fn.system('memo daily')
    path = path and vim.trim(path)
    if path and path ~= '' then
      vim.cmd('edit ' .. vim.fn.fnameescape(path))
    end
  end, {})
end

return M
