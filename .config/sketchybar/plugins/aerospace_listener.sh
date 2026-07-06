#!/usr/bin/env bash
# Single listener updates every workspace pill in one batched call:
# one aerospace query per event, no per-item races (koenvangilst pattern),
# with app-icon ligatures per pill (zackreed pattern).
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
PLUGIN_DIR="$CONFIG_DIR/plugins"

FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
WINDOWS=$(aerospace list-windows --all --format '%{workspace}|%{app-name}' 2>/dev/null)

args=()
for sid in $(aerospace list-workspaces --all); do
  APPS=$(printf '%s\n' "$WINDOWS" | awk -F'|' -v ws="$sid" '$1==ws {print $2}' | sort -u)
  ICONS=""
  while IFS= read -r app; do
    [ -z "$app" ] && continue
    ICONS+="$("$PLUGIN_DIR/icon_map.sh" "$app") "
  done <<< "$APPS"
  ICONS="${ICONS% }"
  LABEL_DRAWING=off
  [ -n "$ICONS" ] && LABEL_DRAWING=on

  if [ "$sid" = "$FOCUSED" ]; then
    # inverted pill: white capsule, dark text (koenvangilst focus style)
    args+=(--set "space.$sid" drawing=on label="$ICONS" label.drawing=$LABEL_DRAWING
      background.drawing=on background.color=$FG
      icon.color=$INVERT label.color=$INVERT)
  elif [ -n "$APPS" ]; then
    args+=(--set "space.$sid" drawing=on label="$ICONS" label.drawing=$LABEL_DRAWING
      background.drawing=off icon.color=$DIM label.color=$DIM)
  else
    args+=(--set "space.$sid" drawing=off)
  fi
done

sketchybar --animate tanh 15 "${args[@]}"
