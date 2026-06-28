---
name: avoid-bash
description: 読まずに作業を開始してはならない。必読。Bashを避け備え付けツール（Read, Edit, Write, Grep, Glob等）を使う。コードを書く・ファイル操作する際に常に適用する。Claude Code 専用。Codex には関係ない。
user-invocable: false
---

# Bash を避けるルール

## 理由

Bash サンドボックスはディレクトリごとの書き込み権限を独自管理しており、プロジェクト内であっても未承認ディレクトリへの書き込みで確認ダイアログが発生する。
備え付けツール（Read, Write, Edit, Glob, Grep）はこの制約を受けないため、権限プロンプトなしで操作できる。

**備え付けツールで代替できる操作には Bash を使わず、備え付けツールを使う。**

## 代替テーブル

| 操作 | 使うべきツール | 避けるべき Bash |
|---|---|---|
| ファイル読み取り | Read | `cat`, `head`, `tail`, `less`, `more`, `bat` |
| ファイル作成 | Write | `echo "..." > file`, `cat <<EOF > file`, `printf > file`, `tee` |
| ファイル編集 | Edit | `sed -i`, `awk`, `perl -i -pe` |
| ファイル名検索 | Glob | `find`, `ls`, `tree` |
| コンテンツ検索 | Grep | `grep`, `rg` |
| ディレクトリ作成 | Write（親ディレクトリ自動作成） | `mkdir -p` |
| ファイルコピー | Read → Write | `cp` |
| 空ファイル作成 | Write（空文字列） | `touch` |

## スキル情報の取得

<IMPORTANT>
テスト・linter・デプロイ等のコマンドやスクリプトのパスを知りたいときは、system-reminder に表示される skill 一覧の description を読み、該当する skill 名を特定して `Skill` ツールで呼ぶ。SKILL.md 内の `${CLAUDE_SKILL_DIR}` は Skill ツール経由でのみ絶対パスに解決される。Glob/Grep/find で SKILL.md やスクリプトファイルを検索しても正しいパスは得られない。

SKILL.md を Read ツールで直接読むことも禁止する。スキルの内容が必要なときは必ず `Skill` ツールで呼び出すこと。例外はスキルファイル自体を更新するとき（SKILL.md を編集する作業）のみで、その場合は Read → Edit/Write してよい。
</IMPORTANT>

```
# NG — SKILL.md やスクリプトを検索して探す
Glob("**/SKILL.md", path="plugins/")
Grep("test", path="plugins/", glob="SKILL.md")
Glob("**/deploy.sh")
Bash("find . -name 'deploy.sh'")

# NG — SKILL.md を直接 Read する（スキル更新作業を除く）
Read("plugins/casy-domain/skills/casy-test/SKILL.md")

# OK — system-reminder の skill 一覧から正確な名前で呼ぶ
Skill("casy-test")
Skill("casy-deploy")
```

## 具体例

### cat / head / tail → Read

```
# NG
Bash("cat src/app.ts")
Bash("head -20 src/app.ts")

# OK
Read("src/app.ts")
Read("src/app.ts", limit=20)
```

### echo > / cat <<EOF > → Write

ファイルを作るあらゆる方法を Write に置き換える。**一時ファイル・中間ファイル・プロンプトファイル（/tmp 配下を含む）も例外ではない。** heredoc（<<'EOF'）でのファイル作成は「Bash でしかできない処理」ではなく、Write の単純な代替対象である。

```
# NG
Bash("echo 'step3-review-start' > .agent/last-step")

# NG — heredoc での一時ファイル作成（よくやりがちな違反）
Bash("cat > /tmp/prompt.txt <<'EOF' ... EOF")

# OK
Write(".agent/last-step", "step3-review-start")
Write("/tmp/prompt.txt", "...本文...")
```

### sed -i → Edit

```
# NG
Bash("sed -i 's/oldFunc/newFunc/g' src/app.ts")

# OK
Edit("src/app.ts", old="oldFunc", new="newFunc", replace_all=true)
```

### find / ls → Glob

```
# NG
Bash("find . -name '*.ts'")
Bash("find src -type f -name '*.spec.ts'")

# OK
Glob("**/*.ts")
Glob("src/**/*.spec.ts")
```

### grep / rg → Grep

```
# NG
Bash("grep -rn 'TODO' src/")
Bash("rg -l 'handleSubmit' --type ts")

# OK
Grep("TODO", path="src/", output_mode="content")
Grep("handleSubmit", type="ts", output_mode="files_with_matches")
```

### mkdir -p → Write

Write ツールはファイル作成時に親ディレクトリを自動生成する。ディレクトリだけ作りたい場合もファイルを書き込めばよい。

```
# NG
Bash("mkdir -p .agent/branches/feature-branch")

# OK（必要なファイルを書き込めば、ディレクトリも自動で作られる）
Write(".agent/branches/feature-branch/last-step", "step3-review-start")
```

### cp → Read + Write

```
# NG
Bash("cp src/template.ts src/new-file.ts")

# OK
Read("src/template.ts") → Write("src/new-file.ts", content)
```

### touch → Write

```
# NG
Bash("touch src/new-file.ts")

# OK
Write("src/new-file.ts", "")
```

## Bash が許容される場合

以下に限定する:

- git, npm, docker, bundle, rails 等のシステムコマンド
- diff, wc 等の集計・比較コマンド
- rm, mv 等の備え付けツールで代替できない操作
- パイプラインやシェル制御が本質的に必要な処理

## Bash を使うときの注意: 

### 変数代入を避ける

Bash サンドボックスは変数代入を含むコマンドを機械的に確認プロンプトへ引っかける。
パスや値を一旦変数に入れてから使うパターンは避け、直接インラインで書く。

```
# NG — 変数代入がサンドボックスの確認を誘発する
Bash('dir="/path/to/target" && mkdir -p "$dir" && echo "done" > "$dir/status"')

# OK — 値をインラインで直接使う
Bash('mkdir -p /path/to/target && echo "done" > /path/to/target/status')

# さらに良い — 備え付けツールで代替する
Write("/path/to/target/status", "done")
```
### パイプ (&& ||) でチェーンすることを避ける

パイプを使うことで別コマンドと判定され、確認プロンプトが走る。
cat ~.log など明らかに大きいファイルを扱う場合を除き、チェーンを避ける。

### 複合コマンドを避ける

`for` ループ・`$()` コマンド置換・複数コマンドの組み合わせは確認ダイアログが発生する。1コマンドずつ順に実行すること。

```
# NG — for + $() で確認ダイアログ発生
Bash('for rf in $(git branch -r | grep release-feature); do git merge-base HEAD "$rf"; done')

# OK — 1コマンドずつ実行
Bash('git branch -r --no-merged origin/release')
# 結果を見て、各ブランチに対して:
Bash('git merge-base HEAD origin/release-feature/xxx')
```

**スキル（SKILL.md）に手順を書く場合も同様。** 複合コマンドとして記述すると実行時に確認ダイアログが出る。1コマンドずつの手順として記述すること。
