#!/usr/bin/env bash
# Clock label; hover shows a mini month calendar.
case "$SENDER" in
  mouse.entered)
    sketchybar --remove '/popup\.clock\..*/' >/dev/null 2>&1
    args=() i=0
    while IFS= read -r line; do
      [ -z "${line// /}" ] && continue
      args+=(--add item "popup.clock.$i" popup.clock
        --set "popup.clock.$i" icon.drawing=off label="$line" label.font="Hack Nerd Font:Regular:12.0")
      i=$((i + 1))
    done < <(cal)
    sketchybar "${args[@]}" --set clock popup.drawing=on
    ;;
  mouse.exited|mouse.exited.global)
    sketchybar --set clock popup.drawing=off
    ;;
  *)
    sketchybar --set "$NAME" label="$(date '+%a %d/%m %H:%M')"
    ;;
esac
