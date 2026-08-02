---
name: codex-open-md
description: Codex から Markdown ファイル（.md）を macOS の open で開くときに使用する。Codex の sandbox 内では open が LaunchServices / GUI セッション分離で失敗することがあるため、Markdown レポート、レビュー report.md、description.md、manual-test.md などを開く依頼では sandbox 外（require_escalated）で open を実行する。
---

# Codex で Markdown を開く

## 原則

Codex で Markdown ファイルを開くときは、通常 sandbox 内で `open` を実行しない。

macOS の `open` は LaunchServices と GUI セッションに依存するため、Codex の sandbox 内から実行すると、ファイルやアプリに問題がなくても失敗することがある。

## 実行手順

1. 対象が Markdown ファイルであることを確認する。対象例は `report.md`、`description.md`、`manual-test.md`、任意の `.md` ファイル。
2. `functions.exec_command` で `sandbox_permissions: "require_escalated"` を付けて実行する。
3. コマンドは単純に `open <対象ファイル>` を使う。プロジェクトに Markdown を開く専用スクリプトがある場合は、そのスクリプトを sandbox 外で実行してよい。
4. approval の説明では、GUI / LaunchServices へ到達するために sandbox 外で開くことを明記する。

例:

```json
{
  "cmd": "open /absolute/path/to/report.md",
  "sandbox_permissions": "require_escalated",
  "justification": "Markdown ファイルを macOS の open で開くため、sandbox 外で実行してもよろしいですか。"
}
```

プロジェクトの `open-md` スクリプトを使う場合も同じ。

```json
{
  "cmd": "bash /path/to/open-md/scripts/open.sh /absolute/path/to/report.md",
  "sandbox_permissions": "require_escalated",
  "justification": "Markdown ファイルを macOS の open で開くため、sandbox 外で実行してもよろしいですか。"
}
```

## 失敗時の扱い

`sandbox` 内で `open` が失敗しても、「開けるアプリがない」と断定しない。

まず次のように扱う。

- 事実: `open` が LaunchServices 経由で失敗した。
- 推定: sandbox / GUI セッション分離の影響の可能性がある。
- 次の行動: sandbox 外で同じ `open` を再実行する。

`sandbox` 外でも失敗した場合だけ、ファイルパス、既定アプリ、アプリ名指定、LaunchServices の状態を追加で確認する。

## 禁止

- Markdown を開く前に、既定アプリを探しに行かない。
- sandbox 内の失敗だけで「アプリがない」と説明しない。
- ユーザーが求めていない原因調査を勝手に広げない。
