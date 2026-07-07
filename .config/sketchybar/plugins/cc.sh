#!/usr/bin/env bash
# Open a native Control Center module from the bar: cc.sh <name-pattern> [fallback-url]
# 1) helpers/menus binary — instant SkyLight click with menu-bar unhide; window
#    names verified on Tahoe (probe via sketchybar's Screen Recording identity).
#    Caveat: a renamed window misses silently, so keep names in sync.
# 2) AX via osascript (slower, needs only Accessibility, fails detectably).
# 3) System Settings pane.
PATTERN="$1"
FALLBACK="$2"
MENUS="${CONFIG_DIR:-$HOME/.config/sketchybar}/helpers/menus/bin/menus"

WINDOW="$PATTERN"
case "$PATTERN" in
  Wi) WINDOW="WiFi" ;;
  Control*) WINDOW="BentoBox-0" ;;
esac
[ -x "$MENUS" ] && "$MENUS" -s "Control Center,$WINDOW" && exit 0

# Tahoe stopped exposing "name" on ControlCenter items; "description" works
osascript <<EOF 2>/dev/null && exit 0
tell application "System Events" to tell process "ControlCenter"
  click (first menu bar item of menu bar 1 whose description contains "$PATTERN")
end tell
EOF

[ -n "$FALLBACK" ] && open "$FALLBACK"
