---
name: skill-vs-command
description: Claude CodeにおけるSkillsとCustom Slash Commands（.claude/commands/）の違いを説明する
disable-model-invocation: true
---

# Skills vs Custom Slash Commands の違い

ユーザーにSkillsとCommandsの違いをわかりやすく説明してください。以下の情報をベースに回答すること。

## 概要

Claude Codeには2つのカスタムコマンド定義方法がある。Commandsは旧形式で、Skillsが現在の推奨形式。

## 比較表

| | Custom Slash Commands | Skills |
|---|---|---|
| 配置場所 | `.claude/commands/<name>.md` | `.claude/skills/<name>/SKILL.md` |
| 構造 | 単一 `.md` ファイル | ディレクトリ単位（SKILL.md + 補助ファイル） |
| Claudeによる自動呼び出し | 不可 | 可能（descriptionで判断） |
| サポートファイル同梱 | 不可 | 可能（テンプレート、スクリプト等） |
| subagent実行 | 不可 | 可能（`context: fork`） |
| モデル指定 | 不可 | 可能（`model: opus` 等） |
| ツール制限 | 可能 | 可能 |
| スコープ | パーソナル / プロジェクト | パーソナル / プロジェクト / エンタープライズ / プラグイン |

## 配置場所とスコープ

### Commands
```
~/.claude/commands/review.md           → 全プロジェクト共通
.claude/commands/review.md             → このプロジェクトのみ
```

### Skills
```
~/.claude/skills/review/SKILL.md       → 全プロジェクト共通（パーソナル）
.claude/skills/review/SKILL.md         → このプロジェクトのみ
```

## Skills の構造例

```
.claude/skills/
└── my-skill/
    ├── SKILL.md           # 必須: メインの指示
    ├── template.md        # 任意: テンプレートファイル
    ├── examples/          # 任意: サンプル集
    │   └── sample.md
    └── scripts/           # 任意: ヘルパースクリプト
        └── helper.py
```

## Skills の Frontmatter

```yaml
---
name: my-skill                      # コマンド名（省略時はディレクトリ名）
description: 何をするスキルか       # Claudeが自動呼び出しを判断する材料
disable-model-invocation: true      # trueならユーザー起動のみ
user-invocable: false               # falseならClaude自動呼び出しのみ（/コマンドに出ない）
allowed-tools: Read, Grep           # 使用許可ツールを制限
model: opus                         # 実行モデル指定
context: fork                       # subagentとして分離実行
agent: Explore                      # subagentタイプ指定
---
```

## Commands から Skills への移行

`commands/review.md` → `skills/review/SKILL.md` に移動するだけで基本的に動く。
Commandsは後方互換のために残っているが、新規作成はSkillsを推奨。
