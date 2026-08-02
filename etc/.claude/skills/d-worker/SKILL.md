---
name: d-worker
description: madara D車線（Decision: 探索・評価・学習）の実装 worker を subagent で起動する。gate は対局ベンチで PMU 車線を使わないため E とは独立に並列で回せる。1 回の呼び出しで空き枠を埋める単発 pass 設計なので /loop で回してよい。「D worker 起動して」「D-XXX やらせて」「D チケット消化して」等で使用。madara 専用。
---

# D 実装 worker の運用

AGENTS.md の D 層規律に従う実装 worker の起動手順。D は「どの手を選ぶか・
どの木を読むか・score をどう扱うか」を変える層で、gate は対局ベンチ。
速度 PMU 車線（E 側）とは独立に並列で回せる。

このスキルは worker spawn を明示的に指示する。worker は Agent ツールの
subagent（general-purpose、**model は sonnet を明示指定**、
run_in_background、name はチケット ID）として起動し、ファイル編集・
ビルド・対局ベンチ・commit まで行わせてよい。

## E との違い（重要）

- gate は速度ではなく対局ベンチ。PMU の clean 窓も `.agent/pmu-lane.lock` も
  使わない。E の計測係とは無関係に走れる。
- 対局結果は水物（非決定的）。勝ち越しの見切り（撤退・改善継続・merge）は
  機械に渡さない。worker は対局を回して結果を記録するところまで。
  merge 判断は dispatcher / ユーザーが持つ。ただし classical 系
  （手書き評価スタックへの挑戦）の gate 通過時 merge はユーザー包括承認済み
  （records/decision/classical.md）。
- 学習チケット（NNUE・手形・方策）は対局 gate の前に長い訓練を伴う。
  訓練は GPU/CPU を占有するので、走らせる前に他車線への影響を dispatcher に
  確認してから起動する。

## 1 回の呼び出し = 1 dispatch pass

呼び出しごとに「空き枠を埋めて即座に戻る」冪等な単発 pass。
/loop（例: `/loop 30m /d-worker`）で回すことを想定する。

1. 着手中チケットの確認: `.agent/claims/` の D claim と実行中 subagent を
   突合。stale な claim は削除する（作業は worktree と branch に残る）。
2. 空き枠の計算: D 実装 worker は同時 2 名まで（訓練を伴うチケットは
   GPU/CPU 占有が重いので、訓練中は 1 名に絞る）。空きがなければ「満席」と
   報告して終了。
3. チケット選定: ユーザー指定があればそれ。なければ records/decision/ の
   未着手チケットから、依存が解けていて claim されていないものを選ぶ。
   D 番号の衝突は複数セッションで起きやすいので、着手前に必ず main と
   branch 一覧で既存を確認する。
4. 空き枠の数だけ worker を spawn する。claim 作成は worker に任せる。
5. 報告は数行: spawn したチケット、継続中、対局待ちの有無。

worker の完了通知時は last message を検分し main 先頭と突合。gate 結果
（勝敗・los）が出ていれば、merge 可否は dispatcher が判断する（classical
包括承認の範囲かどうかを確認）。異常時は /loop を止めて報告する。

## worker prompt（subagent へ渡す本文）

```text
あなたは madara の D 車線の実装 worker です。担当チケットは <TICKET> です。
作業ディレクトリは /Users/filriya/projects/madara。着手前に AGENTS.md、
records/decision/classical.md、records/decision/<TICKET> の記録、
直近の records/decision/ を読んで文脈を回復してください。

最初に着手宣言:
- .agent/claims/<TICKET> を作成（開始時刻・自分の name・branch）。
  既に存在したら二重着手なので何もせず終了して報告する。
- 終了時（撤退・完了・gate 結果記録のいずれでも）に claim を削除する。

規律（AGENTS.md D 層）:
- main と branch 一覧を確認し、同番号が既に存在すれば claim を消して終了。
- D は候補手集合・合法手集合・探索木・score・best move を変える層。
  機械的高速化（同じ木・同じ手・同じ score）は E であって D ではない。
  逆に、判断材料を変えずに E へ移せる処理を見つけたら提案する。
- 学習系は機械学習をコードに書く。classical 系は機械学習を混ぜない
  （重み・学習パラメータを使った時点で classical ではない）。
- D / E / O / S の分界を越えない。1 チケット 1 レイヤー。

gate（対局ベンチ、AGENTS.md の手順）:
1. まず速度ベンチで 1 ベンチ 1〜2 分に収まる depth を決める。
2. その depth で先手・後手を入れ替えて 2 局。
3. 2 局が全く同じ局面なら差が出ていない。速度ベンチ結果で判断。
4. 局面が変われば対局数を増やす。五分五分ならさらに増やす。
   classical 系は T=50ms/手 × 2 回の勝ち越しを主 gate、T=10ms は観測。
5. 対局結果（勝-負-分、los、reasons）を記録に残す。merge はしない。
   勝ち越しの見切りと merge は dispatcher / ユーザーの判断。

記録は records/decision/<TICKET> に追記し branch に commit する。
最終報告は 10 行以内: 記録ファイル名、main の hash、gate 結果（勝敗・los）、
merge 可否の判断材料、claim 削除済みか。
```

## 注意

- 着手中の可視化は `.agent/claims/<ticket>`。E と同じディレクトリを共有し、
  D/E どちらの進行中チケットも一覧できる。
- worktree は `.agent/worktrees/<ticket>` を各自 1 本。
- 対局は非決定的なので、gate 結果が五分なら worker が独断で撤退・採用を
  決めず、数値を記録して dispatcher へ返す。
- 訓練を伴うチケットは重い。並列数と GPU/CPU 占有を dispatcher が管理する。
