#!/usr/bin/env bash
# Click menu bar item $1 of the frontmost app (1 = Apple menu, 2 = app menu).
# The bar never takes focus, so "frontmost" is the app the user is using.
# Primary: compiled helpers/menus binary (SkyLight PSN lookup, raw AX children
# where 0 = Apple menu). Fallback: AX via osascript.
IDX="${1:-2}"
MENUS="${CONFIG_DIR:-$HOME/.config/sketchybar}/helpers/menus/bin/menus"

[ -x "$MENUS" ] && "$MENUS" -s "$((IDX - 1))" && exit 0
osascript -e "tell application \"System Events\" to tell (first process whose frontmost is true) to click menu bar item $IDX of menu bar 1" 2>/dev/null
