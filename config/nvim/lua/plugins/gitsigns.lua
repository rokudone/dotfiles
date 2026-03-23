local M = {}

local function notify_missing()
  vim.notify('gitsigns.nvim を読み込めませんでした', vim.log.levels.WARN, { title = 'Gitsigns' })
end

function M.setup()
  local ok, gitsigns = pcall(require, 'gitsigns')
  if not ok then
    notify_missing()
    return
  end

  gitsigns.setup({
    current_line_blame = false,
    current_line_blame_opts = {
      virt_text_pos = 'eol',
    },
    preview_config = {
      border = 'single',
    },
    signcolumn = true,
    signs = {
      add = { text = '▎', hl = 'GitSignsAdd' },
      change = { text = '▎', hl = 'GitSignsChange' },
      delete = { text = '▁', hl = 'GitSignsDelete' },
      topdelete = { text = '▔', hl = 'GitSignsDelete' },
      changedelete = { text = '~', hl = 'GitSignsChange' },
    },
    signs_staged = {
      add = { text = '▎', hl = 'GitSignsStagedAdd' },
      change = { text = '▎', hl = 'GitSignsStagedChange' },
      delete = { text = '▁', hl = 'GitSignsStagedDelete' },
      topdelete = { text = '▔', hl = 'GitSignsStagedDelete' },
      changedelete = { text = '~', hl = 'GitSignsStagedChange' },
    },
    on_attach = function(bufnr)
      local fn = vim.fn

      local function visual_range()
        local current = fn.line('.')
        local other = fn.line('v')
        if current > other then
          current, other = other, current
        end
        return current, other
      end

      local function with_visual_range(handler)
        return function()
          local first, last = visual_range()
          handler({ first, last })
        end
      end

      local function opts(desc)
        return { silent = true, desc = desc, buffer = bufnr }
      end


      local map = vim.keymap.set
      map('n', '[Git]p', gitsigns.preview_hunk, opts('Hunk をプレビュー'))
      map('n', '[Git]a', gitsigns.stage_hunk, opts('Hunk をステージ'))
      map('x', '[Git]a', with_visual_range(gitsigns.stage_hunk), opts('選択範囲をステージ'))
      map('n', '[Git]r', gitsigns.reset_hunk, opts('Hunk をリセット'))
      map('x', '[Git]r', with_visual_range(gitsigns.reset_hunk), opts('選択範囲をリセット'))
      map('n', '[Git]u', gitsigns.undo_stage_hunk, opts('Hunk のステージを取り消し'))
      map('x', '[Git]u', gitsigns.undo_stage_hunk, opts('選択範囲のステージを取り消し'))
      map('n', '[Git]i', function()
        gitsigns.blame_line({ full = true })
      end, opts('現在行の blame 詳細を表示'))
      map('n', ']g', function() gitsigns.next_hunk() vim.cmd('normal! zz') end, opts('次の Hunk'))
      map('n', '[g', function() gitsigns.prev_hunk() vim.cmd('normal! zz') end, opts('前の Hunk'))
    end,
  })
end

return M
