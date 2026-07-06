#!/usr/bin/env bash
# Network state like the native icon: wired uplink, wifi connected,
# wifi on without network, wifi off.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
WIFI_IF=en0

ROUTE_IF=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')
if [ -n "$ROUTE_IF" ] && [ "$ROUTE_IF" != "$WIFI_IF" ]; then
  sketchybar --set "$NAME" icon=󰈀 icon.color=$FG label.drawing=off
  exit 0
fi

if networksetup -getairportpower $WIFI_IF 2>/dev/null | grep -q ": On"; then
  if [ -n "$(ipconfig getifaddr $WIFI_IF 2>/dev/null)" ]; then
    sketchybar --set "$NAME" icon=󰖩 icon.color=$FG label.drawing=off
  else
    sketchybar --set "$NAME" icon=󰖩 icon.color=$DIM label.drawing=off
  fi
else
  sketchybar --set "$NAME" icon=󰖪 icon.color=$DIM label.drawing=off
fi
