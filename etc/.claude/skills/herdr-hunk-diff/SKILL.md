---
name: herdr-hunk-diff
description: git の差分を hunk cli で herdr の横のペインに開く。「diff を hunk で見せて」「差分をペインで開いて」「コードレビューしたい」等で発動。親ブランチの特定も含む
argument-hint: "[base-ref]"
---

# herdr のペインで hunk diff を開く

差分レビューを依頼されたら、ターミナルに diff を垂れ流さず、`herdr pane split` で右ペインを作って `hunk` を起動する。

## 手順

1. 比較元 ref を決める。指定がなければ親ブランチを特定する（下記）。
2. `herdr pane current` で自分の pane_id を取得する。
3. `herdr pane split <pane_id> --direction right --ratio 0.5 --cwd <リポジトリのパス> --no-focus` で右に分割する。返る JSON の `pane_id` が新ペイン。
4. `herdr pane run <新pane_id> 'hunk diff <base>..HEAD'` で hunk を起動する。
5. `herdr pane read <新pane_id> --source visible --lines 30` で起動を確認する。

`--no-focus` を付ける。フォーカスを奪うとユーザーの作業を中断させる。

## 親ブランチの特定

release から生えていないブランチの比較元は、次の 2 つを合わせて判断する。

1. `git log --oneline -10 --decorate` — HEAD の手前のコミットに付いている branch 名を見る
2. `git branch -a --contains HEAD~1` — その親コミットを含むブランチを列挙する

両方に出てくる feature ブランチが比較元。`origin/` や `pr/` の同名 ref が並んでいるのは同じブランチのリモート側なので、ローカル名を使う。

## hunk のコマンド

| 用途 | コマンド |
|:----|:--------|
| ref 間の差分 | `hunk diff <base>..HEAD` |
| 作業ツリーの変更 | `hunk diff` |
| ステージ済み | `hunk diff --staged` |
| 直前のコミット | `hunk show` |
| 特定のコミット | `hunk show <ref>` |
| patch ファイル | `hunk patch <file>` |

パス絞り込みは `-- <pathspec>` を末尾に付ける。

## 注意

- `hunk` は全画面 TUI なので、`herdr pane run` 経由で別ペインに送る。Bash で直接実行すると出力が壊れる。
- 差分の規模は先に `git diff --stat <base>..HEAD` で把握して、ユーザーに要約を伝える。
- ペインの中身を確認するとき以外は `herdr pane read` を繰り返さない。ユーザーが読むための画面であり、こちらが読むためのものではない。
