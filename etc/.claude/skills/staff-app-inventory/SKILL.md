---
name: staff-app-inventory
description: casy-hub の casy-api/ts/staff（キャスト向けSPA）を Flutter + 新API へ移植するための既存機能洗い出しを実行する。「staff洗い出し」「スタッフアプリ棚卸し」「phase1/phase2/phase3」と言われた時、または /staff-app-inventory で使用。casy-hub リポジトリ内でのみ有効
argument-hint: "[phase1 | phase2 <ドメイン名> | phase3]"
---

# staff アプリ機能洗い出し

casy-api/ts/staff（Backbone + Redux + EJS の SPA）の既存機能を、Flutter + 新API での完全再現に必要な粒度で文書化する。

コードベースの構造的事実（調査済み・file:line 付き）は references/codebase-facts.md を必ず先に読む。

## 絶対ルール

- apiv2（config/routes.rb の namespace :apiv2、app/controllers/apiv2/）には触れない・参照しない・比較しない。捨てるものとして扱う
- 応募者向けサーバーHTML（Top::StaffhomeController、Top::StaffEntryController）はスコープ外
- 見た目（SCSS・レイアウト・色）と文言は対象外。スタイルは作り直すため、構造と挙動だけを記述する
- 判定条件は展開して書く。「WageService.displayable? を参照」のようなポインタ書きは禁止。「デビュー済みかつ締め処理完了月のみ表示」のように条件そのものを記述する
- コード読解の調査は Explore サブエージェントにファンアウトしてよいが、成果物ファイルの書き込みはメインコンテキストで行う

## 成果物の置き場所

casy-hub リポジトリルートの `.agent/staff-app-inventory/` 以下。

```
.agent/staff-app-inventory/
├── phase1/
│   ├── routes.tsv
│   ├── views.tsv
│   ├── apis.tsv
│   ├── deeplinks.tsv
│   ├── cross-cutting.md
│   └── verification.md
├── phase2/
│   ├── <ドメイン名>-front.md（画面仕様）
│   └── <ドメイン名>-server.md（API挙動仕様）
└── phase3/
    └── unused-endpoints.md
```

## Phase 1: 機械的列挙（解釈なし、正本データの作成）

5つの成果物を作る。列挙元はすべて references/codebase-facts.md に記載の単一の真実の源を使う。

### routes.tsv

app_router.ts の `get routes()` 全エントリ（約110）を列挙する。

列: `route_pattern` `handler` `view_class` `view_file` `guards`（routeGuards + draw内ガード） `handler_notes`（データ先読み・ヘッダ差し替え等の特記） `domain`

### views.tsv

staff views 全264ファイル + staff が使う shared views を列挙する。

列: `view_file` `class_name` `instantiated_from`（router / 親viewファイル名） `templates`（require している EJS） `is_shared` `notes`

到達可能性判定は shared を含む全ツリーで行う（staff 内 grep だけでは偽陽性が出る）。

### apis.tsv

actions/apis.ts の全関数（219）を列挙する。変数組み立ての隠れパス6本（codebase-facts.md 参照）を必ず展開する。

列: `function_name` `method` `path` `server_controller` `server_service`（コントローラが委譲する先） `jbuilder` `domain` `notes`

### deeplinks.tsv

メール・プッシュ・サーバーリダイレクト発の全ディープリンク（codebase-facts.md に一覧あり。列挙時に再グレップして増減を確認する）。

列: `source_kind`（mail / push / redirect） `source_file` `target_path` `route_exists`

### cross-cutting.md

画面に紐づかない横断機構の仕様: ミドルウェア6種、ネイティブブリッジ2種、UA・アプリ版チェック、認証・セッション、CSRF、状態永続化（saveState）、行動ログ送信、304キャッシュ、X-App-Request-Time。

### verification.md（Phase 1 の完了条件）

以下を機械的に確認し、結果を記録する。

1. 全 view ファイル（staff 264 + 使用 shared）が views.tsv に現れる。現れないものはデッドコードとして明示（既知: views/modals/reason_for_unmatching_view.ts の1件）
2. 全テンプレート（staff 256 + 使用 shared）がいずれかの view に紐づく
3. deeplinks.tsv の全 target_path が routes.tsv に存在する
4. apis.ts 以外に通信経路がないことを grep で確認（期待ヒット: ajax.ts / sendAction.ts / cacaco_util.ts のみ）
5. routes.tsv の全ルートに domain が割り当てられている

## Phase 2: ドメイン単位の機能記述

引数でドメイン名を受け取る。routes.tsv / apis.tsv の domain 列で対象を抽出する。初回実行時は小さいドメインをサンプルとして作り、ユーザーに粒度を確認してから他ドメインへ展開する。

想定ドメイン分割（Phase 1 で確定させる）: オファー（スポット・定期・レコメンド）、依頼・ジョブ、チャット、給与・銀行・インボイス、コミュニティ（CACACO）、研修（home・online）、ガイダンス、仕事紹介、鍵（keycafe・返却・転送）、レポート（掃除・料理・チャレポ）、設定、紹介キャンペーン、エントリーフロー、認証・マイページ。

### 画面ごとの記述項目

1. 基本情報: ルート、view、テンプレート、流入経路（画面内遷移・ディープリンク）
2. 表示条件: ルートガード + EJS 内条件分岐。「誰に何が出るか」を条件展開して書く（view が計算してテンプレートに渡す変数も遡って条件を解決する）
3. ユーザー操作: 操作 → dispatch される API → 成功・失敗時の挙動（画面更新・遷移・エラー表示）
4. 構成部品: サブビュー・モーダル・shared 部品と、それぞれの表示条件
5. 遷移: 画面内からの遷移先

view と EJS はペアで読む。UI 仕様の本体は EJS の条件分岐に埋まっている。

### API ごとの記述項目（ドメイン内の全エンドポイント）

サーバ側をコントローラ → サービス → モデル → jbuilder の順に読み解いて書く。

1. 前提条件・権限: 誰がいつ呼べるか。表示・実行可否の判定条件を展開して記述
2. 処理内容: 計算ロジック、状態遷移、更新時の検証
3. 副作用: メール・プッシュ送信、他レコードの更新、外部連携
4. レスポンス: jbuilder が返す項目の一覧

### ドメイン完了条件

routes.tsv / apis.tsv の該当ドメイン全行が記述に現れることを突合して確認し、ファイル末尾に確認結果を記す。

## Phase 3: 逆引き検証

サーバ側からの逆引き。config/routes.rb の namespace :api > namespace :staff の全エンドポイントを展開し、apis.tsv と突合する。フロントから呼ばれないエンドポイントを unused-endpoints.md に「未使用（新API削減候補）」として列挙する。呼ばれているのに apis.tsv に無いものが出たら Phase 1 の欠陥なので apis.tsv を修正する。
