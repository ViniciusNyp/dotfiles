#!/usr/bin/env bash
# Open a native Control Center module from the bar: cc.sh <name-pattern> [fallback-url]
# AX-clicks the ControlCenter menu bar item whose name contains the pattern
# (pops the native dropdown, works with the menu bar hidden).
# Falls back to a System Settings pane when Accessibility is not granted.
PATTERN="$1"
FALLBACK="$2"

# Tahoe stopped exposing "name" on ControlCenter items; "description" works
osascript <<EOF 2>/dev/null
tell application "System Events" to tell process "ControlCenter"
  click (first menu bar item of menu bar 1 whose description contains "$PATTERN")
end tell
EOF

if [ $? -ne 0 ] && [ -n "$FALLBACK" ]; then
  open "$FALLBACK"
fi
