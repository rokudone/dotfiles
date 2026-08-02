# casy-api/ts/staff 構造的事実（2026-07 調査済み）

パスはすべて casy-hub リポジトリルートからの相対。行番号は調査時点のもので、ズレていたら周辺を探す。

## フロント構造

- ルーター: casy-api/ts/staff/routers/app_router.ts の1ファイルに集約
  - ルート定義: `get routes()`（app_router.ts:108、約110エントリ）。ルート文字列 = ハンドラメソッド名の一対一対応
  - 遷移ガード: `routeGuards` テーブル（app_router.ts:40、派遣・正社員キャスト等）+ `checkRouteGuard`（app_router.ts:72）+ `draw` 内のログイン・反社チェック・規約同意ガード（app_router.ts:308）
  - 複雑なハンドラ例: recommend_cleaning_offer_list（:470、13コレクション注入）、chat（:554、async データ先読み）、community_*（:894 以降、ヘッダを CommunityHeaderView に差し替え :888）、home_training_*（:1258、ロール判定コールバック）
- view バレル: casy-api/ts/staff/views/index.ts（97 export）。ルーターは `import * as Views` で全画面クラスを取り込む
- view ファイルは staff 配下に264。バレル非公開の約167はサブビュー・モーダルで、親 view からの `new XxxView` / import で到達（`new XxxView` は views 配下に282箇所）
- デッドコード: views/modals/reason_for_unmatching_view.ts の1件のみ（全ツリーでどこからも import されない）
- 偽陽性注意: views/staff_new_chat_message_view.ts は staff 内に importer が無いが shared/views/chat_view.ts:5 から import されている。到達可能性判定は必ず shared を含む全ツリーで行う
- テンプレート: 全256枚が EJS。view の `get template() { return require("../templates/xxx.ejs"); }` で紐づく。EJS はロジックを内包する（例: templates/my_page.ejs は351行・制御タグ72箇所、isPublish / unCleaning 等キャスト属性で出し分け）
- shared 層: casy-api/ts/shared。staff が使う distinct モジュール43。shared/views に25ファイル・shared/templates に19枚の実UI（not_found_view、loader_view、chat_view、pagination_view 等）。user アプリ（casy-api/ts/user）も同じ shared を共有
- 状態管理: reducers 42スライス（素の switch 方式）。Redux が真実の源、store.subscribe → lib/mapStateToBackbone.ts:110 で Backbone モデルへミラー、view は change イベントで再描画という一方向フロー。resources シングルトン（mapStateToBackbone.ts:69）をルーターが参照
- actions: ActionType.ts（型定数）、apis.ts（API関数219）、index.ts（同期アクション）、navigates.ts（ルーティングも Redux アクション）

## API 呼び出し機構

- CaSy サーバへの経路は3系統（「apis.ts 一本」ではないことに注意）:
  1. actions/apis.ts（約3,300行、219関数、Redux + ajax ミドルウェア）— 大半のAPI
  2. lib/api-client.ts（shared/fetch.ts の fetchApi、Redux非依存の素の fetch、X-CSRF-Token付与）— 前払い関連4関数のみ。呼び出し元は advance_salary_view.ts のみ
  3. 直リンク（ajax外）— PDFダウンロード3本（staff_util.ts:197 の requests download、wage_list_view.ts:82,96 の wages/invoices download）と EJS 内直接 aタグ2本（templates/guidances/guidance.ejs:64,68 の redirect_to_zoom/ai）
- Backbone model/collection は url/urlRoot を持たず通信しない
- 送信は middlewares/ajax.ts:13-67。`payload.request` を持つ action を `$.ajax` で送信。相対URLに `Casy.hostAddress()`（= apiServer + "/api"、shared/lib/globals.ts:11）を前置。パスは `/staff/...` 表記（実パスは /api/staff/...）
- `url:` は217箇所。ただし変数組み立ての隠れパスあり。必ず個別展開する:
  - apis.ts:817-829 submitOffer → /staff/offers/subscription_requests | /staff/spot_requests
  - apis.ts:836-848 submitOfferCombo → /staff/subscription_request_combos | /staff/spot_request_combos
  - apis.ts:1275 三項演算子 → /staff/request_report_masters/:request_id | /staff/job_report_masters/:job_id
- 例外パス1本: /line_staffs/disconnect（apis.ts:3057）
- method 未指定は GET（ajax.ts:35）。FormData なら multipart アップロード（ajax.ts:22-30）。If-Modified-Since/Last-Modified の304キャッシュ自前実装（ajax.ts:44-57）。全リクエストに X-App-Request-Time 付与（ajax.ts:24,34）
- 経路の完全性確認 grep: `\$\.ajax|fetch\(|\.save\(|axios|XMLHttpRequest|urlRoot|hostAddress\(\)|/api/staff` を staff と shared の両ツリー + templates（EJS）に対して実行。CaSy宛の期待ヒットは ajax.ts / shared/fetch.ts（api-client.ts経由） / 直リンク5箇所。外部宛は sendAction.ts / cacaco_util.ts
- サーバ外通信2系統: middlewares/sendAction.ts:31（全 Redux action を lzbase62 圧縮して外部 AWS API Gateway へ POST、2秒デバウンス）、lib/cacaco_util.ts:17-23（画像サイズ取得の fetch）
- WebSocket / EventSource / axios / iframe form POST は不使用

