---
name: subagent-fork
description: 今の会話の文脈を引き継いだ subagent を起動する。/subagent-fork で明示的に呼ぶ。
user-invocable: true
---

# fork で subagent を起動する

引数に渡されたタスクを `Agent` ツールの `subagent_type: "fork"` で起動する。

fork は現在の会話コンテキストをそのまま引き継ぐため、これまでの議論の前提や決定を説明し直す必要がない。

引数が空の場合は、何をさせたいかをユーザーに聞く。
