npm i -g @anthropic-ai/claude-code

curl -LsSf https://astral.sh/uv/install.sh | sh

# コードインデックス
ghq get https://github.com/johnhuang316/code-index-mcp.git
cd ~/projects/github.com/johnhuang316/code-index-mcp
uv sync


## 環境変数の設定


### FIGMA

## Figma APIキーの取得方法

# 1. [Figma](https://www.figma.com) にログイン
# 2. 左上のアカウントメニューから「Settings」を選択
# 3. 「設定」を選択
# 4. 「セキュリティ」タブから「個人アクセストークン」セクションに移動
# 5. 「新規アクセストークン」をクリック
# 6. トークン名を入力
# 7. スコープ（権限）を選択：
#    - ファイルのコンテンツを読み取りのみにする（これだけで十分です）
# 8. 「トークンを生成」をクリック
# 9. 生成されたトークンをコピー

### GitHub Personal Access Token

# 1. https://github.com/settings/tokens でトークンを作成
# 2. 必要な権限: `repo`, `read:user`
# 3. 設定ファイルの `<YOUR_GITHUB_TOKEN>` を実際のトークンに置き換え

### データベース接続情報

#### MySQL
# - `MYSQL_URL` を実際の接続文字列に置き換え
# - 形式: `mysql://user:password@localhost:3306/dbname`

#### Elasticsearch
# - `ES_URL` を実際のElasticsearchエンドポイントに置き換え
# - `ES_API_KEY` を実際のAPIキーに置き換え
