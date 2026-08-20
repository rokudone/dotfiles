---
name: crit-pr-review
description: 他人の PR をレビューするとき、crit を起動して GitHub の既存コメントを取り込み、ブラウザに表示するまでを実行する。「PR をレビューして」「crit で PR を見たい」「crit --pr」と言われた時に使用。役割分担のルールも含む
---

# 他人の PR を crit でレビューする

PR レビューを指示されたら、次の手順を最後まで実行してブラウザに表示するところまで持っていく。途中でユーザーに操作を求めない。

## 手順

### 1. PR 番号を特定する

引数に PR 番号 / URL があればそれを使う。無ければ現在ブランチから引く。

```
gh pr view --json number,title,url,headRefName,author
```

ブランチ名からの自動検出は失敗することがある。ローカルのブランチ名が `_` 区切りでリモートの head が `/` 区切りだと一致しないため。その場合はチケット番号等で検索する。

```
gh pr list --repo <owner>/<repo> --state all --search "<チケット番号>" --json number,title,url,state,headRefName,author --limit 30
```

### 2. crit を PR モードで起動する

`--no-open` は必ず付ける（crit-open-in-cmux に従う）。前景に留まるのでバックグラウンド実行にして URL を取得する。

```
crit --no-open --pr <num>
```

### 3. GitHub の既存コメントを取り込む

既存コメントの有無を判定せず常に実行する。空振りしても無害である。

```
crit pull <num>
```

引数なしだと自動検出に失敗しうるので番号を明示する。

### 4. デーモンを停止する

**この順序が要。** デーモン起動中に review.json を書き換えると、デーモンが自分の持つ状態で上書きし、修正が消える。

```
crit stop
```

`crit stop` は現在のセッションのみ停止する。他セッションのデーモンが残っていることがあるので、必要なら `pgrep -fl "crit _serve"` で確認して個別に kill する。

### 5. focus_key を書き換える

`crit pull` は focus key を組み立てるとき base SHA と PR 番号を落とし、`range:..<head_sha>`（`..` の左辺が空）という不正な値を書き込む。この値はどの起動オプションでも生成できないため、コメントはどのビューからも到達できない。crit 側の実装バグで、コマンドの使い方では回避できない。

review.json のパスは `crit status` の `Review file` に出る。`~/.crit/reviews/<session>/review.json` の形。

```
python3 -c "
import json
p='<review.json のパス>'
d=json.load(open(p))
n=0
for path,v in d.get('files',{}).items():
    for c in v.get('comments',[]):
        if c.get('focus_key','').startswith('range:..'):
            c['focus_key']='pr:<num>'; n+=1
for c in d.get('review_comments',[]):
    if c.get('focus_key','').startswith('range:..'):
        c['focus_key']='pr:<num>'; n+=1
json.dump(d,open(p,'w'),ensure_ascii=False,indent=2)
print('rewrote',n)
"
```

`diff_scope` は `layer` のままでよい。`crit --pr` の既定と一致する。

書き換え対象は crit のローカル review.json のみで、GitHub 上のコメントにも作業リポジトリのコードにも影響しない。書き換え前の状態は pull し直せば復元できる。

### 6. 起動してブラウザで開く

```
crit --no-open --pr <num>
```

出力された URL をそのまま `cmux browser open <url>` に渡す（crit-open-in-cmux に従う。URL を加工しない）。

### 7. 反映を確認する

書き換えが保持されたかを確認する。デーモンが上書きしていたら `range:..` に戻っている。

```
python3 -c "
import json
d=json.load(open('<review.json のパス>'))
print({c.get('focus_key') for p,v in d.get('files',{}).items() for c in v.get('comments',[])})
"
```

`{'pr:<num>'}` になっていれば成功。URL を伝えて Finish Review を待つ。

## 表示されないと言われたときの確認順序

ユーザーが「見えない」と言っても、実際には表示されていることがある。ファイルツリーの件数バッジは控えめな見た目で見落としやすい。推測で手を動かす前に、サーバとブラウザの実際の状態を確認する。

