---
name: git-no-dash-c
description: git -C を使わず cd でディレクトリ移動してから git コマンドを実行する。git コマンドを別ディレクトリで実行する際に常に適用する。
user-invocable: false
---

# git -C 禁止

Bash サンドボックスは `git -C <path>` を未承認ディレクトリへのアクセスと判定し、確認ダイアログを出す。
`cd` で移動してから実行すれば承認不要。

```
# NG — 確認ダイアログ発生
git -C /path/to/repo status

# OK — cd してから実行
cd /path/to/repo && git status
```
