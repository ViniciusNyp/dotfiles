#!/usr/bin/env bash
# Meeting item fully backed by the official MeetingBar app:
# label mirrors its status item title (Accessibility API), click pops its
# real menu. Hidden when MeetingBar shows nothing or isn't reachable.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

mb_status_item() {
  # NSStatusItem lands in "menu bar 2" for regular apps, "menu bar 1" for agents
  osascript -e "tell application \"System Events\" to tell process \"MeetingBar\" to $1 menu bar item 1 of menu bar 2" 2>/dev/null && return 0
  osascript -e "tell application \"System Events\" to tell process \"MeetingBar\" to $1 menu bar item 1 of menu bar 1" 2>/dev/null
}

if [ "$1" = "menu" ]; then
  mb_status_item "click" >/dev/null
  exit 0
fi

if LABEL=$(mb_status_item "get title of") && [ -n "$LABEL" ]; then
  case "$LABEL" in *" left)"*) COLOR=$GREEN ;; *) COLOR=$FG ;; esac
  sketchybar --set "$NAME" drawing=on label="$LABEL" label.color=$COLOR icon.color=$COLOR
else
  sketchybar --set "$NAME" drawing=off
fi