```
# サーバがコメントを認識しているか（comment_count と hidden_unresolved を見る）
python3 -c "
import json,urllib.request
d=json.load(urllib.request.urlopen('http://localhost:<port>/api/session',timeout=5))
print('hidden_unresolved:',d.get('hidden_unresolved'))
for f in d.get('files',[]):
    if f.get('comment_count'): print(' ',f['path'],f['comment_count'])
"

# ブラウザに実際に描画されているか
cmux browser <surface> eval --script "document.body.innerText.slice(0,600)"
```

`hidden_unresolved: 0` かつ `comment_count` が立っていれば、サーバ側は正常。あとは描画の問題なので DOM を見る。

`crit --range <base>..<head>` で開き直す案は使えない。新しい空セッションが作られてコメントを持つセッションとは別物になる。

## Finish Review の後の構図

crit の標準フローは「コメントを受けた作者がコードを直し、対応内容を返信する」前提だが、他人の PR では構図が逆になる。`crit comment --reply-to` 自体は禁止しない。返信はユーザーとのレビュー議論として使う。

- crit のコメントは、ユーザーが PR 作者に向けて書く指摘の草稿・相談材料。Claude への指示ではない
- 議論の場は crit の返信またはこの会話。成果物は、ユーザーが投稿すると決めた GitHub の PR レビューコメント
- PR 作者は crit セッションを見ない。crit に何を書いても誰にも届かない

### どちらへの返信なのかを取り違えない

crit と GitHub の PR には、どちらも「コメント」と「返信」がある。書き込む前に、いま書いているものがどちらへ向いたものかを確定させる。

- **crit への返信**: 宛先はユーザー。ユーザーが書いた草稿に対する、共にレビューする側からの意見・検討結果
- **GitHub への返信**: 宛先は PR 作者。レビューの成果物として届ける指摘

同じ内容を両方に書かない。crit では判断材料・問い返し・投稿要否を議論し、GitHub ではユーザーが確定した作者向け文面だけを投稿する。

Finish Review のプロンプトが「各コメントに `crit comment --reply-to` で返信せよ」と指示した場合は実行してよい。ただし、返信の宛先はユーザーであり、Claude はユーザーと共にレビューする側である。各コメントについて関連コードと既存のやり取りを調べ、次のいずれかを返す。

- コードから読み取れる意図と、ユーザーの懸念が成り立つかどうか
- 判断に必要な追加情報や、ユーザーへの問い返し
- 作者へ投稿する指摘として残すか、質問にするか、見送るかの提案

「修正しました」「対応しました」「テストを追加しました」のような作者視点の返答はしない。PR 作者の返信や最新コミットに対応内容がある場合も、「作者はこう回答しており、現在のコードではこう確認できる」とレビュワー視点で照合する。

### 禁止事項

1. PR のコードを修正しない。他人の PR である
2. 作者の視点で書かない。Claude はユーザーと共にレビューする側であって、指摘に答える側ではない
3. ユーザーの承認を得ていない文面を GitHub へ投稿しない
4. crit のコメントを実装指示として扱わない。`crit comment --reply-to` は議論への返信にだけ使う

### 正しい流れ

1. Finish Review 後、crit のコメント一覧を議論の入力として読む
2. コメントを1件ずつコードと照合し、`crit comment --reply-to <comment-id> --author <自分の名前> "<議論への返答>"` で自動返信してよい。返信前の個別承認は不要
3. 全コメントへの返信後、Finish Review の出力で指定された `crit --session <session-id>` を実行し、ユーザーが議論を続けられる画面を開く
4. ユーザーが投稿する・しないを決める。必要ならこの会話でも1件ずつ議論する
5. 確定した指摘は作者向け文面を一字一句提示し、承認を得てから GitHub へ PR レビューコメントとして投稿する
6. 投稿先・方法は manual-review 等の進行中フローがあればそれに従う