## サーバ側（旧API = 移植の読み解き対象）

- ルート: config/routes.rb:471-765 の namespace :api > namespace :staff。実パス /api/staff/...
- コントローラ: app/controllers/api/staff/ に89ファイル・約3,950行。薄いコントローラ + サービス + モデルの構成。casy-ruby には依存しない（同一 MySQL を別モデル名で参照）
- 大きいコントローラ: staffs_controller.rb（332行。update は複数画面の更新が集約された太い箇所、:49 に endpoint 分割の FIXME）、offers_controller.rb（223行）
- サービス例: app/services/wage_service.rb、staff_offer_service.rb、staff_offer_recommend_service.rb。これらは api/bo（管理画面）と api/monica（外部連携）からも共有されるため、洗い出し時は「staff 専用でない」ことに注意
- 基底: app/controllers/staff_application_controller.rb（login_required、メンテナンスモード）。current_staff は application_controller.rb:129
- レスポンス: jbuilder（app/views/api/staff/ に115ファイル）+ render partial + render json の3方式併存。シリアライザ不使用
- リクエストスペック: spec/requests/api/staff/ に24ファイル

## エントリーポイント・外部連携

- ホストページ: app/views/staff_apps/index.html.erb（`Casy.appStart(initialData)`、initial_data.jbuilder 埋め込み + CSRF トークン）。ルーティングは routes.rb:23 `get "/staff_apps/*path" => "staff_apps#index"`
- ネイティブ WebView: UA `casy-app-staff-(ios|android)-(version)` を照合（app.ts:49）。ブリッジは2種のみ（shared/lib/app_util.ts:44,55）:
  - requestDeviceToken: iOS webkit.messageHandlers.callbackHandler / Android window.CasyAndroid。マイページ表示時（app_router.ts:783）。トークン登録先 POST /api/staff/devices
  - notifyLogout: ログアウト時（views/logout_view.ts:17）
- アプリ版チェック: initialData の IOS/ANDROID_APP_VERSION と window.IOS_APP_VERSION を比較、古ければアップグレードモーダルで起動停止（app.ts:69）
- ディープリンク（調査時点の一覧。Phase 1 で再グレップして確定する）:
  - push: /staff_apps/mypage（staffs_controller.rb:297、trustdock_verifications_controller.rb:42、cooking_images_controller.rb:31）、/staff_apps/community_school（cacaco_school_attendances_controller.rb:32、staff_remind_hiyoko_salon.rake:12）、/staff_apps/guidance/:id（guidance_schedule.rake:49）、/staff_apps/edit_staff（staff_candidate.rake:127）、/staff_apps/setting（staff_candidate.rake:194）、/staff_apps/subscription_(cleaning|cooking)_offer_list（staff_promotion_subscription.rake:13、staff_promotion_for_rookie.rake:13）
  - mail: /staff_apps/request/:id（urge_check_out/send_mail_helper.rb:125）、/staff_apps/home_training_rookie_show・home_training_trainer_detail/:id（home_training_schedule.rb:159,165）、/staff_apps/home_training_trainer_list（home_training_participant_cancel_service.rb:44）
  - redirect: /staff_apps/init_pass/:staffId/:passHash（top/confirmations_controller.rb:29）、/staff_apps/guidance_booking（同:32）、/staff_apps/job/:id（staff/actions/jobs_controller.rb:11）、/staff_apps/login・mypage（api/line_staffs_controller.rb:26,77）
  - プッシュ配信は casy-api から直接ではなく MessageQueue.send_message（app/services/message_queue.rb:93）経由で外部 casy-daemon に委譲
- 認証: Cookie セッション（_casy-api_session、40日、config/initializers/session_store.rb:2）。ログインは POST /api/staff/staffs/login（Staff.find_loginable、SHA1+salt、staff.rb:449）。CSRF は null_session（application_controller.rb:12）
- ミドルウェア6種（lib/store.ts:13）: ajax（通信）、analytics（GA スタッフID同期、masquerade 時除外）、hubspot（identify + pageview、masquerade 時除外）、optimize（GTM dataLayer へ push）、saveState（sessionStorage 30分 + localStorage session_id）、sendAction（外部行動ログ）
- LP・コミュニティ・研修等はすべて SPA 内クライアントルート。SPA 外のサーバー HTML は応募者向け Top::Staffhome / Top::StaffEntry のみ（スコープ外）

## スコープ除外（ユーザー決定事項）

- apiv2（routes.rb:1075,1204、app/controllers/apiv2/staff 36ファイル）: 触れない・参照しない・比較しない。捨てるもの
- Top::Staffhome / Top::StaffEntry（応募者向けサーバー HTML）: 対象外
- 見た目（SCSS）・文言: 対象外（スタイルは作り直す）
- ネイティブ iOS/Android アプリ側の仕様: 追って別途
- 実挙動確認: ユーザーが Playwright 環境を用意し、属性別テストアカウントで実画面を開いて確認する前提
