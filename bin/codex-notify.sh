#!/usr/bin/env bash
set -euo pipefail

payload=${1-}

title="Codex"
subtitle=""
message="Codexからの通知です。"
sound=""

if [ -n "$payload" ]; then
  if parsed=$(PAYLOAD="$payload" /usr/bin/python3 - 2>/dev/null <<'PY')
  then
import json
import os

payload = os.environ.get("PAYLOAD", "")

try:
    data = json.loads(payload)
except json.JSONDecodeError:
    print()
    print()
    print(payload)
    print()
else:
    def pick(*keys):
        for key in keys:
            value = data.get(key)
            if isinstance(value, str) and value.strip():
                return value
        return ""

    print(data.get("title", "Codex"))
    print(data.get("subtitle", ""))
    print(pick("body", "message", "text", "description"))
    print(data.get("sound") or "")
PY
  ); then
    mapfile -t fields <<<"$parsed"
    if [ "${#fields[@]}" -ge 1 ] && [ -n "${fields[0]}" ]; then
      title="${fields[0]}"
    fi
    if [ "${#fields[@]}" -ge 2 ] && [ -n "${fields[1]}" ]; then
      subtitle="${fields[1]}"
    fi
    if [ "${#fields[@]}" -ge 3 ] && [ -n "${fields[2]}" ]; then
      message="${fields[2]}"
    fi
    if [ "${#fields[@]}" -ge 4 ] && [ -n "${fields[3]}" ]; then
      sound="${fields[3]}"
    fi
  else
    message="$payload"
  fi
fi

message=${message//$'\r'/}
message=${message//$'\n'/ }

escape() {
  local value=${1-}
  value=${value//\\/\\\\}
  value=${value//"/\"}
  printf '%s' "$value"
}

escaped_title=$(escape "$title")
escaped_subtitle=$(escape "$subtitle")
escaped_message=$(escape "$message")

/usr/bin/osascript -e 'set volume alert volume 100' >/dev/null 2>&1 || true

if [ -n "$subtitle" ]; then
  /usr/bin/osascript -e "display notification \"$escaped_message\" with title \"$escaped_title\" subtitle \"$escaped_subtitle\"" || true
else
  /usr/bin/osascript -e "display notification \"$escaped_message\" with title \"$escaped_title\"" || true
fi

pick_sound() {
  local name=${1-}
  case "$name" in
    "") echo "Glass" ;;
    "default"|"ping"|"Ping") echo "Ping" ;;
    "glass"|"Glass") echo "Glass" ;;
    "basso"|"Basso") echo "Basso" ;;
    "hero"|"Hero") echo "Hero" ;;
    "submarine"|"Submarine") echo "Submarine" ;;
    *) echo "$name" ;;
  esac
}

sound_name=$(pick_sound "$sound")
sound_file="/System/Library/Sounds/${sound_name}.aiff"

if [ ! -f "$sound_file" ]; then
  sound_file="/System/Library/Sounds/Ping.aiff"
fi

(
  /usr/bin/afplay "$sound_file" >/dev/null 2>&1 &
  sleep 0.35
  /usr/bin/afplay "$sound_file" >/dev/null 2>&1 &
) &

exit 0
