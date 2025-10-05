local M = {}

function M.setup()
  vim.g.gitgutter_enabled = 1
  vim.g.gitgutter_map_keys = 0
  vim.g.gitgutter_max_signs = 2000
  vim.g.gitgutter_signs = 1
  vim.g.gitgutter_highlight_linenrs = 0
  vim.g.gitgutter_sign_allow_clobber = 1

  local map = vim.keymap.set
  local opts = { silent = true }

  map('n', ']h', '<Plug>(GitGutterNextHunk)', opts)
  map('n', '[h', '<Plug>(GitGutterPrevHunk)', opts)

  map('n', '[git]p', '<Plug>(GitGutterPreviewHunk)', opts)
  map('n', '[git]a', '<Plug>(GitGutterStageHunk)', opts)
  map('n', '[git]r', '<Plug>(GitGutterUndoHunk)', opts)
  map('n', '[git]t', '<Plug>(GitGutterLineHighlightsToggle)', opts)
end

return M
