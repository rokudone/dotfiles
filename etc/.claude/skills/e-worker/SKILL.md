---
name: e-worker
description: madara E車線の巡回 dispatcher。未着手チケットを検知して PMU-ready まで仕上げる subagent を起動し、PMU 完了結果を durable inbox から回収して採否処理へつなぐ。1 回の呼び出しは冪等な単発 pass で、継続運転は /loop を使う。「実装 worker 起動して」「E-XXX やらせて」「E チケット消化して」「E worker をループして」等で使用。madara 専用。
---

# E worker dispatcher の運用

docs/e-lane-protocol.md に従う E 車線の巡回 dispatcher。実装 worker は計測を
行わず、候補を PMU-ready まで仕上げて `.agent/pmu-queue/` へ積む。
計測係は結果を `.agent/pmu-results/` へ発行する。dispatcher はその結果を
回収して採否処理を完了させる。計測係（pmu-measurer skill）と対になる。

このスキルは worker spawn を明示的に指示する。worker は Agent ツールの
subagent（general-purpose、**model は sonnet を明示指定**、
run_in_background、name はチケット ID）として起動し、subagent に
ファイル編集・ビルド・commit まで行わせてよい。codex exec での起動は
ユーザーが明示した場合の代替手段とする。

## 継続運転

ユーザーがループ運転を指示したら、即時に 1 pass 実行したうえで
`/loop 15m /e-worker` を登録する。ユーザーが間隔を指定した場合はそれを優先する。
各 pass は待機せずに終了する。監視は pass の再実行で行い、skill 内で sleep しない。

ループは次の場合だけ止める。

1. correctness gate 不通過のまま queue 投入されるなど protocol 違反を検出した場合。
2. PMU result が壊れている、同じ ticket に異なる result があるなど自動回復できない場合。
3. counter 不一致、result 欠損、数値不足などで formal mean delta の符号を
   一意に決められず、ユーザー判断が必要な場合。0.5 cyc/局面未満、pair 符号混在、
   build mean overlap だけを `null/unresolved` 停止理由にしない。

## 1 回の呼び出し = 1 reconcile / dispatch pass

このスキルは呼び出しごとに PMU 完了の回収と空き枠の補充を行い、即座に
戻る冪等な単発 pass とする。1 pass では以下だけを行う。

1. dispatcher lock の取得: `.agent/e-worker-dispatch.lock/` を atomic mkdir で
   取得する。既存 lock があれば pass は何もせず「前回 pass 実行中」と報告する。
   stale と判断してよいのは、lock が 30 分以上古く、対応する e-worker pass が
   存在しない場合だけとする。以後の予約と spawn が終わるまで lock を保持し、
   正常終了と異常終了のどちらでも必ず解放する。取得後に `.agent/claims/`、
   `.agent/finalizing/`、`.agent/pmu-results/`、`.agent/pmu-staging/` がなければ作成する。
2. PMU 完了の回収: 先に legacy / crash recovery を行う。E branch / worktree のうち
   claim、queue、result がなく、main に最終判断が未反映で、branch の最新 record commit に
   同じ target SHA、protocol、command、全 run、counter gate、verdict が揃う ticket があれば、
   その commit から `.agent/pmu-results/<ticket>.md` を atomic に復元する。これにより
   durable inbox 導入前の計測係や result publish 前 crash も回収する。その後
   `.agent/finalizing/` に marker が 1 件でもあれば新しい finalizer を spawn しない。
   空なら `.agent/pmu-results/` の `README.md` 以外を
   mtime 順に確認し、対応する `.agent/pmu-queue/<ticket>.md` が存在しない先頭 1 件を
   選ぶ。marker を作成して下記 finalizer を spawn し、spawn に失敗した場合は marker を
   削除する。finalizer は全 ticket を通じて同時 1 名に限定する。queue が残る result は
   計測係の publish 後 cleanup 中または crash recovery 中なので触らない。
   result が残る間は完了を未処理とみなし、last message の上書きに依存しない。
