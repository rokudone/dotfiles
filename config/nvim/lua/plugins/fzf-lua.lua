local M = {}

local fn = vim.fn
local api = vim.api
local map = vim.keymap.set
local cmd = api.nvim_create_user_command

-- 共通のpathを管理
local function ensure_paths()
  local dotfiles = vim.g.dotfiles_path
  if not dotfiles or dotfiles == '' then
    local myvimrc = vim.env.MYVIMRC or fn.stdpath('config') .. '/init.lua'
    local config_dir = fn.fnamemodify(myvimrc, ':p:h')
    local output = fn.systemlist('cd ' .. fn.shellescape(config_dir) .. ' && git rev-parse --show-toplevel')
    if vim.v.shell_error == 0 and output and #output > 0 then
      dotfiles = output[1]
    else
      dotfiles = config_dir
    end
  end
  vim.g.dotfiles_path = dotfiles

  if not vim.g.claude_code_config_path or vim.g.claude_code_config_path == '' then
    vim.g.claude_code_config_path = fn.expand('~/projects/claude-code-config')
  end
end

local function filename_first_weighted_to(filepath, _, ctx)
  local filename = (ctx and ctx.path and ctx.path.tail and ctx.path.tail(filepath))
    or filepath:match('([^/]+)$')
    or filepath
  -- 列1-3: ファイル名を重複させてスコアを上げる
  -- 列4  : フルパス（表示とパス検索用）
  return string.format('%s\t%s\t%s\t%s', filename, filename, filename, filepath)
end

