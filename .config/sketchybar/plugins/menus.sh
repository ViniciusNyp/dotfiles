#!/usr/bin/env bash
# Click menu bar item $1 of the frontmost app (1 = Apple menu, 2 = app menu).
# The bar never takes focus, so "frontmost" is the app the user is using.
IDX="${1:-2}"
osascript -e "tell application \"System Events\" to tell (first process whose frontmost is true) to click menu bar item $IDX of menu bar 1" 2>/dev/null