3. 着手中チケットの確認: `.agent/claims/` と実行中の subagent / codex exec を
   突合する。claim があるのに対応する worker がいなければ、claim を先に削除しない。
   対象 branch、worktree、record、queue、result を確認する。作業状態が残っていれば
   同じ claim、branch、worktree を引き継ぐ resume worker を実装 worker 枠で spawn する。
   PMU 前棄却の完成 record が残る場合も resume worker に production code を入れず
   record だけ main へ反映させる。別種の record-only finalizer は作らない。
   状態が何も残っていないと確認できた場合だけ stale claim を削除する。
   `.agent/finalizing/` の stale marker も result と main record を確認してから削除する。
4. 空き枠の計算: 実装 worker は同時 3 名まで（finalizer と計測係は別枠）。
   空きがなければ「満席」と報告して終了する。
5. チケット選定: ユーザー指定の有無にかかわらず、以下の状態 gate を全て通す。
   指定がなければ records/engine/ の最新状態が「Filed only / Not started」で、
   依存（blocked on）が解けているものから選ぶ。古い段落に `Filed only` が残っていても
   後続の判断が complete / rejection / adoption / queued なら未着手と扱わない。
   さらに
   `.agent/claims/`、`.agent/pmu-queue/`、`.agent/pmu-results/`、
   `.agent/finalizing/` のいずれにも存在せず、同 ticket の branch / worktree に
   未回収状態がないものを選ぶ。observation 系は実装系より先に出してよい。
6. spawn 前予約: 空き枠の数だけ `.agent/claims/<TICKET>` を atomic create する。
   中身は開始時刻、worker name、対象 branch、dispatcher reservation とする。
   作成済みなら選定をやり直す。予約成功後に worker を spawn する（下記 prompt の
   `<TICKET>` を置換）。spawn に失敗した場合だけ claim を削除する。
7. 報告は数行にする。finalize を開始した ticket、spawn した ticket、
   継続中 ticket、PMU queue 数、未処理 PMU result 数を記載する。

worker の完了通知を受けたときは last message を検分し、main 先頭と突合
（dispatcher の通常検証）。異常（gate 不通過のまま queue 投入、同じ正式 PMU で
negative 済みの同一候補を根拠なく再投入する等）があれば /loop を止めてユーザーへ
報告する。過去の `do-not-retry` 文言だけを停止理由にしない。

`pmu-measurer-last.txt` は運用状況の表示にだけ使う。PMU 完了の検知には使わない。
このファイルは次の `queue empty` 起動で上書きされるため、通知の正本にはならない。

## PMU result finalizer prompt（subagent へ渡す本文）

```text
あなたは madara E 車線の PMU result finalizer です。対象 result は
<RESULT_PATH>、ticket は <TICKET> です。作業ディレクトリは
/Users/filriya/projects/madara。AGENTS.md、docs/e-lane-protocol.md、result、
result が指す record、対象 branch の PMU commit を読んでください。

最初に result の ticket / branch / record / record-commit / verdict / protocol を
相互照合してください。record-commit が対象 branch に存在し、record に全 run、
expected counter 一致、baseline mean、target mean、target-minus-baseline delta、
符号 verdict が記載されていることを確認してください。
不一致なら何も merge せず result と .agent/finalizing/<TICKET> を残して異常報告します。

verdict ごとの処理:
1. positive: main 先頭へ rebase 可能か確認し、correctness と PMU の根拠を保ったまま
   必要な公式 ledger と record の判断を対象 branch へ追記して commit します。その後
   対象 branch を main へ fast-forward merge します。競合または ledger 更新を一意に
   完了できない場合は merge せず報告します。
2. negative: production code を main へ入れません。対象 ticket の完成 record だけを
   main の records/engine/ へ反映して commit します。
3. counter 不一致、result 欠損、数値不足などで delta の符号を一意に決められない場合:
   production code は main へ入れず、
   完成 record だけを main へ反映して commit します。その後も result と marker を残し、
   loop を止める必要があると報告します。勝手に再試行、採択、撤退を決めません。

0.5 cyc/局面未満、pair 符号混在、build mean overlap は上記 3 の理由ではありません。
formal counter gate が通り数値が揃う場合は、target mean - baseline mean が負なら
positive、正なら negative、厳密な 0 なら non-improving として処理してください。

main に完成 record が存在し、positive の場合は必要なコードも main に存在することを
確認できた場合だけ
<RESULT_PATH> と .agent/finalizing/<TICKET> を削除します。worktree を畳む場合は
対応 record が main に存在することを先に確認します。最終報告は 10 行以内で、
ticket、verdict、record-commit、main commit、採否、result 消化有無、異常を記載します。
```

