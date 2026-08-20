---
name: crit-open-in-cmux
description: crit を起動するときは必ず --no-open を付け、表示された URL を cmux のブラウザで開く。crit / crit live / crit preview / crit --pr / crit plan など crit のレビューセッションを開くとき常に適用する。デフォルトの自動ブラウザ起動は使わない
---

# crit は --no-open で起動し cmux のブラウザで開く

crit のデフォルトはシステムの既定ブラウザを自動で開く。この環境ではそれを使わず、cmux の内蔵ブラウザパネルに表示する。

## 手順

1. crit のコマンドに必ず `--no-open` を付けて起動する

```
crit --no-open
```

`crit live <url>` / `crit preview <file.html>` / `crit --pr <num>` / `crit plan --name <slug> <file>` / `crit --range <base>..<head>` も同じく `--no-open` を付ける。

2. 起動出力に現れる URL をそのまま読み取る

出力は次の形になる。`http://localhost:<port>` の部分が URL である。

```
Started crit daemon at http://localhost:61900 (session a3d919c400a5, PID 34551)
```

3. 読み取った URL を一字一句そのまま cmux のブラウザで開く

```
cmux browser open http://localhost:61900
```

## 開き直しの禁止

`cmux browser open` を実行するのは、crit を新しく起動して URL を得たときだけである。既に開いているセッションに対して開き直してはならない。

とくに `crit --session <id>` はレビューの次ラウンドへ進むための再接続であり、ブラウザ操作を伴わない。実行しても `cmux browser open` は不要である。

```
# NG — 再接続しただけなのに開き直す
crit --session 6bdc026dc6c0
cmux browser open http://localhost:64624

# OK — 再接続のみ。ブラウザは開いたままなので何もしない
crit --session 6bdc026dc6c0
```

ユーザーから「表示されない」と言われた場合を除き、2 回目以降の `cmux browser open` は行わない。

## URL を加工することの禁止

出力された URL に対して、パスを足す・セッション ID を埋め込む・形式を推測して組み立てる、のいずれも禁止する。`/r/<session>` のようなパスは crit の出力に現れない限り存在しない。

出力にパスが付いていないのは異常ではなく、これが正常な形である。「パスがないのはおかしい」と考えて補完してはならない。

```
# NG — セッション ID からパスを組み立てる
cmux browser open http://localhost:61900/r/a3d919c400a5

# OK — 出力された URL をそのまま渡す
cmux browser open http://localhost:61900
```

## 表示されないと言われたときの対応

まず出力された URL をそのまま渡したかを確認する。加工していたなら、加工前の URL で開き直すだけでよい。

URL の形式を自分で調べようとしないこと。curl でのパス探索、`crit status` からの URL 再構成、`--no-open` を外しての再起動は、いずれも不要かつ禁止である。それでも表示されない場合はユーザーに状況を伝えて指示を仰ぐ。

## 注意

1. `--no-open` は理由を問わず外さない。URL を調べる目的であっても外さない。省略して起動してしまった場合のみ、既定ブラウザ側のタブを閉じ、改めて `cmux browser open <url>` を実行する
2. crit はサーバーを立てたまま前景に留まるため、バックグラウンド実行にして URL を取得する
3. `cmux open` ではなく `cmux browser open` を使う。前者はワークスペースのパネルとして開く汎用コマンドで、ブラウザサーフェスを指定できない