local function filename_first_weighted_from(entry)
  -- fzf-luaのバージョン差分でentryがtableになり得るため防御的に処理
  if type(entry) == 'table' then
    entry = entry[1] or entry.text or entry.fzf or table.concat(entry, '\t')
  end
  if type(entry) ~= 'string' then
    return entry
  end

  -- タブ区切りの最後の要素を優先してパスとして解釈する
  local parts = vim.split(entry, '\t', { plain = true, trimempty = true })
  if #parts == 0 then
    return entry
  end

  local function is_abs(path)
    return path:sub(1, 1) == '/' or path:match('^%a:[/\\]') ~= nil
  end

  local candidate = parts[#parts]
  if is_abs(candidate) then
    return candidate
  end

  for _, p in ipairs(parts) do
    if is_abs(p) then
      return p
    end
  end

  return candidate
end


-- filename_first フォーマッタ: 表示はASCIIスペースでも、復元時に正しいパスへ変換する
local function patch_filename_first_formatter()
  local ok_defaults, defaults = pcall(require, 'fzf-lua.defaults')
  local ok_utils, utils = pcall(require, 'fzf-lua.utils')
  local ok_path, path = pcall(require, 'fzf-lua.path')
  if not (ok_defaults and ok_utils and ok_path) then
    return
  end

  local formatter = defaults
  formatter = formatter and formatter.defaults and formatter.defaults.formatters
  formatter = formatter and formatter.path and formatter.path.filename_first
  if not formatter or type(formatter) ~= 'table' then
    return
  end

  formatter.from = function(entry, _)
    local delimiter = utils.nbsp or ' '
    local sanitized = entry:gsub('\xc2\xa0     .-$', '')
    if delimiter ~= '\xc2\xa0' and delimiter ~= '' then
      local suffix = delimiter .. string.rep(' ', 5)
      sanitized = sanitized:gsub(vim.pesc(suffix) .. '.-$', '')
    end

    local before_tab, after_tab = sanitized:match("^(.*)\t(.+)$")
    if not after_tab then
      return sanitized
    end

    local prefix = ''
    local filename = before_tab
    if delimiter ~= '' then
      local search_from = 1
      local last_idx
      while true do
        local s, e = before_tab:find(delimiter, search_from, true)
        if not s then
          break
        end
        last_idx = e
        search_from = e + 1
      end
      if last_idx then
        prefix = before_tab:sub(1, last_idx)
        filename = before_tab:sub(last_idx + 1)
        if filename == '' then
          prefix = ''
          filename = before_tab
        end
      end
    end

    local parent
    if utils.__IS_WINDOWS and path.is_absolute(after_tab) then
      local drive = after_tab:sub(1, 2)
      local remainder = #after_tab > 2 and after_tab:sub(3):match("^[^:]+") or ''
      parent = drive .. remainder
    else
      parent = after_tab:match("^[^:]+")
    end

    if not parent or parent == '' then
      return sanitized
    end

    local rest = after_tab:sub(#parent + 1)
    local fullpath = path.join({ parent, filename })
    return prefix .. fullpath .. rest
  end
end

local function setup_fzf_lua()
  local fzf = require('fzf-lua')
  patch_filename_first_formatter()

  fzf.setup({
    -- NBSPを通常スペースに置換し、パス復元は独自パッチで保証する
    nbsp = ' ',
    -- グローバル設定
    global_resume = true,
    global_resume_query = true,

    -- Window設定（float window）
    winopts = {
      height = 0.85,
      width = 0.85,
      row = 0.35,
      col = 0.50,
      border = 'rounded',  -- ambiwidth=doubleに対応
      fullscreen = false,
      preview = {
        layout = 'horizontal',
        horizontal = 'right:50%',
        border = 'rounded',  -- プレビューも同じボーダー
        scrollbar = false,
        wrap = 'wrap',  -- 折り返しあり（日本語対応）
      },
    },

    -- キーバインド
    keymap = {
      builtin = {
        ["<C-d>"] = "preview-page-down",
        ["<C-u>"] = "preview-page-up",
        ["<C-j>"] = "down",
        ["<C-k>"] = "up",
      },
      fzf = {
        ["ctrl-a"] = "select-all",
        ["ctrl-y"] = "select-all",
        ["ctrl-d"] = "deselect-all",
        ["ctrl-q"] = "select-all+accept",
        -- fzfネイティブアクションのみ使用
      },
    },

    -- アクション（ファイル操作はここで定義）
    actions = {
      files = {
        ["default"] = fzf.actions.file_edit,
        ["ctrl-s"] = fzf.actions.file_split,      -- 横分割
        ["ctrl-v"] = fzf.actions.file_vsplit,     -- 縦分割
        ["ctrl-t"] = fzf.actions.file_tabedit,    -- タブで開く
        ["ctrl-q"] = fzf.actions.file_sel_to_qf,  -- quickfixに送る
      },
      grep = {
        ["default"] = fzf.actions.file_edit,
        ["ctrl-s"] = fzf.actions.file_split,
        ["ctrl-v"] = fzf.actions.file_vsplit,
        ["ctrl-t"] = fzf.actions.file_tabedit,
        ["ctrl-q"] = fzf.actions.file_sel_to_qf,
      },
      buffers = {
        ["default"] = fzf.actions.buf_edit,
        ["ctrl-s"] = fzf.actions.buf_split,
        ["ctrl-v"] = fzf.actions.buf_vsplit,
        ["ctrl-t"] = fzf.actions.buf_tabedit,
        ["ctrl-d"] = fzf.actions.buf_del,
      },
    },

    -- ファイル検索設定（fdを使用）
    files = {
      prompt = 'Files> ',
      cmd = 'fd --type f --hidden --no-ignore --follow --exclude .git --exclude node_modules --exclude .DS_Store',
      -- `formatter` は文字列指定のみサポートされるため公式名を使用
      formatter = 'path.filename_first',
      _fmt = {
        to = filename_first_weighted_to,
        from = filename_first_weighted_from,
      },
      git_icons = false,  -- 無効化
      file_icons = false, -- アイコン無効化（表示問題の原因になりやすい）
      color_icons = false,
      -- マッチはファイル名を強く優先しつつ、パス検索も残す
      fzf_opts = {
        ['--with-nth'] = '1,4',      -- 表示: ファイル名 + パス
        ['--nth'] = '1,2,3,4',       -- 検索対象: ファイル名(3重) + パス
        ['--tiebreak'] = 'begin,length,index',
      },
    },

    -- grep設定（ripgrepを使用）
    grep = {
      prompt = 'Rg> ',
      cmd = 'rg --color=never --no-heading --with-filename --line-number --column --smart-case --hidden --no-ignore --glob "!.git/*" --glob "!node_modules/*"',
      multiline = 1,  -- シングルライン表示に変更（表示崩れ防止）
      -- Ctrl-gでlive_grepモードと結果フィルタモードを切り替え
      actions = {
        ["ctrl-g"] = { fzf.actions.grep_lgrep },
      },
    },

    -- バッファ
    buffers = {
      prompt = 'Buffers> ',
      sort_mru = true,
      ignore_current_buffer = true,
    },

    -- fzf自体のオプション
    fzf_opts = {
      ['--ansi'] = '',
      ['--info'] = 'inline',
      ['--height'] = '100%',
      ['--layout'] = 'reverse',
      ['--border'] = 'none',
    },

    -- 日本語環境向け設定
    defaults = {
      formatter = 'path.filename_first',  -- ファイル名を前に表示
      file_icons = false,  -- アイコン無効化（表示問題の原因になりやすい）
      git_icons = false,
    },

    -- その他の設定
    lsp = {
      symbols = {
        symbol_style = 1,  -- アイコン表示
      },
    },
  })
end

local function setup_commands()
  local fzf = require('fzf-lua')

  -- Telescopeと互換性のあるコマンド
  cmd('FilesWithQuery', function(opts)
    fzf.files({ query = opts.args })
  end, { nargs = '?', complete = 'file' })

  cmd('Dotfiles', function(opts)
    fzf.files({ cwd = vim.g.dotfiles_path, query = opts.args })
  end, { nargs = '?', complete = 'file' })

  cmd('ClaudeCodeConfig', function(opts)
    fzf.files({ cwd = vim.g.claude_code_config_path, query = opts.args })
  end, { nargs = '?', complete = 'file' })

  cmd('Rg', function(opts)
    if opts.args ~= '' then
      fzf.grep({ search = opts.args })
    else
      fzf.live_grep()
    end
  end, { nargs = '*' })

  cmd('Ag', function(opts)
    if opts.args ~= '' then
      fzf.grep({ search = opts.args })
    else
      fzf.live_grep()
    end
  end, { nargs = '*' })

  cmd('Jump', function()
    fzf.jumps()
  end, {})
end

local function setup_keymaps()
  local fzf = require('fzf-lua')

  -- ファイル検索
  map('n', '<C-p>', fzf.files, { silent = true, desc = 'fzf-lua files' })
  map('n', '<Leader>f', function()
    fzf.files({ query = fn.expand('%:t:r') })
  end, { silent = true, desc = 'fzf-lua files (buffer name)' })
  map('n', '<Leader>F', function()
    fzf.files({ query = fn.expand('<cword>') })
  end, { silent = true, desc = 'fzf-lua files (word)' })

  -- dotfilesとclaude-code-config
  map('n', '<Leader>ee', function()
    fzf.files({ cwd = vim.g.dotfiles_path })
  end, { silent = true, desc = 'fzf-lua dotfiles' })
  map('n', '<Leader>ec', function()
    fzf.files({ cwd = vim.g.claude_code_config_path })
  end, { silent = true, desc = 'fzf-lua Claude config' })

  -- バッファ
  map('n', '<Leader>b', fzf.buffers, { silent = true, desc = 'fzf-lua buffers' })

  -- マーク
  map('n', '<Leader>m', fzf.marks, { silent = true, desc = 'fzf-lua marks' })

  -- grep検索
  map('n', '<Leader>a', function()
    vim.ui.input({ prompt = 'Rg> ' }, function(input)
      if input and input ~= '' then
        fzf.grep({ search = input })
      else
        fzf.live_grep()
      end
    end)
  end, { silent = true, desc = 'fzf-lua live grep' })

  map('n', '<Leader>A', function()
    local word = fn.expand('<cword>')
    fzf.grep({ search = word })
  end, { silent = true, desc = 'fzf-lua grep (word)' })

  -- バッファ内検索
  map('n', '<Leader>/', fzf.blines, { silent = true, desc = 'fzf-lua buffer search' })
  map('n', '<Leader>?', fzf.grep_curbuf, { silent = true, desc = 'fzf-lua search current buffer' })

  -- ヒストリー
  map('n', '<Leader>h', fzf.search_history, { silent = true, desc = 'fzf-lua search history' })
  map('n', '<Leader>H', fzf.help_tags, { silent = true, desc = 'fzf-lua help tags' })

  -- ジャンプリスト
  map('n', '<Leader>J', fzf.jumps, { silent = true, desc = 'fzf-lua jumplist' })

  -- LSP関連（オプショナル）
  -- Neovim 標準の LSP キーマップを上書きしない
  map('n', '<Leader>gr', fzf.lsp_references, { silent = true, desc = 'fzf-lua LSP references' })
  map('n', '<Leader>gd', fzf.lsp_definitions, { silent = true, desc = 'fzf-lua LSP definitions' })
  map('n', '<Leader>D', fzf.lsp_document_symbols, { silent = true, desc = 'fzf-lua document symbols' })
  map('n', '<Leader>W', fzf.lsp_workspace_symbols, { silent = true, desc = 'fzf-lua workspace symbols' })
end

function M.setup()
  ensure_paths()

  local ok, fzf_lua = pcall(require, 'fzf-lua')
  if not ok then
    vim.notify('fzf-lua is not installed', vim.log.levels.WARN, { title = 'plugins.fzf-lua' })
    return
  end

  setup_fzf_lua()
  setup_commands()
  setup_keymaps()
end

return M
