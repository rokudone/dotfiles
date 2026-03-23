#!/bin/sh

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
AEROSPACE_BIN="/opt/homebrew/bin/aerospace"
SKETCHYBAR_BIN="/opt/homebrew/bin/sketchybar"

for i in 1 2 3 4 5 6 7 8 9 10; do
  name="space.$i"
  display_mask="$("$SKETCHYBAR_BIN" --query "$name" 2>/dev/null | awk -F': ' '/"associated_display_mask"/ { gsub(/[^0-9]/, "", $2); print $2; exit }')"
  if [ -z "$display_mask" ]; then
    continue
  fi

  display_index=0
  value="$display_mask"
  while [ "$value" -gt 1 ]; do
    value=$((value / 2))
    display_index=$((display_index + 1))
  done

  if [ "$display_index" -le 0 ]; then
    continue
  fi

  workspace="$("$AEROSPACE_BIN" list-workspaces --monitor "$display_index" --visible --format '%{workspace}' 2>/dev/null | head -n 1)"
  if [ -z "$workspace" ]; then
    workspace="-"
  fi

  "$SKETCHYBAR_BIN" --set "$name" icon.string="$workspace"
done
