#!/usr/bin/env bash
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

FREE=$(memory_pressure | awk '/System-wide memory free percentage/ {gsub("%",""); print $NF}')
[ -z "$FREE" ] && exit 0
USED=$((100 - FREE))

COLOR=$FG
[ "$USED" -ge 85 ] && COLOR=$RED

sketchybar --set "$NAME" label="${USED}%" label.color=$COLOR
