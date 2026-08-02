---
name: pmu-measurer
description: madara E車線の計測係（空の PMU queue でも終了せず待機し、直列消化する常駐 codex exec worker）を起動・再起動・停止する。「計測係を起動して」「PMU queue 回して」「計測係止めて」等で使用。madara 専用。
---

# PMU 計測係の運用

docs/e-lane-protocol.md「PMU queue 運用」の計測係を codex exec 常駐 worker として
運用する手順。queue は `.agent/pmu-queue/`、lock は `.agent/pmu-lane.lock`、
完了結果の durable inbox は `.agent/pmu-results/`（いずれも
/Users/filriya/projects/madara 配下）。

## 起動手順

1. 既存の計測係がいないことを確認する。1 コマンドずつ実行する。

   ```
   pgrep -fl "codex exec"
   ```

   計測係らしきプロセスが既にいれば起動しない（二重化は lock 運用を壊す）。

2. stale lock を確認する。`.agent/pmu-lane.lock` が存在するのに
   `pgrep -x xctrace` と手順 1 が両方空なら、lock は残骸なので削除してよい。
   queue 処理時の本当の排他は下記 worker が atomic mkdir で取得する。

3. Write ツールで prompt ファイルを作成する（パス:
   `/Users/filriya/projects/madara/.agent/pmu-measurer-prompt.txt`、内容は
   下記「worker prompt」全文）。

4. 背景起動する（run_in_background）:

   ```
   codex exec -C /Users/filriya/projects/madara -s danger-full-access -o /Users/filriya/projects/madara/.agent/pmu-measurer-last.txt - < /Users/filriya/projects/madara/.agent/pmu-measurer-prompt.txt
   ```

   PMU 計測では process list、Instruments cache、DTServiceHub への接続が必要になる。
   `workspace-write` では `pgrep` と `xctrace` が失敗するため、この設定を
   `workspace-write` へ戻して起動しない。

5. worker は queue が空でも終了せず、10 秒間隔で次の entry を待つ。
   背景タスクの終了通知は正常な空 queue を意味しない。
   `.agent/pmu-measurer-last.txt` と process 状態を確認し、明示停止でなければ
   異常終了としてユーザーへ報告する。原因を確認せず自動再起動を繰り返さない。

last message は上書きされる運用表示であり、完了通知の正本にしない。
e-worker への handoff は `.agent/pmu-results/` だけを使う。

## worker prompt

以下を prompt ファイルの全文とする。

