#!/usr/bin/env bash
# Bluetooth state like the native icon: headphones connected, device
# connected, powered idle, off.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

read -r STATE CONNECTED HEADPHONES <<< "$(system_profiler SPBluetoothDataType -json 2>/dev/null | /usr/bin/python3 -c "
import json, sys
d = json.load(sys.stdin)['SPBluetoothDataType'][0]
state = d.get('controller_properties', {}).get('controller_state', '')
devs = d.get('device_connected', []) or []
types = ' '.join(str(list(x.values())[0].get('device_minorType', '')) for x in devs)
hp = 'yes' if ('Headphones' in types or 'Headset' in types) else 'no'
print(state, len(devs), hp)
" 2>/dev/null)"

if [ "$STATE" != "attrib_on" ]; then
  sketchybar --set "$NAME" icon=󰂲 icon.color=$DIM label.drawing=off
elif [ "${CONNECTED:-0}" -gt 0 ]; then
  ICON=󰂱
  [ "$HEADPHONES" = "yes" ] && ICON=󰋋
  sketchybar --set "$NAME" icon="$ICON" icon.color=$FG label.drawing=off
else
  sketchybar --set "$NAME" icon=󰂯 icon.color=$DIM label.drawing=off
fi
