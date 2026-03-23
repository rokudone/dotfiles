local M = {}

function M.setup()
  local ok, octo = pcall(require, 'octo')
  if not ok then
    vim.notify('octo.nvim を読み込めませんでした', vim.log.levels.WARN, { title = 'Octo' })
    return
  end

  octo.setup({
    picker = 'fzf-lua',
    suppress_missing_scope = {
      projects_v2 = true,
    },
    mappings = {
      review_diff = {
        add_review_comment = { lhs = '[Git]c', desc = 'コメントを追加' },
        add_review_suggestion = { lhs = '[Git]s', desc = '修正提案を追加' },
        submit_review = { lhs = '[Git]q', desc = 'レビューを送信 (quit)' },
        discard_review = { lhs = '[Git]d', desc = 'レビューを破棄 (discard)' },
      },
      pull_request = {
        add_comment = { lhs = '[Git]c', desc = 'コメントを追加' },
        review_resume = { lhs = '[Git]R', desc = 'レビューを再開' },
      },
    },
  })

end

return M
