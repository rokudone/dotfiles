#!/usr/bin/env bash
# Usage: cc-ding.sh <event>
SOUND="/System/Library/Sounds/Glass.aiff"
[ -f "$SOUND" ] || SOUND="/System/Library/Sounds/Pop.aiff"
afplay "$SOUND" >/dev/null 2>&1 &
