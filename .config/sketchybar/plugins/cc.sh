#!/usr/bin/env bash
# Open a native Control Center module from the bar: cc.sh <name-pattern> [fallback-url]
# 1) AX-click the ControlCenter item whose description matches (native dropdown,
#    works with the menu bar hidden; fails detectably).
# 2) helpers/menus binary — SkyLight menu-bar unhide around the click; its
#    window-name match needs Screen Recording and misses silently, so it runs second.
# 3) System Settings pane.
PATTERN="$1"
FALLBACK="$2"
MENUS="${CONFIG_DIR:-$HOME/.config/sketchybar}/helpers/menus/bin/menus"

# Tahoe stopped exposing "name" on ControlCenter items; "description" works
osascript <<EOF 2>/dev/null && exit 0
tell application "System Events" to tell process "ControlCenter"
  click (first menu bar item of menu bar 1 whose description contains "$PATTERN")
end tell
EOF

WINDOW="$PATTERN"
[ "$PATTERN" = "Wi" ] && WINDOW="WiFi"
[ -x "$MENUS" ] && "$MENUS" -s "Control Center,$WINDOW" && exit 0

[ -n "$FALLBACK" ] && open "$FALLBACK"
