---
name: google-sheets
description: Google スプレッドシートの読み書き（自前 OAuth + Sheets REST API）。ユーザーがスプレッドシートの URL を貼った時、「スプシ」「スプレッドシート」「シート読んで」「シートに書いて」と言った時に使用
argument-hint: "[spreadsheet-url]"
---

Google スプレッドシートを `~/.claude/bin/google/sheet.ts` 経由で読み書きする。

## 読み取り

scripts/read.ts を使う。メタ情報（ブック名・シート一覧）は stderr、セルデータは TSV で stdout に出る。

```
node --experimental-strip-types <このスキルのディレクトリ>/scripts/read.ts "<URLまたはspreadsheetId>" ["範囲"]
```

- URL に `#gid=` が含まれていれば該当シート全体、なければ先頭シートを読む
- 範囲を指定する場合は A1 記法: `シート名!A1:C10`
- 出力が大きくなりそうならファイルへリダイレクトして Read で読む。リダイレクトは `>|` を使う（noclobber の環境では `>` が既存ファイルで止まる）
- セル内の改行はそのまま出るため、TSV の行数はシートの行数と一致しない。特定の行を見たいときは範囲指定で絞る

## 通信エラー

sandbox のプロキシ経由では、大きな応答の途中で接続が切れることがある。`request` は GET に限り 3 回まで自動で再試行し、stderr に `# 再試行 n/2: ...` と出す。3 回とも失敗したら例外で落ちる（exit 1）ので、少し待ってコマンドごと再実行する。

`Detected unsettled top-level await` で exit 13 になるのは、応答の途中切断を拾えずに Promise が未解決のまま残る症状。sheet.ts 側で拾うように直してあるため、再発したら sheet.ts の `requestOnce` を疑う。

## 書き込み・その他の操作

`sheet.ts` の `request` を import して REST を直接叩く。スクリプトは scratchpad に書いてよい。

```ts
import { request } from "/Users/takuma/.claude/bin/google/sheet.ts";

// 更新
await request("PUT", `/spreadsheets/${id}/values/${range}?valueInputOption=USER_ENTERED`, {
  values: [["a", "b"]],
});
// 追加: POST `/spreadsheets/${id}/values/${range}:append?valueInputOption=USER_ENTERED`
// クリア: POST `/spreadsheets/${id}/values/${range}:clear`
```

書き込みは破壊的操作。ユーザーの明示的な指示があるときだけ実行する。

## 認証

トークンは `~/.claude/bin/google/secrets/token.json` にキャッシュされ、通常はログイン不要。初回・失効時はブラウザ認証が開くため、コマンドを run_in_background で実行し、ユーザーにブラウザでの許可を依頼する。
