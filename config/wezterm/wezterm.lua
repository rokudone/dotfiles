local wezterm = require 'wezterm'
local config = {}

-- open-uriイベントハンドラー（ファイルパスを開く）
wezterm.on('open-uri', function(window, pane, uri)
  wezterm.log_info('Opening URI: ' .. uri)
  
  -- ファイル用
  if uri:find('^file:') then
    local path = uri:gsub('^file://', '')
    -- macOSはopen、Linuxはxdg-open
    local cmd = 'open'  -- macOS用
    os.execute(cmd .. ' "' .. path .. '"')
    return false  -- weztermのデフォルト処理をスキップ
  end
end)

-- 基本設定
config.automatically_reload_config = true
config.term = "xterm-256color"
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- フォント設定
config.font = wezterm.font_with_fallback({"S2GUniFont Nerd Font"})
config.font_size = 24.0


-- フォントレンダリング設定（WezTermの正しい設定）
-- config.freetype_load_target = "Light"  -- より滑らかなレンダリング
-- config.freetype_render_target = "HorizontalLcd"  -- LCDサブピクセルレンダリング
-- config.freetype_load_flags = "NO_HINTING"  -- ヒンティング無効

-- 日本語文字幅の修正
-- config.treat_east_asian_ambiguous_width_as_wide = false  -- 曖昧な幅の文字を全角として扱わない
config.use_cap_height_to_scale_fallback_fonts = true

-- フォントオフセット (WezTermでは line_height で調整)
config.line_height = 1.4
config.cell_width = 1.0

-- カラースキーム (Ayu Dark風)
config.colors = {
  -- 背景と前景色
  background = '#0A0D13',
  foreground = '#B2B1AD',

  -- カーソル
  cursor_bg = '#F6CD76',
  cursor_fg = '#1E222A',

  -- 通常色
  ansi = {
    '#02050c',  -- black
    '#e0787a',  -- red
    '#c6d863',  -- green
    '#f3b765',  -- yellow
    '#75bff9',  -- blue
    '#fceea3',  -- magenta
    '#a7e3cc',  -- cyan
    '#c7c7c7',  -- white
  },

  -- 明るい色
  brights = {
    '#c7c7c7',  -- black
    '#ff3333',  -- red
    '#c2d94c',  -- green
    '#e7c547',  -- yellow
    '#59c2ff',  -- blue
    '#b77ee0',  -- magenta
    '#5ccfe6',  -- cyan
    '#ffffff',  -- white
  },

  -- 選択範囲
  selection_bg = '#171E29',
  selection_fg = '#2E323B',
}

-- ウィンドウ設定
config.initial_cols = 80
config.initial_rows = 30
config.window_decorations = "RESIZE"  -- "TITLE | RESIZE" for full decorations
config.window_background_opacity = 1.0

-- スクロールバック
config.scrollback_lines = 10000

-- カーソル設定
config.default_cursor_style = 'BlinkingBlock'

-- 追加のレンダリング設定
config.bold_brightens_ansi_colors = true  -- Alacrittyの draw_bold_text_with_bright_colors に相当
config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"  -- 文字の描画改善

