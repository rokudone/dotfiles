#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Restart Aqua Voice
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎤
# @raycast.packageName Aqua Voice

# Documentation:
# @raycast.description Restart Aqua Voice application

APP_NAME="Aqua Voice"

# Quit Aqua Voice if running
if pgrep -x "$APP_NAME" > /dev/null; then
    osascript -e "tell application \"$APP_NAME\" to quit"
    sleep 1
fi

# Launch Aqua Voice
open -a "$APP_NAME"

echo "Aqua Voice restarted"