```text
あなたは madara の E 車線の計測係です。docs/e-lane-protocol.md の
「PMU queue 運用」節と AGENTS.md を読んでから作業してください。
このプロセス自身が計測 worker です。pmu-measurer skill の呼び出しや
別の `codex exec` の起動は行わず、自分で以下の queue 処理を実行してください。

常駐 loop で行うこと:
1. `.agent/pmu-results/` と `.agent/pmu-result-staging/` がなければ作成する。
   queue 確認前に `.agent/pmu-queue-check.txt` と
   `.agent/pmu-queue-check.txt.tmp` を削除する。
   その後 `.agent/pmu-queue/` を確認する。README.md 以外の entry がなければ、
   `sleep 10` 後の再確認を同じ shell invocation 内で無期限に続ける。
   queue が空であることを理由に process を終了しない。確認 loop と entry の確定は
   同じ shell invocation 内で実行し、`entry` を別 shell にまたがせない。
   実行する式は次の全文とし、分割・追加確認・表示用の式追加は禁止する。
   `while true; do entry=$(rg --files .agent/pmu-queue | rg -v '/README\.md$' | head -n 1); if [[ -n "$entry" ]]; then print -r -- "$entry" > .agent/pmu-queue-check.txt.tmp; mv .agent/pmu-queue-check.txt.tmp .agent/pmu-queue-check.txt; sed -n '1p' .agent/pmu-queue-check.txt; break; fi; sleep 10; done`
   tool 層が `Script running`、session ID、cell ID、pending など process 継続中を示した場合は
   stdout 欠落として扱わない。同じ session を poll し、process exit まで待つ。process 完了前に
   `.agent/pmu-queue-check.txt` を読んではならない。process 完了後に shell stdout が得られれば
   それだけを正とする。process 完了後も stdout が空だった場合だけ
   `.agent/pmu-queue-check.txt` を一度読み、その1行を正とする。queue の再検索は禁止する。
   tool が表示する wall time、worker が感じた待機時間、途中経過から process 終了や
   entry の有無を推測してはならない。待機中の session を自分から terminate しない。
   判定ファイルが存在しないまま shell process が終了した場合だけ異常として扱う。
   entry path が出力されたら、その path を再検索せず以後の処理へ渡す。
2. entry があれば `.agent/pmu-lane.lock/` を atomic mkdir で排他取得する。
   取得できなければ別の計測係がいるため何も測らず終了する。取得後は directory 内の
   owner ファイルへ自分の PID と開始時刻を書く。以後 queue が空になるまで直列に消化する。
3. 各 entry について priority 順（同値は mtime 順）に選ぶ。測定前に同 ticket の
   `.agent/pmu-results/<ticket>.md` を確認する。result が entry と同じ branch、record、
   target-sha256、protocol、commands、expected-counters を持ち、record-commit が branch 上に
   あれば既に測定済みなので再測定せず queue entry を削除する。result がなくても record に
   同じ target-sha256、protocol、commands、expected-counters に対する完了済みの全 run、
   counter gate、verdict が commit 済みなら、
   その commit から result を復元して再測定しない。
   既存 result と entry が矛盾する場合は entry を残して異常報告する。
4. 未測定 entry は実行直前に
   cargo / rustc / madara / xctrace の競合プロセスが無いことを確認し、
   entry 記載の command を pmu-judge の clean 窓で protocol 指定
   （standard-n3 または e187-paired）どおりに実行する。
5. 全 run の counter が entry の expected-counters と一致することを確認する。
   不一致の run は無効とし、その旨を記録に書く。
6. 結果（各 run の PMU cyc/局面、baseline mean、target mean、sd、
   target-minus-baseline delta、符号 verdict）を entry 記載の
   record ファイルへ追記し、branch に commit する。merge はしない。
   採択判断・帳簿更新は dispatcher の仕事なので行わない。
   formal counter gate が通り数値が揃う場合、delta が負なら positive、正なら
   negative、厳密な 0 なら non-improving とする。0.5 cyc/局面未満、pair 符号混在、
   build mean overlap だけを理由に再queueまたは `null/unresolved` にしない。
7. record commit 成功後、`.agent/pmu-results/<ticket>.md` を durable handoff として
   発行する。先に `.agent/pmu-result-staging/<ticket>.md.tmp` へ書き、rename で
   results directory へ公開する。必須項目は
   ticket / branch / record / record-commit / verdict / protocol / measured-at /
   commands / expected-counters / target-sha256 / counter-gate / summary とする。
   既存 result が同じ record-commit と verdict なら再発行済みとして続行する。内容が異なる場合は
   queue entry を削除せず異常報告する。
8. result の存在と内容を再読して確認した後だけ、消化した queue entry を削除する。
   queue が空になったら lock を削除し、手順 1 の待機へ戻る。lock を保持したまま
   空 queue を待たない。計測係 process は終了させない。これにより e-worker が
   result を後から確実に回収でき、次の entry も同じ worker が受け取れる。
9. 明示停止または回復不能な異常で終了するときだけ last message を 10 行以内にする。
   消化した ticket 一覧、各 verdict、発行した result、main 先頭 hash、異常の有無を書く。

厳守: lock 保持中も自分は build してよいが（target は構築済みのはず）、
entry に成果物が無い・SHA が合わない場合はその entry を skip して
理由を last message に書く。PMU 窓には被測定 command 本体だけを入れる。
result 発行前に queue entry を削除しない。
```

## 停止手順

1. `pgrep -fl "codex exec"` で対象 PID を特定して `kill <PID>`。
2. `.agent/pmu-lane.lock` が残っていれば削除する。
3. result 未発行の entry は queue に残るのでそのまま次回に引き継がれる。
   発行済み result は `.agent/pmu-results/` に残り、e-worker が回収する。

## 注意

- 計測係は常に 1 名。起動前の重複確認を省略しない。
- worker が lock directory を残したまま死んだ場合、stale lock の判定は
  「lock があるのに codex exec も xctrace もいない」こと。
- queue entry の書式は `.agent/pmu-queue/README.md` を正とする。
- PMU result は e-worker が main への採否処理を完了するまで削除しない。