## worker prompt（subagent へ渡す本文）

```text
あなたは madara の E 車線の実装 worker です。担当チケットは <TICKET> です。
作業ディレクトリは /Users/filriya/projects/madara。着手前に AGENTS.md、
docs/scan-metric-reset.md、docs/e-lane-protocol.md、
records/engine/<TICKET> の記録、直近の records/engine/ を読んで文脈を
回復してください。

最初に dispatcher が作成した .agent/claims/<TICKET> を確認してください。
中身の worker name と対象 branch が自分に一致すれば予約済みとして作業を始めます。
claim がない場合または内容が一致しない場合は二重着手の可能性があるため何もせず
終了して報告します。作業終了時（棄却・完了・queue 投入のいずれでも）に claim を
削除します。

規律（e-lane-protocol の要点）:
- main 先頭を確認し、同番号の作業が既に存在すれば claim を消して終了。
- 着手前に直近 rejection 記録と do-not-retry の根拠を確認する。具体的な同値性失敗、
  または同じ正式 protocol の PMU speed negative を根拠とする同一候補だけを閉じる。
  do-not-retry 文言、ordinary timing、実装形状だけを理由に候補を止めない。
- 観測を実装に先行させる。hot path の分岐・分類、frame size、code size、
  spill / reload、load / store 数、disassembly shape は診断材料に限り terminal gate にしない。
- scan 候補は全局面で完全な最終 action-list 表現を生成する。末端だけの
  省略・遅延は scan-lazy 側として bench 前に棄却する。
- .agent/pmu-lane.lock が存在する間は新しい cargo build を開始しない
  （lock が消えるまで待つか、build 不要の作業を先に進める）。
- baseline は .agent/baseline-pool/<main先頭hash>/ を参照する。entry が
  無ければ自分が一度だけ構築して pool に置く（src/Cargo/build.rs の
  git diff 空を確認してから）。

仕上げの定義（PMU-ready）:
1. 正しさ gate 全通過（release suite、順序差分、counter 閉包、必要なら
   E-119 layer audit と leaf 経路 disasm）。
2. 通常 release の方向 smoke は、CPU が空いているときだけ参考値として実行してよい。
   CPU が他用途で使われている場合は省略して正式 PMU へ進む。通常 release の符号、
   mixed、ばらつきだけを理由に棄却してはならず、速度の採否は正式 PMU だけで決める。
3. target の fresh-PGO artifact を構築し SHA-256 を記録に記載。
4. 実行 command・期待 counter・判定 protocol（通常は standard-n3、追加観測として
   e187-paired も可）を
   記録に記載。
5. queue entry は `.agent/pmu-staging/<TICKET>.md.tmp` に完成形を書き、再読して
   必須 field と SHA を確認した後、rename で .agent/pmu-queue/<TICKET>.md へ
   atomic publish して手離れ。計測と verdict は計測係の仕事。自分では PMU を実行しない。

記録は records/engine/<TICKET> に追記し branch に commit する。record の
保存は採否にかかわらず必須。PMU 前に棄却する場合は production code を main へ入れず、
完成 record だけを main の records/engine/ へ反映して commit してから claim を削除する。
observation 完了時は必要な観測 artifact と record を main へ反映してから claim を削除する。
main への反映に失敗した場合は claim を残して異常報告する。PMU queue 投入時は queue entry の
存在と内容を確認してから claim を削除する。
最終報告は 10 行以内: 記録ファイル名、main の hash、主要数値、
queue 投入の有無、claim 削除済みか、判断。
```

## 注意

- 着手中の可視化は `.agent/claims/<ticket>` が正。dispatcher が spawn 前に
  claim を予約し、worker が終了時に削除する。
- 実装は並列可だが、worktree は `.agent/worktrees/<ticket>` を各自 1 本。
- 却下で終わるチケットは queue に積まず、短式記録だけを main へ保存して終わるのが正常系。
- 観測チケット（kind: observation）は PMU-ready の代わりに「記録完成 +
  merge」で終了してよい。
- 計測係が動いていない場合、queue は溜まるだけで壊れない。pmu-measurer
  skill で着任させる。
