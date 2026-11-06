---
name: report-cli
description: 今の話題を図の形で見せる。「図にして」「形を見せて」「構造を出して」「report-cli」と言われた時、または会話の対象（コードの流れ・ファイル構成・状態遷移）を文章より形で示したほうが早い時に使用。ターミナルに出す前提で、擬似コード・呼び出し木・ファイル木・diff のいずれかを選ぶ
argument-hint: [何を見せるか]
---

今の話題を、要点が伝わる最小の形で見せる。前置きを省き、文章は短くする。

ターミナルに出すので、描画が要る記法（Mermaid 等）は使わない。すべて等幅のテキストで組む。

## 型

内容の種類に合わせて一つ選ぶ。複数使うことはあっても、全部は使わない。

ロジックやアルゴリズムは擬似コード:

```text
on(save)
  if content is unchanged
    return cached result
  write new content
  return fresh result
```

実行時の制御の流れは呼び出し木:

```text
submitForm
  createSession
    persistPrompt
    launchAgent
  navigateToSession
```

UI の構造はコンポーネント木。意味のある state とモジュール境界を添える:

```tsx
<SessionPage> (apps/example/src/routes/session.tsx)
  useSessionEvents()
  <SessionToolbar>
    <RunSkillButton> (packages/ui)
```

ファイルの責務や広い refactor は浅いファイル木:

```text
src/
├── commands/       # ユーザー操作を解釈する
├── sessions/       # セッション状態を持つ
└── transport/      # API リクエストを送る
```

相互作用や時系列は、参加者を列にした矢印の並び:

```text
User      UI          Daemon
 |-- コマンド選択 -->|            |
 |          |-- 展開した prompt -->|
 |          |<-- 結果を stream ---|
```

すでにある形の中で何が変わるかが主題なら diff。話題に合わせて木・擬似コード・ファイル木のどれにでも `+` `-` を付ける:

```diff
 submitForm
   createSession
     persistPrompt
+    expandSkillMention
     launchAgent
-  navigateToSession
+  navigateToSession
+    subscribeToEvents
```

大半が新規で、省くと所有や順序が見えなくなる時や、コピーして使える目標形が要る時は、ブロック全体を出す:

```ts
function expandSkill(command: string): string {
  const skillName = command.slice(1)
  return `use the ${skillName} skill`
}
```

## 置き方

1. 図は、それを支える短い文の隣に置く
2. 今の問い、または今の論点を決めるのに要る呼び出し・ファイル・prop・状態・境界だけを残す。それ以外は削る
3. 一つの図で足りるなら一つで止める。足りない時だけ二つ目を足す
4. ファイルには書かない。長さがターミナルに収まらない時は、この skill ではなく report-html の仕事である
