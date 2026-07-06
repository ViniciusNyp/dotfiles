#!/usr/bin/env bash
# Toggle a network-details popup under the wifi item; click a row to copy it.
STATE=$(sketchybar --query wifi | /usr/bin/python3 -c \
  "import json,sys; print(json.load(sys.stdin)['popup']['drawing'])" 2>/dev/null)

if [ "$STATE" = "on" ]; then
  sketchybar --set wifi popup.drawing=off
  exit 0
fi

IP=$(ipconfig getifaddr en0 2>/dev/null)
ROUTER=$(ipconfig getoption en0 router 2>/dev/null)
HOST=$(hostname -s)

sketchybar --remove '/popup\.wifi\..*/' 2>/dev/null
i=0
for row in "IP: ${IP:-—}" "Router: ${ROUTER:-—}" "Host: $HOST"; do
  VALUE="${row#*: }"
  sketchybar --add item "popup.wifi.$i" popup.wifi \
    --set "popup.wifi.$i" icon.drawing=off label="$row" \
    click_script="printf '%s' '$VALUE' | pbcopy; sketchybar --set wifi popup.drawing=off"
  i=$((i + 1))
done
sketchybar --set wifi popup.drawing=on
