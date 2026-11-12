---
name: report-html
description: 分析・比較・調査の結果を単一ファイルの HTML レポートにして、ブラウザで開く。ターミナルの Markdown では読みづらい長い内容を出すときに使う。ユーザーが「HTML で」「レポートにして」「図解して」と言った時、または /report-html で発動。
user-invocable: true
argument-hint: [出力先パス] （省略時は確認する）
allowed-tools: Write, Read, Bash
---

# report-html

<<<<<<< Updated upstream
分析結果を単一 HTML ファイルにして、ブラウザで開く一行を渡す。ターミナルに長い Markdown を流す代わりに使う。
||||||| Stash base
長文資料を、認知負荷の低い1枚のダイジェストHTMLに変換する。実績: masa_wunder の統合ドキュメント29本（merged/digest/ 配下）。
=======
長文資料を、認知負荷の低い1枚のダイジェストHTMLに変換する。実績: masa_wunder の統合ドキュメント29本（masa_wunder/reports/ 配下）。
>>>>>>> Stashed changes

## 前提

1. 単一ファイル完結。CSS は `<style>` にインライン。外部 CSS / JS / フォント / 画像を一切参照しない。
2. 画像は SVG のみ。`<img>` タグを使わない。写真・イラスト・ラスタ画像は扱わない。
3. ライト固定。ダークモードの分岐を入れない。
4. 出力先は固定しない。ユーザーが指定しなければ聞く。指定がなく聞ける状況でなければスクラッチパッドに置く。
5. Bash の sandbox は `open` を必ず拒否する（Launch Services が塞がれている）。生成後に `open` を打たず、`! open <絶対パス>` の一行を単独のコードブロックで渡す。先頭の `!` を省かない（省くとユーザーの発話として送られる）。

## 手順

1. 出力先パスを決める。ユーザー指定があればそれに従う。なければ聞く。
2. 内容を構造化する。何が主張で、どこが図になるかを先に決める。図にならない内容を無理に図にしない。
3. 下の骨格をそのまま使って HTML を書く。Write で 1 ファイルに書き出す。
4. 前提 5 の一行を出す。ターミナル本文には結論を数行だけ書き、詳細は HTML に送る。

## 内容とテーマを混ぜない

テーマは見た目の指定であって、書く内容の指定ではない。テーマに合わせて文体を変えたり、記事らしい導入や締めを足したりしない。内容は内容の都合だけで決める。

文章は `prose-style` スキルの文体ルールに従う。常体、読点を減らす、淡々と書く、強調表現を使わない。

## 内容の作り方

ターミナルに書けば済む程度の内容なら、そもそも HTML にしない。

既定は表。図は、表では表せないものにだけ使う。

図にするのは、要素の位置関係そのものが意味を持つときに限る。どこから何が出てどこへ入るか（経路・依存）、何が何の内部にあるか（階層・境界）、どこで分岐して合流するか。これらは行と列に置き換えると情報が落ちる。

同じ項目について複数の軸の値を並べるだけなら表にする。行が独立していて、上下の順序に意味がなく、隣の行と線で繋がっていないなら、それは図ではなく表である。矢印を引いても、それが「左の欄の値に対応する右の欄の値」以上を意味していないなら、その矢印は列の区切りでしかない。

<<<<<<< Updated upstream
```
❌ 図にした比較        →  ✅ 表
[書き方] → [解決] → [結果]     | 書き方 | 解決 | 結果 |
[書き方] → [解決] → [結果]     | ...    | ...  | ...  |
```

表は本文と同じ幅に折り返せて、文字数の制約も受けない。図にすると座標の制約が生まれ、文字を 16px 以上にした時点で入らなくなる。

単なる列挙、分岐のない手順、2〜3 項目の対比も図にしない。文章か表で書く。

内容と関係ない要素を足さない。バッジ、統計、タブ、サイドバー、アバターの類は、それ自体が伝える情報を持たない限り置かない。

## SVG の描き方

`<svg>` を HTML に直接埋め込む。`viewBox` は幅 1020 を基準にする（本文カラムと同じ）。`width` は指定せず CSS で `width: 100%` にする。

```html
<figure>
  <svg viewBox="0 0 1020 170" role="img" aria-label="図の説明">
    <defs>
      <marker id="ar1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
        <path d="M 0 1 L 9 5 L 0 9" fill="none" stroke="var(--fg-66)" stroke-width="1.3"/>
      </marker>
    </defs>
    <!-- 中身 -->
  </svg>
  <figcaption>図が何を示すか</figcaption>
</figure>
```

色はカスタムプロパティを `fill="var(--fg)"` のように参照する。SVG 内に色を直接書かない。

