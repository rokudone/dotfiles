---
name: git-gtr
description: git gtr (Git Worktree Runner) でworktreeを操作する。worktreeの作成・削除・一覧・移動が必要なときに使用。「worktree作って」「worktree消して」「worktree一覧」等で発動
---

# git gtr — Git Worktree Runner

worktree操作には `git gtr` サブコマンドを使う。`git worktree` を直接叩かない。

## コマンド一覧

| 操作 | コマンド |
|------|---------|
| 一覧 | `git gtr list --porcelain` |
| 作成 | `git gtr new <branch>` |
| 削除 | `git gtr rm <branch>` |
| 削除+ブランチ削除 | `git gtr rm <branch> --delete-branch` |
| 複数削除 | `git gtr rm <branch1> <branch2> ...` |
| パス取得 | `git gtr go <branch>` |
| コマンド実行 | `git gtr run <branch> <command...>` |
| ヘルスチェック | `git gtr doctor` |
| 不要worktree掃除 | `git gtr clean` |

## 注意

- `git gtr` はリポジトリルートで実行する。`git -C` は使用禁止（サンドボックスで弾かれる）
- カレントディレクトリが対象リポジトリでない場合、ユーザーにコマンドを提示して手動実行を依頼する
- ブランチ名で worktree を特定する（パス指定ではない）
- メインリポジトリは特別ID `1` で参照: `git gtr go 1`, `git gtr run 1 git status`
- `--yes` で確認スキップ可能（削除時）

## 別リポジトリの worktree を操作する場合

Bash サンドボックスの制約により、カレントディレクトリ外のリポジトリでは `git gtr` を直接実行できない。
コマンドをコードブロックで提示し、ユーザーに実行してもらう。

```
cd ~/projects/casy-hub
git gtr list --porcelain
git gtr rm feature/CASY-XXXX --yes
git gtr run feature/CASY-XXXX git status --short
```
