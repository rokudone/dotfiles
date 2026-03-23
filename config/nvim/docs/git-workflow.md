# Git プラグイン操作早見表

Neogit／Diffview／Gitsigns／Gitlinker を中心に、置き換え後の Git 操作をまとめたメモです。

## プレフィックス

- `<Leader>g` → `[git]` プレフィックス（ノーマルモード／一部ビジュアルモード）

## 主なキーマップ

※ `元?` 列は「元々」=プラグイン既定キーバインド、「⭕️」= dotfiles 独自マッピングを示します。

|   | 元? | キー                 | 機能                                     | プラグイン         | 備考 |
|---| --- | -------------------- | ---------------------------------------- | ------------------ | ---- |
| x | ⭕️  | `[git]c`             | コミット UI を開く                       | Neogit             | `:Neogit commit` を実行。 |
| x | ⭕️  | `[git]s`             | Git status を fzf-lua で開く             | fzf-lua            | fzf-lua 未ロード時は Neogit split。 |
| x | ⭕️  | `[git]w`             | HEAD と現在との差分を表示                | Diffview           | `:DiffviewOpen HEAD`。 |
| x | ⭕️  | `[git]f`             | Git 管理ファイルを fzf-lua で開く        | fzf-lua            | 未追跡ファイルも表示。 |
| x | ⭕️  | `[git]p`             | Hunk のプレビュー                        | Gitsigns           | 浮動ウィンドウで確認。 |
| x | ⭕️  | `[git]a`             | Hunk をステージ                          | Gitsigns           | ビジュアルでは選択範囲。 |
| x | ⭕️  | `[git]u`             | 直前のステージを取り消す                 | Gitsigns           | `undo_stage_hunk` で直前のステージを戻す。 |
| x | ⭕️  | `[git]r`             | Hunk をリセット／ステージ解除            | Gitsigns           | 未ステージならリセット、ステージ済みならアンステージ。ビジュアルでは選択範囲。 |
| x | 元々 | `ga` (Neo-tree)     | 選択ノードをステージ                     | Neo-tree           | ファイルツリー／Git status 両方で利用可。 |
| x | 元々 | `gu` (Neo-tree)     | 選択ノードのステージを解除               | Neo-tree           | ファイルツリー／Git status 両方で利用可。 |
| x | ⭕️  | `]g` / `[g`          | 次／前の Hunk へジャンプ                 | Gitsigns           | 差分ナビゲーション。 |
| x | ⭕️  | `[git]O` (normal)    | 現在行をブラウザで開く                   | Gitlinker          | デフォルトは GitHub URL。 |
| x | ⭕️  | `[git]O` (visual)    | 選択範囲をブラウザで開く                 | Gitlinker          | 選択範囲の permalink。 |
| x | ⭕️  | `[git]l`             | コミット履歴を fzf-lua で開く            | fzf-lua            | `git log` のクイック検索。 |
| x | ⭕️  | `[git]H`             | リポジトリ全体の履歴を Diffview で開く   | Diffview           | `:DiffviewFileHistory`。 |
| x | ⭕️  | `[git]h`             | カーソルファイルの履歴を Diffview で開く | Diffview           | `:DiffviewFileHistory %`。 |
|   | ⭕️  | `[git]i`             | 現在行の blame 詳細を表示                | Gitsigns           | `full = true`。 |
|   | ⭕️  | `[git]I`             | ライブ blame パネルを切り替え            | Git CLI（自作）    | 右分割で同期スクロール。 |
|   | ⭕️  | `[git]b`             | ブランチ一覧を fzf-lua で開く            | fzf-lua            | ブランチ切替ショートカット。 |

## よく使うコマンド

| コマンド                       | 説明 |
| ------------------------------ | ---- |
| `:Neogit`                      | Neogit メイン UI を開く。 |
| `:Neogit commit`               | コミットダイアログを開く。 |
| `:Neogit checkout <branch>`    | ブランチチェックアウト。 |
| `:DiffviewOpen [rev]`          | Diffview を起動し比較する。例: `:DiffviewOpen HEAD~1`。 |
| `:DiffviewFileHistory [path]`  | ファイル／リポジトリ履歴を Diffview で表示。 |
| `:DiffviewClose`               | Diffview を閉じる。 |
| `:Gitsigns blame_line`         | 現在行の blame（フル）を表示。 |
| `:Gitsigns toggle_current_line_blame` | インライン blame のトグル。 |
| `:Gitlinker get_buf_range_url` | 現在範囲の URL を取得（ヤンクのみも可能）。 |

## Tips

- Diffview セッション中は `Ctrl+w` でパネル切替、`g?` でヘルプが表示できます。
- Neogit のバッファでは Magit ライクなキーバインドが有効 (`tab` で展開、`s` でステージ等)。
- Gitlinker は `lua require('gitlinker').get_buf_range_url('n', {action_callback = require('gitlinker.actions').copy_to_clipboard})` のようにコピー専用にも設定可能。
- Gitsigns のインライン blame を常時表示したい場合は `require('gitsigns').toggle_current_line_blame(true)` をマッピングするなど調整してください。
- fzf-lua がロード済みであれば `[git]s` でいつでも Git status リストへアクセスできます。
- 未ステージは緑／青／赤、ステージ済みは黄系 (`GitSignsStaged*`) に変化するため、一目で状態が区別できます。
- `[git]r` は同じキーで、未ステージならリセット、ステージ済みならアンステージとして動作します。
