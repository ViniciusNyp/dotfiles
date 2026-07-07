#!/usr/bin/env bash
# Bluetooth state like the native icon: headphones connected, device
# connected, powered idle, off. blueutil answers in ~50ms so we can poll
# fast; the heavyweight system_profiler minorType lookup runs only when
# the connected-device set changes (cached). Falls back to pure
# system_profiler when blueutil is missing.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
BLUEUTIL=/opt/homebrew/bin/blueutil
CACHE=/tmp/sketchybar_bt_type

set_item() { sketchybar --set "$NAME" icon="$1" icon.color="$2" label.drawing=off; }

headphones_connected() {
  system_profiler SPBluetoothDataType -json 2>/dev/null | /usr/bin/python3 -c "
import json, sys
d = json.load(sys.stdin)['SPBluetoothDataType'][0]
devs = d.get('device_connected', []) or []
types = ' '.join(str(list(x.values())[0].get('device_minorType', '')) for x in devs)
print('yes' if ('Headphones' in types or 'Headset' in types) else 'no')
" 2>/dev/null
}

POWER=$([ -x "$BLUEUTIL" ] && "$BLUEUTIL" --power 2>/dev/null)
if [ "$POWER" = "0" ] || [ "$POWER" = "1" ]; then
  if [ "$POWER" = "0" ]; then
    set_item 󰂲 $DIM
    exit 0
  fi
  ADDRS=$($BLUEUTIL --connected --format json 2>/dev/null | jq -r 'map(.address) | sort | join(",")')
  if [ -z "$ADDRS" ]; then
    set_item 󰂯 $DIM
    exit 0
  fi
  read -r CACHED_ADDRS CACHED_ICON < "$CACHE" 2>/dev/null
  if [ "$CACHED_ADDRS" != "$ADDRS" ] || [ -z "$CACHED_ICON" ]; then
    CACHED_ICON=󰂱
    [ "$(headphones_connected)" = "yes" ] && CACHED_ICON=󰋋
    echo "$ADDRS $CACHED_ICON" > "$CACHE"
  fi
  set_item "$CACHED_ICON" $FG
  exit 0
fi

# fallback: system_profiler only
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
  set_item 󰂲 $DIM
elif [ "${CONNECTED:-0}" -gt 0 ]; then
  ICON=󰂱
  [ "$HEADPHONES" = "yes" ] && ICON=󰋋
  set_item "$ICON" $FG
else
  set_item 󰂯 $DIM
fi
