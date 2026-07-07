#!/usr/bin/env bash
# Now playing via nowplaying-cli; hides when nothing plays, dims when paused.
# The item flows after the left island; the label is truncated to exactly the
# space remaining before the notch on the built-in display.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
NOTCH_WIDTH=200      # keep in sync with --bar notch_width in sketchybarrc
NOTCH_BAR_HEIGHT=38  # keep in sync with --bar notch_display_height
PX_PER_CHAR=8        # Hack Bold 13 average advance
ITEM_OVERHEAD=60     # icon + paddings + gap to the left island

TITLE=$(nowplaying-cli get title 2>/dev/null)
if [ -z "$TITLE" ] || [ "$TITLE" = "null" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

ARTIST=$(nowplaying-cli get artist 2>/dev/null)
LABEL="$TITLE"
[ -n "$ARTIST" ] && [ "$ARTIST" != "null" ] && LABEL="$ARTIST — $TITLE"

# Fit the label to the gap on the notched display; 45 when it can't be measured
CHARS=$(jq -rn --argjson fa "$(sketchybar --query front_app)" \
               --argjson ds "$(sketchybar --query displays)" \
               --arg nw "$NOTCH_WIDTH" --arg bh "$NOTCH_BAR_HEIGHT" \
               --arg oh "$ITEM_OVERHEAD" --arg pc "$PX_PER_CHAR" '
  ($fa.bounding_rects // {} | to_entries[]
    | select(.value.size[1] == ($bh|tonumber)).value) as $r
  | ($ds[] | select(.frame.x <= $r.origin[0]
      and $r.origin[0] < .frame.x + .frame.w).frame) as $d
  | ($d.x + $d.w/2 - ($nw|tonumber)/2) - ($r.origin[0] + $r.size[0]) - ($oh|tonumber)
  | (. / ($pc|tonumber) | floor)
  | if . < 10 then 10 elif . > 70 then 70 else . end
' 2>/dev/null)
case "$CHARS" in ''|*[!0-9]*) CHARS=45 ;; esac

[ ${#LABEL} -gt "$CHARS" ] && LABEL="${LABEL:0:$((CHARS - 1))}…"

RATE=$(nowplaying-cli get playbackRate 2>/dev/null)
case "$RATE" in
  ''|null|0|0.*) ICON=󰏤 LABEL_COLOR=$DIM ;;
  *)             ICON=󰝚 LABEL_COLOR=$FG ;;
esac
sketchybar --set "$NAME" drawing=on label="$LABEL" icon="$ICON" label.color=$LABEL_COLOR
