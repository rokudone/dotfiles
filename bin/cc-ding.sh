#!/usr/bin/env bash
set -euo pipefail

SOUND="/System/Library/Sounds/Glass.aiff"
DEFAULT_MESSAGE="${CC_DING_MESSAGE:-Task completed}"
MESSAGE="${1:-$DEFAULT_MESSAGE}"
TITLE="${CC_DING_TITLE:-cc-ding}"

afplay "$SOUND" >/dev/null 2>&1 &

MESSAGE="$MESSAGE" TITLE="$TITLE" osascript <<'APPLESCRIPT'
set messageText to system attribute "MESSAGE"
set titleText to system attribute "TITLE"
display notification messageText with title titleText
APPLESCRIPT