`<marker>` は図ごとに `<defs>` を持たせ、id を図ごとに変える（`ar1` / `ar2`）。他の図の defs を参照しない。

テキストは `<text>` で入れる。`font-family` は指定せず継承させる。フォントサイズは 16〜18 を基準にし、16 を下回らない。線は `stroke-width="1.3"` を基準にする。

`viewBox` の座標は CSS ピクセルと一致しないので、`width: 100%` で表示幅 1020 に収まって初めて 16 が 16px になる。`viewBox` の幅を 1020 より大きくすると文字は縮む。広い図が要るなら、幅を増やさず図を分割する。

文字が 16 以上あると、1020 の中に置けるテキストの量は少ない。3 列に矢印を挟むような構成は幅が足りなくなる。列の文字数を数えてから座標を決める。日本語は 1 文字あたりフォントサイズと同じ幅、英数字はその半分で見積もる。

図が複雑になったら分割する。一枚に詰め込まない。

## 骨格

数値は note.com の配信 CSS から読み取ったもの。そのまま使う。

```html
<!doctype html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light">
<title>タイトル</title>
<style>
:root {
  --bg: #fff;
  --fg: #08131a;
  /* 文字色は 1 種類。副次的なテキストも薄くしない */
  --fg-66: #08131a;
  --fg-46: #08131a;
  --line-mid: #08131a;
  --surface-2: #f5f8fa;
  --accent: #1f9e8c;
  --danger: #c62d28;

  /* html は 125%（20px）基準。最小は --fs-sm の 16px */
  --fs-sm: .8rem;       /* 16px */
  --fs-base: 1rem;      /* 20px */
  --fs-lg: 1.125rem;    /* 22.5px */
  --fs-xl: 1.25rem;     /* 25px */
  --fs-2xl: 1.75rem;    /* 35px */

  --sans: "Helvetica Neue", "Hiragino Sans", "Hiragino Kaku Gothic ProN", Arial, "Noto Sans JP", Meiryo, sans-serif;
  --mono: SFMono-Regular, Consolas, Menlo, Courier, monospace;
  --fg-strong: var(--fg);
  --muted: var(--fg-66);
}
* { box-sizing: border-box; }
html { font-size: 125%; } /* 20px 基準。rem 指定の文字と行送りが一括で決まる */
body {
  margin: 0; padding: 0 1.25rem 8rem;
  background: var(--bg); color: var(--fg);
  font-family: var(--sans); font-size: var(--fs-base); line-height: 1.5;
  -webkit-font-smoothing: antialiased;
}
article { max-width: 1020px; margin: 0 auto; }

.head { padding: 72px 0 0; }
h1 {
  font-size: 42px; line-height: 60px; font-weight: 700;
  letter-spacing: 1.28px; margin: 0 0 48px; color: var(--fg);
}

/* ブロック共通マージン: すべて 36px */
h2, h3, p, ol, ul, blockquote, figure, hr,
.checks, .tablewrap, details, pre { margin-top: 36px; margin-bottom: 36px; }

/* 見出しは margin-bottom:-18px で次の段落に食い込ませる */
h2, h3 {
  margin-bottom: -18px; font-weight: 700;
  font-feature-settings: "palt" 1; line-height: 2.25rem; letter-spacing: .04em;
  color: var(--fg);
}
h2 { margin-top: 54px; font-size: var(--fs-2xl); }
h3 { margin-top: 36px; font-size: var(--fs-xl); }
h2 + h3 { margin-top: 54px; }

p { font-size: var(--fs-lg); line-height: 2rem; }
.head + p { margin-top: 0; } /* 導入段落のみ。p:first-of-type にすると h2 直後の最初の段落が見出しに食い込む */
a { color: var(--fg); text-decoration: underline; cursor: pointer; }
a:hover { text-decoration: none; }

pre {
  font-family: var(--mono); font-size: var(--fs-base); line-height: 1.7;
  color: #fff; background: #000; white-space: pre-wrap;
  padding: 36px; overflow-x: auto;
}
pre code { background: none; padding: 0; color: inherit; font-family: var(--mono); font-size: 100%; line-height: inherit; }
p code, li code, td code, summary code, .check code, blockquote code {
  font-family: var(--mono); font-size: max(.9em, 16px);
  background: var(--surface-2); padding: .15em .4em; border-radius: 3px;
}

blockquote {
  margin-left: 0; margin-right: 0;
  padding: 25px 36px; font-size: var(--fs-base); line-height: 2.25rem;
  background: var(--surface-2);
}
blockquote > * { margin-top: 0; margin-bottom: 0; font-size: var(--fs-base); }

ol, ul { padding-left: 24px; }
li { margin-top: 9px; margin-bottom: 9px; font-size: var(--fs-lg); line-height: 1.875rem; }

hr { border: none; border-bottom: 1px solid var(--line-mid); height: 0; }

figure svg { width: 100%; height: auto; display: block; }
figcaption { display: block; margin-top: 16px; font-size: var(--fs-sm); text-align: center; }

.tablewrap { overflow-x: auto; }
table { border-collapse: collapse; width: 100%; font-size: var(--fs-base); line-height: 1.875rem; }
th, td { padding: 12px 14px 12px 0; border-bottom: 1px solid var(--line-mid); text-align: left; vertical-align: top; }
th { font-weight: 700; color: var(--fg-66); }
td:first-child { font-weight: 700; }

/* 検査結果などの短い対リスト */
.check { display: flex; align-items: baseline; gap: 12px; padding: 14px 0; border-bottom: 1px solid var(--line-mid); }
.check:first-child { border-top: 1px solid var(--line-mid); }
.check .dot { width: 6px; height: 6px; border-radius: 50%; background: var(--accent); flex: none; transform: translateY(-2px); }
.check .k { font-size: var(--fs-base); font-weight: 700; flex: 1; }
.check .v { font-size: var(--fs-sm); color: var(--fg-66); font-family: var(--mono); text-align: right; }

details { padding: 16px 0; border-top: 1px solid var(--line-mid); border-bottom: 1px solid var(--line-mid); font-size: var(--fs-base); }
details p { font-size: var(--fs-base); line-height: 1.875rem; }
summary { cursor: pointer; font-weight: 700; list-style: none; display: flex; align-items: center; gap: 10px; }
summary::-webkit-details-marker { display: none; }
summary::before {
  content: ""; width: 0; height: 0; flex: none;
  border-left: 5px solid var(--fg-46);
  border-top: 4px solid transparent; border-bottom: 4px solid transparent;
  transition: transform .15s ease;
}
details[open] summary { margin-bottom: 20px; }
details[open] summary::before { transform: rotate(90deg); }
details > *:not(summary):last-child { margin-bottom: 0; }

.foot { margin-top: 72px; padding-top: 24px; border-top: 1px solid var(--line-mid); font-size: var(--fs-sm); color: var(--fg-66); }
</style>
</head>
<body>
<article>

  <div class="head">
    <h1>タイトル</h1>
  </div>

  <p>導入。</p>

  <h2>節</h2>
  <p>本文。</p>

  <figure>
    <svg viewBox="0 0 1020 170" role="img" aria-label="…">…</svg>
    <figcaption>…</figcaption>
  </figure>

  <div class="foot">補足があれば</div>

</article>
</body>
</html>
```

