---
name: cmux-md
description: Markdown ファイルを cmux の整形ビューアで開く。「開いて」「表示して」「見せて」と .md ファイルを指して言われた時、デイリーログ・タスクノート・設計メモ等を画面に出す時に使用。open コマンドや cat での代替は禁止
argument-hint: "[path]"
---

Markdown を開くときは `open` コマンドや `cat` を使わず、必ず cmux のビューアを使う。

```
cmux markdown open <path>
```

パスは絶対パスで渡す。ファイル変更は自動で反映される（ライブウォッチ付き）。

## オプション

必要なときだけ付ける。既定は右分割・フォーカスなし。

| オプション | 用途 |
|:----------|:-----|
| `--direction <left\|right\|up\|down>` | 分割方向（既定: right） |
| `--focus true` | ビューアにフォーカスを移す（既定: false） |
| `--workspace <id\|ref\|index>` | 対象ワークスペース |
| `--window <id\|ref\|index>` | 対象ウィンドウ |

## パスの解決

引数がファイルパスでない場合（「今日のデイリー」「タスクノート」等の呼び名）は、config.local.yml の `paths.notes` と CLAUDE.md の「notes の構成」から実体を引く。日付が要るものは `date +%Y%m%d` で確定させ、記憶で組み立てない。

## 報告

開いたら結果の `pane=` を添えて一行で伝える。ファイルの中身は読み上げない（ビューアに出ているものを地の文で繰り返すのはノイズ）。
