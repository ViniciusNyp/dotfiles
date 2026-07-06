#!/usr/bin/env bash
# Now playing via nowplaying-cli; hides when nothing plays.
TITLE=$(nowplaying-cli get title 2>/dev/null)

if [ -z "$TITLE" ] || [ "$TITLE" = "null" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

ARTIST=$(nowplaying-cli get artist 2>/dev/null)
LABEL="$TITLE"
[ -n "$ARTIST" ] && [ "$ARTIST" != "null" ] && LABEL="$ARTIST — $TITLE"

sketchybar --set "$NAME" drawing=on label="${LABEL:0:40}"
