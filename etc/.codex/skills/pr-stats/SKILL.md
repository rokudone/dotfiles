---
name: pr-stats
description: 対象期間・ユーザー・リポジトリを指定して、PRベースのコード行数統計を出す。「PR統計」「行数計測」「生産性計測」と言った時に使用
argument-hint: "[author] [from] [to]"
---

# PR Stats

PRベースでコード行数を計測する。GitHub API からファイル単位の additions を取得し、自動生成ファイルを除外、カテゴリ別に集計する。

## 入力

引数またはユーザーへの確認で以下を取得する:

- **author**: GitHub ユーザー名(複数可)
- **from**: 開始日 (YYYY-MM-DD)
- **to**: 終了日 (YYYY-MM-DD)
- **repo**: リポジトリ (owner/repo形式、デフォルトは現在のリポジトリ)

## 手順

### 1. PR一覧の取得

```bash
gh pr list --state all --author {author} --limit 200 \
  --json number,state,createdAt,mergedAt,title,baseRefName,additions \
  --repo {repo}
```

jq でフィルタ:
- state が OPEN または MERGED のみ(CLOSED は除外)
- createdAt または mergedAt が対象期間内
- headRefName が release-feature/ で始まるPRは除外(release-feature → release/main のマージPRは他人の変更を含むため)

結果を /tmp/pr-stats-{author}.json にキャッシュする。

### 2. 外れ値チェック

additions が 10,000行 を超えるPRをユーザーに提示し、除外するか確認する。
典型的な除外対象:
- release-feature 全体を含むPR
- 定期リリースPR
- storybook-static や node_modules を含むPR

除外PRリストを /tmp/pr-stats-{author}-blacklist.txt に保存する。

### 3. ファイル別 additions の取得

各PRについて gh api でファイル一覧を取得:

```bash
gh api "repos/{repo}/pulls/{number}/files" --paginate
```

ファイルごとの additions を以下のルールで分類する:

#### 除外(カウントしない)
- node_modules/, package-lock
- generated/, storybook-static/
- .agent/, .claude/, .vscode/, .next/
- design-tokens, openapi.yaml
- .md, .csv, .xml, .json 拡張子

#### カテゴリ分類(除外されなかったファイル)
- **テスト**: `_spec.rb`, `.test.`, `.spec.`, `.stories.` を含むファイル
- **ドキュメント**: `docs/` 配下のファイル
- **実装**: 上記いずれにも該当しないファイル

### 4. 集計・出力

以下の形式で出力する:

```
| 著者 | PR数 | 計 | 実装 | テスト | ドキュメント |
```

スクリプト: `scripts/collect-pr-stats.sh` を使用する。
