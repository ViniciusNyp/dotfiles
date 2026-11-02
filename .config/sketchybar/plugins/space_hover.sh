#!/usr/bin/env bash
# Hover popup listing the windows of a workspace. $1 = workspace id.
SID="$1"
ITEM="space.$SID"

case "$SENDER" in
  mouse.entered)
    sketchybar --remove "/popup\.$ITEM\..*/" >/dev/null 2>&1
    i=0
    while IFS='|' read -r wid app title; do
      [ -z "$wid" ] && continue
      LABEL="$app"
      [ -n "$title" ] && [ "$title" != "$app" ] && LABEL="$app — ${title:0:30}"
      sketchybar --add item "popup.$ITEM.$i" "popup.$ITEM" \
        --set "popup.$ITEM.$i" icon.drawing=off label="$LABEL"
      i=$((i + 1))
    done < <(aerospace list-windows --workspace "$SID" --format '%{window-id}|%{app-name}|%{window-title}' 2>/dev/null)
    [ "$i" -gt 0 ] && sketchybar --set "$ITEM" popup.drawing=on
    ;;
  mouse.exited|mouse.exited.global)
    sketchybar --set "$ITEM" popup.drawing=off
    ;;
esac
