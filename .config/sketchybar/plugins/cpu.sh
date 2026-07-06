#!/usr/bin/env bash
source "$CONFIG_DIR/colors.sh"

CPU=$(top -l 1 -n 0 | awk '/CPU usage/ {print int($3+$5)}')
[ -z "$CPU" ] && exit 0

COLOR=$FG
[ "$CPU" -ge 80 ] && COLOR=$RED

sketchybar --set "$NAME" label="${CPU}%" label.color=$COLOR
