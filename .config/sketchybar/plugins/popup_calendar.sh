#!/usr/bin/env bash
# Toggle a mini month calendar popup under the clock (FelixKratz-style popup).
STATE=$(sketchybar --query clock | /usr/bin/python3 -c \
  "import json,sys; print(json.load(sys.stdin)['popup']['drawing'])" 2>/dev/null)

if [ "$STATE" = "on" ]; then
  sketchybar --set clock popup.drawing=off
  exit 0
fi

sketchybar --remove '/popup\.clock\..*/' 2>/dev/null
i=0
while IFS= read -r line; do
  [ -z "${line// /}" ] && continue
  sketchybar --add item "popup.clock.$i" popup.clock \
    --set "popup.clock.$i" icon.drawing=off label="$line" \
    label.font="Hack Nerd Font:Regular:12.0"
  i=$((i + 1))
done < <(cal)

sketchybar --add item popup.clock.open popup.clock \
  --set popup.clock.open icon.drawing=off label="Open Calendar ↗" \
  click_script="open -a Calendar; sketchybar --set clock popup.drawing=off" \
  --set clock popup.drawing=on
