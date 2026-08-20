#!/bin/bash
# 現在のワークスペースと、指定方向の隣のモニタに表示中のワークスペースを入れ替える。
# 使い方: swap-workspace-with-monitor.sh left|right|up|down
#
# aerospace には「方向 → モニタID」を引くコマンドが無いので、
# NSScreen の座標から隣のモニタを自前で求める。
# 移動は --workspace で対象を明示した2回だけなので、
# 実行途中のフォーカス位置に依存しない。
set -euo pipefail

direction="${1:?usage: $0 left|right|up|down}"

# "aerospaceID x y w h" を1行ずつ出力する。
# monitor-appkit-nsscreen-screens-id は NSScreen.screens の1始まりの位置を指す。
monitor_geometry() {
  osascript -l JavaScript -e '
    ObjC.import("AppKit");
    $.NSScreen.screens.js.map(function (s) {
      return [s.frame.origin.x, s.frame.origin.y,
              s.frame.size.width, s.frame.size.height].join(" ");
    }).join("\n");
  ' | awk '{ print NR, $0 }' | sort -k1,1 > /tmp/.aerospace-swap-screens.$$

  aerospace list-monitors --format '%{monitor-id} %{monitor-appkit-nsscreen-screens-id}' \
    | sort -k2,2 \
    | join -1 2 -2 1 -o '1.1,2.2,2.3,2.4,2.5' - /tmp/.aerospace-swap-screens.$$

  rm -f /tmp/.aerospace-swap-screens.$$
}

geometry=$(monitor_geometry)
origin=$(aerospace list-monitors --focused --format '%{monitor-id}')

# 焦点モニタの矩形（left bottom right top）。NSScreen の y 軸は上が正。
read -r ol ob or ot <<<"$(printf '%s\n' "$geometry" \
  | awk -v m="$origin" '$1 == m { print $2, $3, $2 + $4, $3 + $5 }')"

# 指定方向にあるモニタのうち、進行方向と直交する軸で重なっていて、
# かつ最も手前にあるものを隣とみなす。中心距離で選ぶと、
# 斜めに置かれた小さいモニタが正面の候補を横取りしてしまう。
target=$(printf '%s\n' "$geometry" | awk -v m="$origin" -v ol="$ol" -v ob="$ob" -v or="$or" -v ot="$ot" -v dir="$direction" '
  $1 == m { next }
  {
    l = $2; b = $3; r = $2 + $4; t = $3 + $5
    if (dir == "right" || dir == "left") { if (t <= ob || b >= ot) next }
    else                                 { if (r <= ol || l >= or) next }
    if (dir == "right") { if (l < or) next; d = l - or }
    if (dir == "left")  { if (r > ol) next; d = ol - r }
    if (dir == "up")    { if (b < ot) next; d = b - ot }
    if (dir == "down")  { if (t > ob) next; d = ob - t }
    if (best == "" || d < best) { best = d; id = $1 }
  }
  END { print id }
')

# その方向にモニタが無ければ何もしない
[ -n "$target" ] || exit 0

here=$(aerospace list-workspaces --monitor "$origin" --visible)
there=$(aerospace list-workspaces --monitor "$target" --visible)

[ -n "$here" ] && [ -n "$there" ] || exit 0
[ "$here" != "$there" ] || exit 0

# 経由用のワークスペースを、交換に関与しないモニタから拾っておく。
# 手順4で必要になる。
bounce=$(printf '%s\n' "$geometry" \
  | awk -v a="$origin" -v b="$target" '$1 != a && $1 != b { print $1; exit }')
[ -n "$bounce" ] && bounce=$(aerospace list-workspaces --monitor "$bounce" --visible)

# 1手目。here が target へ移り、無人になった origin に
# aerospace が空のワークスペースを自動生成する（この生成は防げない）。
aerospace move-workspace-to-monitor --workspace "$here" "$target"

# 2手目。there を origin へ移す。ここで there は target 側で裏に回っているため、
# 移動先でも裏のままとなり、生成された空のワークスペースが表を占め続ける。
aerospace move-workspace-to-monitor --workspace "$there" "$origin"

# 3手目。here は target 側で裏に回っているので、表に出して空のワークスペースを追い出す。
# ただし here が focused と誤認識されていると workspace が no-op になるため、
# 交換に関与しないワークスペースを一度経由してから呼ぶ。
[ -n "$bounce" ] && aerospace workspace "$bounce"
aerospace workspace "$here"
