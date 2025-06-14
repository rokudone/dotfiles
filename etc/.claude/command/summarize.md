# 会話を要約してプロンプトにする（テンプレート化）

この作業を再利用可能テンプレートに整理：
出力形式：
markdown# {作業名}テンプレート
## 手順
1. {処理1} - `{コマンド}`
2. {処理2} - `{コマンド}`

## 変数
- `{VAR}`: 説明

## 並行実行対応
- 識別子: `$(date +%Y%m%d_%H%M%S)_$$`
- 競合回避: {方法}
処理パターン・コマンド・判断基準・エラー対処を含める。
即座に他セッションで使用可能な形式で出力。

## 使用例

```bash
# 各コマンド実行
claude-code --prompt "$(cat doc-update.txt)"
claude-code --prompt "$(cat git-review.txt)" 
claude-code --prompt "$(cat template.txt)"

# セッションID生成
export UNIQUE_ID="$(date +%Y%m%d_%H%M%S)_$$"
