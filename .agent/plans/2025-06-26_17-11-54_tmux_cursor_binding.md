# 実装計画: tmuxでCursorエディタを開くキーバインディング

## 実装状態: ✅ 完了 (2025-06-26)

## 概要（日本語）
tmux.confにC-q cとC-q C-cのキーバインディングを追加し、現在いるディレクトリでCursorエディタを開く機能を実装します。

### 技術詳細
- tmuxのキーバインディング機能を使用
- `run-shell`コマンドで外部コマンドを実行
- `#{pane_current_path}`変数で現在のディレクトリパスを取得
- cursorコマンドに現在のパスを渡して起動

### 実装ステップ
1. tmux.confの現在のC-q c、C-q C-cバインディングを確認
2. 既存のバインディング（new-window）をコメントアウト
3. 新しいバインディングを追加：
   - `bind c run-shell 'cursor "#{pane_current_path}"'`
   - `bind C-c run-shell 'cursor "#{pane_current_path}"'`
4. tmux設定をリロードして動作確認

## Overview (English)
Add C-q c and C-q C-c key bindings to tmux.conf to open the Cursor editor in the current directory.

### Technical Details
- Use tmux key binding functionality
- Execute external commands with `run-shell`
- Get current directory path with `#{pane_current_path}` variable
- Launch cursor command with current path parameter

### Implementation Steps
1. Check current C-q c and C-q C-c bindings in tmux.conf
2. Comment out existing bindings (new-window)
3. Add new bindings:
   - `bind c run-shell 'cursor "#{pane_current_path}"'`
   - `bind C-c run-shell 'cursor "#{pane_current_path}"'`
4. Reload tmux configuration and verify functionality