## 決まりごと

1. `ul` を使わない。箇条書きは `ol`。これはユーザーの全体方針。
2. 太字による強調を使わない。強調は語の選び方と構造で示す。
3. 16px 未満のフォントを使わない。CSS も SVG の `<text>` も対象。`em` や `%` で指定するときは、継承元の実寸を計算して 16px を下回らないことを確認する。下回るなら `max(.9em, 16px)` のように下限を書く。
4. 文字を薄くしない。本文・補足・キャプション・表のヘッダ・図のラベルを、すべて `--fg` の一色で出す。`rgba` による透明度、灰色、`opacity` のいずれも使わない。区別が要るなら太さ・位置・罫線で付ける。
5. 表は `.tablewrap` で囲む。
6. JavaScript は入れてよい。ただし静的で足りるものに動きを足さない。折りたたみは `<details>` で足りる。入れるなら `prefers-reduced-motion` を尊重する。
7. 折りたたみ（`<details>`）は、本筋から外れる検証ログやコマンド列を畳むのに使う。

## 補足

配色や字送りを変えたいと言われたら、`:root` のカスタムプロパティだけ差し替える。構造は触らない。

`--fg-66` と `--fg-46` は名前に濃度が残っているが、値は `--fg` と同じ。名前に合わせて薄い値へ戻さない。指定を減らさず変数を残してあるのは、骨格の各所からの参照を書き換えずに済ませるため。

他サイトの見た目に寄せたいと言われた場合、記事を開いて算出スタイルを測るのではなく、配信されている CSS を取得して規則ごと読む。記事に存在しない要素は算出スタイルでは測れない。Playwright は `~/Library/Caches/ms-playwright` のバイナリを `executablePath` で指定すれば動く。読み取った数値を自分のスタイルに反映するに留め、他社の CSS をそのまま複製しない。
||||||| Stash base
複数本ある場合は同スタイルの目次ページ（index.html）も作る。実例: /Users/filriya/Documents/note/masa_wunder/merged/digest/index.html
=======
複数本ある場合は同スタイルの目次ページ（index.html）も作る。実例: /Users/filriya/Documents/note/masa_wunder/reports/index.html
>>>>>>> Stashed changes
