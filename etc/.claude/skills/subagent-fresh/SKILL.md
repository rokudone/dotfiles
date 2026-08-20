---
name: subagent-fresh
description: 会話の文脈を持たない白紙の subagent を起動する。/subagent-fresh で明示的に呼ぶ。
user-invocable: true
---

# 白紙の subagent を起動する

引数に渡されたタスクを `Agent` ツールの `subagent_type: "general-purpose"` で起動する。

fresh は現在の会話コンテキストを引き継がないため、先入観なしの調査やレビューに使う。タスクに必要な前提は prompt に全て書く。

引数が空の場合は、何をさせたいかをユーザーに聞く。
