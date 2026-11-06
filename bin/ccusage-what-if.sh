#!/usr/bin/env bash
#
# ccusage-what-if.sh
#
# あるモデルで使った実績を「もし別のモデルを使っていたら」に置き換えて
# ccusage で試算する。元のログには一切触れず、一時ディレクトリへ
# セッションログだけをコピーした上でモデル名を差し替える。
#
# usage: ccusage-what-if.sh [--since YYYY-MM-DD] [--until YYYY-MM-DD]
#                           [--from MODEL] [--to MODEL]
#                           [--period daily|monthly|session]
#                           [--json] [--keep] [--baseline]

set -euo pipefail

FROM_MODEL="accounts/fireworks/models/deepseek-v4-flash-0731"
TO_MODEL="gpt-5.6-sol"
PERIOD="daily"
SINCE=""
UNTIL=""
JSON=""
KEEP=0
BASELINE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --since)    SINCE="$2"; shift 2 ;;
    --until)    UNTIL="$2"; shift 2 ;;
    --from)     FROM_MODEL="$2"; shift 2 ;;
    --to)       TO_MODEL="$2"; shift 2 ;;
    --period)   PERIOD="$2"; shift 2 ;;
    --json)     JSON=1; shift ;;
    --keep)     KEEP=1; shift ;;
    --baseline) BASELINE=1; shift ;;
    -h|--help)  sed -n '2,14p' "$0" | sed 's/^#\{1,\} \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

SRC="${CODEX_HOME:-$HOME/.codex}"
[[ -d "$SRC/sessions" ]] || { echo "sessions not found: $SRC/sessions" >&2; exit 1; }

run_ccusage() {
  local home="$1"
  local args=(codex "$PERIOD")
  [[ -n "$SINCE" ]] && args+=(--since "$SINCE")
  [[ -n "$UNTIL" ]] && args+=(--until "$UNTIL")
  [[ -n "$JSON"  ]] && args+=(--json)
  CODEX_HOME="$home" npx -y ccusage@latest "${args[@]}"
}

if [[ $BASELINE -eq 1 ]]; then
  echo "### baseline (実績)" >&2
  run_ccusage "$SRC"
  echo >&2
fi

WORK="$(mktemp -d "${TMPDIR:-/tmp}/ccusage-what-if.XXXXXX")"
[[ $KEEP -eq 0 ]] && trap 'rm -rf "$WORK"' EXIT

# セッションログだけをコピーする。auth.json などの機密ファイルは持ち込まない。
mkdir -p "$WORK/sessions"
( cd "$SRC/sessions" && find . -name '*.jsonl' -print0 | cpio -pd0 --quiet "$WORK/sessions" )

# モデル名は JSON 文字列としてそのまま現れるため固定文字列置換で足りる。
# 区切りに | を使い、モデル ID 中の / をエスケープ不要にする。
# BSD sed は -i '' が xargs 経由で壊れるため -i.bak を使って後で消す。
COUNT=$(grep -rl --fixed-strings "$FROM_MODEL" "$WORK/sessions" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$COUNT" -gt 0 ]]; then
  grep -rlZ --fixed-strings "$FROM_MODEL" "$WORK/sessions" \
    | xargs -0 sed -i.bak "s|${FROM_MODEL}|${TO_MODEL}|g"
  find "$WORK/sessions" -name '*.bak' -delete
fi

echo "### what-if: ${FROM_MODEL} -> ${TO_MODEL} (${COUNT} files)" >&2
[[ $KEEP -eq 1 ]] && echo "workdir: $WORK" >&2
run_ccusage "$WORK"
