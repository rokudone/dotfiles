# Git キーマップ再編方針

## 背景
- `[git]` という専用リーダー (実体は `<leader>g`) を経由する 2 段階構成は維持前提だが、2 打目の文字が機能名と結び付かず想起しづらい。
- 特に blame 系コマンドが `l`/`L` に割り当てられており、動詞の頭文字と一致しないため検索・想起に時間がかかっている。
- Diffview／Gitsigns／Gitlinker／fzf-lua が混在しており、用途別にまとまっていないためドキュメントの一覧も視認しづらい。

## 基本方針
1. Git 系ショートカットは引き続き `[git]` (=`<leader>g`) を共通プレフィックスとし、2 段階操作をキープする。
2. 2 打目は機能の頭文字 (b = blame, d = diff, h = history, o = open など) を割り当て、動詞とキーの対応を明示する。
3. 亜種や派生操作は大文字または 3 打目で差別化し、同一カテゴリの中で完結させる。
4. ドキュメント上も「カテゴリ → アクション」の順に並べ替え、視覚的にグルーピングする。

## キーマップ改定案
| カテゴリ | 操作内容 | 現状のキー | 改定案 | 備考 |
| --- | --- | --- | --- | --- |
| Diffview | HEAD との差分ビュー | `[git]w` | `[git]w` | `w = worktree diff`。適用済み。
| Diffview | リポジトリ全体の履歴 | `[git]L` | `[git]H` | `H = history (repo)`。`DiffviewFileHistory` を起動。
| Diffview | カーソルファイルの履歴 | `[git]h` | `[git]h` | `%` 対象に固定。`h = history`。 |

| Blame (自作) | ライブ blame パネル切替 | `[git]I` | `[git]I` | `I = interactive blame`。適用済み。
| Gitlinker | 現在行をブラウザで開く | `[git]O` (Normal) | `[git]O` | `O = open`。適用済み。
| Gitlinker | 選択範囲をブラウザで開く | `[git]O` (Visual) | `[git]O` | Visual でも同キー。
| fzf-lua | ブランチ一覧 | `[git]b` | `[git]b` | `b = branches`。`[git]` プレフィックスで完結。
| fzf-lua | Git status | `<leader>gs` | `[git]s` | `s = status`。Neogit fallback 付き。
| fzf-lua | コミット履歴 (ログビュー) | — | `[git]l` | fzf-lua の `git_commits` を起動。

## 移行手順
1. `config/nvim/lua/core/keymaps.lua` と各 Git プラグインのモジュールで `[git]` グループ配下の 2 打目を上記対応で差し替える。
2. `config/nvim/docs/git-workflow.md` の表を「カテゴリ別 + 新キーマップ順」に並べ替え、旧キーの記述を削除する。
3. Neovim を再読み込みし、各マップが衝突していないか `:Telescope keymaps` / `:map <leader>g` で確認する。
4. 慣れるまでは which-key やヘルプに新しいグループ名を出せるよう、`<leader>g` のグループ見出しを付与する (必要であれば which-key 設定を追加)。

## 未決事項
- Diffview 自体を維持するかは要観察。不要と判断した場合はプラグインごと削除し、上記の `<leader>gd/gp/gf/gH` を無効にする。
- `<leader>gr` (旧 `<leader>gb`) への移行後、ブランチ操作をさらに集約したい場合は fzf-lua 側のアクション (checkout, delete) もプリセット化する。
