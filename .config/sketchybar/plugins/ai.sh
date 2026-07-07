#!/usr/bin/env bash
# AI agents at a glance: agent-deck session counts (running/waiting) plus a
# best-effort count of agent CLIs (claude/codex/gemini/cursor-agent) started
# outside agent-deck. Orange = an agent is waiting on you.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

RUNNING=0 WAITING=0
HAVE_DECK=0
if command -v agent-deck &> /dev/null; then
  HAVE_DECK=1
  STATUS=$(agent-deck status 2>/dev/null)
  RUNNING=$(grep -oE '[0-9]+ running' <<< "$STATUS" | cut -d' ' -f1)
  WAITING=$(grep -oE '[0-9]+ waiting' <<< "$STATUS" | cut -d' ' -f1)
  RUNNING=${RUNNING:-0} WAITING=${WAITING:-0}
fi

PROCS=0
for bin in claude codex gemini cursor-agent; do
  PROCS=$((PROCS + $(pgrep -x "$bin" 2>/dev/null | wc -l)))
done

if [ "$HAVE_DECK" -eq 1 ]; then
  EXTRA=$((PROCS - RUNNING - WAITING))
  [ "$EXTRA" -lt 0 ] && EXTRA=0
else
  RUNNING=$PROCS EXTRA=0
fi

if [ $((RUNNING + WAITING + EXTRA)) -eq 0 ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

LABEL=""
[ "$RUNNING" -gt 0 ] && LABEL="${RUNNING}▸"
[ "$WAITING" -gt 0 ] && LABEL="${LABEL:+$LABEL }${WAITING}󰏤"
[ "$EXTRA" -gt 0 ] && LABEL="${LABEL:+$LABEL }+${EXTRA}"

COLOR=$FG
[ "$WAITING" -gt 0 ] && COLOR=$ORANGE
sketchybar --set "$NAME" drawing=on label="$LABEL" icon.color=$COLOR label.color=$COLOR