-- キーバインド
config.keys = {
  -- フォントサイズ調整
  {key = '0', mods = 'CMD', action = wezterm.action.ResetFontSize},
  {key = '=', mods = 'CMD', action = wezterm.action.IncreaseFontSize},
  {key = '-', mods = 'CMD', action = wezterm.action.DecreaseFontSize},

  -- コピー＆ペースト
  {key = 'c', mods = 'CMD', action = wezterm.action.CopyTo 'Clipboard'},
  {key = 'v', mods = 'CMD', action = wezterm.action.PasteFrom 'Clipboard'},

  -- タブ操作
  {key = 'Tab', mods = 'CTRL', action = wezterm.action.ActivateTabRelative(1)},
  {key = 'Tab', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1)},

  -- 新規インスタンス
  {key = 'n', mods = 'CMD', action = wezterm.action.SpawnWindow},

  -- 終了
  {key = 'q', mods = 'CMD', action = wezterm.action.QuitApplication},
  {key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentTab{confirm=false}},

  -- クリア
  {key = 'k', mods = 'CMD', action = wezterm.action.ClearScrollback 'ScrollbackAndViewport'},

  -- Altキーコンビネーション (AlacrittyのAlt+文字をエスケープシーケンスとして送る)
  {key = 'a', mods = 'ALT', action = wezterm.action.SendString '\x1ba'},
  {key = 'b', mods = 'ALT', action = wezterm.action.SendString '\x1bb'},
  {key = 'c', mods = 'ALT', action = wezterm.action.SendString '\x1bc'},
  {key = 'd', mods = 'ALT', action = wezterm.action.SendString '\x1bd'},
  {key = 'e', mods = 'ALT', action = wezterm.action.SendString '\x1be'},
  {key = 'f', mods = 'ALT', action = wezterm.action.SendString '\x1bf'},
  {key = 'g', mods = 'ALT', action = wezterm.action.SendString '\x1bg'},
  {key = 'h', mods = 'ALT', action = wezterm.action.SendString '\x1bh'},
  {key = 'i', mods = 'ALT', action = wezterm.action.SendString '\x1bi'},
  {key = 'j', mods = 'ALT', action = wezterm.action.SendString '\x1bj'},
  {key = 'k', mods = 'ALT', action = wezterm.action.SendString '\x1bk'},
  {key = 'l', mods = 'ALT', action = wezterm.action.SendString '\x1bl'},
  {key = 'm', mods = 'ALT', action = wezterm.action.SendString '\x1bm'},
  {key = 'n', mods = 'ALT', action = wezterm.action.SendString '\x1bn'},
  {key = 'o', mods = 'ALT', action = wezterm.action.SendString '\x1bo'},
  {key = 'p', mods = 'ALT', action = wezterm.action.SendString '\x1bp'},
  {key = 'q', mods = 'ALT', action = wezterm.action.SendString '\x1bq'},
  {key = 'r', mods = 'ALT', action = wezterm.action.SendString '\x1br'},
  {key = 's', mods = 'ALT', action = wezterm.action.SendString '\x1bs'},
  {key = 't', mods = 'ALT', action = wezterm.action.SendString '\x1bt'},
  {key = 'u', mods = 'ALT', action = wezterm.action.SendString '\x1bu'},
  {key = 'v', mods = 'ALT', action = wezterm.action.SendString '\x1bv'},
  {key = 'w', mods = 'ALT', action = wezterm.action.SendString '\x1bw'},
  {key = 'x', mods = 'ALT', action = wezterm.action.SendString '\x1bx'},
  {key = 'y', mods = 'ALT', action = wezterm.action.SendString '\x1by'},
  {key = 'z', mods = 'ALT', action = wezterm.action.SendString '\x1bz'},
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = wezterm.action.SendString('\n'),
  },
}

-- マウス設定
config.hide_mouse_cursor_when_typing = true

-- その他の設定
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false

-- タブバーの色設定
config.colors.tab_bar = {
  background = '#0A0D13',
  active_tab = {
    bg_color = '#2c2e34',
    fg_color = '#B2B1AD',
  },
  inactive_tab = {
    bg_color = '#1A1E29',
    fg_color = '#7f8490',
  },
  inactive_tab_hover = {
    bg_color = '#2c2e34',
    fg_color = '#B2B1AD',
  },
}

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- ファイルパス用のルールを追加
table.insert(config.hyperlink_rules, {
  regex = [[\bfile://\S*\b]],
  format = '$0',
})

-- 相対パス用
table.insert(config.hyperlink_rules, {
  regex = [[\b[\w\./\-_]+\.\w+\b]],
  format = 'file://$0',
})

-- macOS固有の設定（必要に応じて）
if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin" then
  -- macOSのフォントレンダリング
  config.front_end = "WebGpu"  -- より良いレンダリング
  config.webgpu_power_preference = "HighPerformance"

  -- macOS固有のアンチエイリアス設定
  config.font_rasterizer = "FreeType"  -- または "CoreText"
  config.font_shaper = "Harfbuzz"  -- より良い文字形状処理
end

return config
