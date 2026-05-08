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
    reviews = {
      auto_show_threads = false,
    },
    mappings = {
      review_diff = {
        add_review_comment = { lhs = '<leader>gc', desc = 'コメントを追加' },
        add_review_suggestion = { lhs = '<leader>gs', desc = '修正提案を追加' },
        submit_review = { lhs = '<leader>gq', desc = 'レビューを送信 (quit)' },
        discard_review = { lhs = '<leader>gd', desc = 'レビューを破棄 (discard)' },
        toggle_viewed = { lhs = '<leader>gv', desc = 'Viewed をトグル' },
      },
      file_panel = {
        toggle_viewed = { lhs = 'v', desc = 'Viewed をトグル' },
      },
      review_thread = {
        delete_comment = { lhs = '<leader>gx', desc = 'コメントを削除' },
      },
      pull_request = {
        add_comment = { lhs = '<leader>gc', desc = 'コメントを追加' },
        delete_comment = { lhs = '<leader>gx', desc = 'コメントを削除' },
        review_resume = { lhs = '<leader>gR', desc = 'レビューを再開' },
      },
    },
  })

end

return M
