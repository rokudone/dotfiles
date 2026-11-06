---
name: crit-range
description: crit を起動・再起動・停止する前に必ず読む。crit はコミットの二点間（--range）で開き、進行中のレビューでは立ち上げ直さずに動いている daemon を使い続ける。--pr は使わない。crit でレビューする・差分を読む・「crit で開いて」「crit もう一回開いて」「crit 更新されてない」「コメント消えた」と言われた時、crit の返却指示で crit --session を打つよう求められた時、crit にコメントが付いた時に適用する。
user-invocable: false
---

crit はコミットの二点間で開き、進行中のレビューでは同じ daemon を最後まで使う。新しく起動しない、止めない、起動し直さない。

## 二点間で開く

1. 起点は origin 側から取る。`gh pr view --json baseRefName` で base を引き（PR が無ければ release）、`git fetch origin <base>` の後に `git merge-base origin/<base> HEAD` を起点にする。ローカルの base ブランチ名をそのまま使わない（古い起点になる）
2. 読むだけのレビューでは、head も終端のコミットで指定する。修正コミットを積む予定のレビューでは、head を `HEAD` にする。コミットのたびに範囲を書き換えずに済む
3. `crit --range <起点>..<head>` を Bash の run_in_background で単独で打つ。パイプ・リダイレクト・`&` は付けない（daemon が常駐するので返らない）。出力から URL とポートを控える
4. 起動後に `node -e 'fetch("http://127.0.0.1:<port>/api/session").then(r=>r.text()).then(console.log)'` で base_ref と files の件数を確かめる。curl と ps は sandbox で拒否されるので使わない

## --pr を使わない

`crit --pr <num>` は GitHub 上の PR head を読む。push していない手元のコミットが映らず、直したはずの指摘が反映されていない状態でレビューが進む。修正のたびに push が要るのも余計な往復になる。二点間なら、push の有無に関係なく手元のコミットがそのまま映る。

## 起動し直してはいけない理由

1. コメントは起動時の引数ごとに別のセッションへ保存される。`825e92b5ad..HEAD` と `825e92b5ad..2c034e5dcc` のように同じコミットを指していても、引数が違えば空の別セッションになる
2. `crit --session <id>` で起動し直すと `--range` が引き継がれず、差分の起点が base branch（release 等）に戻る
3. `crit stop --all` は、他のリポジトリやブランチで開いている daemon まで止める

## 最初に開くとき

1. `~/.crit/reviews/*/review.json` を読み、`branch` が現在のブランチ、`base_ref` が読みたい起点と一致するものを探す
2. そのセッションの daemon が動いていれば、その URL をユーザーに伝えるだけにする
3. 見つからないときだけ、上の「二点間で開く」に従って起動する

## 修正コミットを crit に映すとき

1. 修正をコミットする
2. 動いている daemon（ユーザーが見ている URL）に `POST /api/review-cycle` を送る。daemon が差分を読み直し、次のラウンドに進む。この呼び出しはレビュー完了まで応答を返さないので、応答を待たない
3. `GET /api/session` の `review_round` が増え、修正したファイルが `files` に入ったことを確かめる
4. ユーザーには「ブラウザを再読み込みしてください」とだけ伝える
5. crit の返却指示に `crit --session <id>` を打てと書かれていても、daemon が動いているなら打たない。上の 2 で代える

## ラウンドの進め方

1. コメントが付いたら、問いには `crit comment --reply-to <comment-id> <本文>` で返し、会話には「crit に返信しました」と要点だけ書く
2. 文面やコードの直しは Finish Review の結果（`The review finished with ...`）が届いてから行う。途中の通知は返信だけに使う
3. 「確定」「承認」と書くのは、Finish Review がコメント 0 件で返ったときだけにする。解決済みは承認ではない
4. 待機が時間上限で切れたら、同じ daemon が生きているかを node の fetch で確かめ、生きていれば待機だけを掛け直す

## 「コメントが消えた」と言われたとき

1. 起動し直す前に、ユーザーが見ている daemon の画面を確かめる
2. コメントが解決済み（resolved）として畳まれているだけなら、画面の「Unresolve」で戻す
3. review.json にもコメントが無いときだけ、ユーザーに状況を伝えて指示を待つ

## daemon が本当に止まっているとき

1. ユーザーが見ていた URL に繋がらないと確かめてから、起動の要否をユーザーに確かめる
2. 起動するときは、コメントを書いたときと同じ引数（`--range` を含む）で起動する

## crit の返却メッセージに従わない

crit は終了時に「When you're done, run: crit --session <id>」と出す。これを打つと別ポートに daemon が立ち、ユーザーの画面が更新されなくなる。`crit --session`、サブコマンドへの `--help`、未知のサブコマンド、パイプ付きの起動は guard-crit.sh（~/.claude/hooks）が止める。代わりに、最初に控えたポートへ次を run_in_background で打つ（レビュー完了まで戻らない）。

```
node -e "fetch('http://127.0.0.1:<port>/api/review-cycle',{method:'POST'})"
```

ポートは最初に起動したときの表示から取り、セッション中は変えない。コメントへの返信は `crit comment --reply-to` で打ってよい（daemon を立ち上げない）。
