---
name: bd-tasks
description: bd（beads）でタスク管理する。.beads/ が初期化されたリポジトリでタスクを積む・依存関係を張る・進捗を管理するとき、「bd でタスク管理」「beads」「bd に積んで」と言われた時に使用。TodoWrite / TaskCreate の代わりに使う
---

# bd-tasks

bd（beads）はリポジトリ内 `.beads/` にデータを持つ CLI の issue トラッカー。タスク1件 = issue 1件。セッションをまたいで永続する。

## 前提

1. `.beads/` が存在するリポジトリでのみ使う。無いリポジトリで必要になったら、`bd init` を実行してよいかユーザーに確認する
2. bd が使えるリポジトリでは、TodoWrite / TaskCreate ではなく bd でタスクを管理する

## 基本循環

1. タスクを作る: `bd create "タイトル"` — 短い ID（例 `bd-a1b2`）が返る。説明を付けるなら `-d "説明"`
2. 着手可能な一覧を見る: `bd ready` — 依存でブロックされているタスクは出ない
3. 着手を宣言する: `bd update <id> --claim` — ready 一覧から外れ、取り合いを防ぐ
4. 閉じる: `bd close <id>` — 閉じる前に、次に読む人（人間・エージェント）向けの結論を note に残す

## 依存関係

1. 「A が終わるまで B は始められない」は blocks リンクで張る。ready 判定に効くのは blocks だけで、他のリンク種は記録用
2. link 系コマンドの正確な構文は初回に `bd link --help` で確認してから使う（学習データに無いツールのため、構文を推測で打たない）

## 記録と検索

1. `bd note <id> "本文"` — 調査結果・学びをタスクに追記する。セッションをまたぐ文脈はここに残す
2. `bd show <id>` — 詳細（説明・note・依存）を見る
3. `bd list` / `bd query` — 一覧・絞り込み。メタフィールドの絞り込みは query では取れないことがあり、その場合は list のフィルタを使う

## 禁止事項

1. `bd remember` / `bd forget` / `bd memories` を使わない（prime のコンテキストを肥大化させる。記憶は issue の note に残す）
2. bd のために git commit / push をしない。`bd dolt push` 等の Dolt sync に触らない
3. swarm / federation / merge-slot / gate 等の高度機能を自分の判断で使わない（必要ならユーザーに提案する）
