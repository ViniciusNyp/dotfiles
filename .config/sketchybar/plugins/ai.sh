#!/usr/bin/env bash
# AI agents trio: ai = robot + running count (green), ai_wait = waiting count
# (yellow, an agent needs input), ai_extra = best-effort count of agent CLIs
# (claude/codex/gemini/cursor-agent) outside agent-deck (dim). Claude Code
# hooks trigger ai_change for instant updates; the island flashes when the
# waiting count rises. Degrades to a pure process count without agent-deck.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

RUNNING=0 WAITING=0 IDLE=0
HAVE_DECK=0
if command -v agent-deck &> /dev/null; then
  HAVE_DECK=1
  STATUS=$(agent-deck status 2>/dev/null)
  RUNNING=$(grep -oE '[0-9]+ running' <<< "$STATUS" | cut -d' ' -f1)
  WAITING=$(grep -oE '[0-9]+ waiting' <<< "$STATUS" | cut -d' ' -f1)
  IDLE=$(grep -oE '[0-9]+ idle' <<< "$STATUS" | cut -d' ' -f1)
  RUNNING=${RUNNING:-0} WAITING=${WAITING:-0} IDLE=${IDLE:-0}
fi

PROCS=0
for bin in claude codex gemini cursor-agent; do
  PROCS=$((PROCS + $(pgrep -x "$bin" 2>/dev/null | wc -l)))
done

if [ "$HAVE_DECK" -eq 1 ]; then
  # idle deck sessions keep their agent process alive; they are tracked, not extras
  EXTRA=$((PROCS - RUNNING - WAITING - IDLE))
  [ "$EXTRA" -lt 0 ] && EXTRA=0
else
  RUNNING=$PROCS EXTRA=0
fi

if [ $((RUNNING + WAITING + EXTRA)) -eq 0 ]; then
  sketchybar --set ai drawing=off --set ai_wait drawing=off --set ai_extra drawing=off
  exit 0
fi

ICON_COLOR=$DIM
[ "$RUNNING" -gt 0 ] && ICON_COLOR=$GREEN
args=(--set ai drawing=on icon.color=$ICON_COLOR label="${RUNNING}▸")
[ "$RUNNING" -gt 0 ] && args+=(label.drawing=on) || args+=(label.drawing=off)
if [ "$WAITING" -gt 0 ]; then
  args+=(--set ai_wait drawing=on label="${WAITING}󰏤")
else
  args+=(--set ai_wait drawing=off)
fi
if [ "$EXTRA" -gt 0 ]; then
  args+=(--set ai_extra drawing=on label="+${EXTRA}")
else
  args+=(--set ai_extra drawing=off)
fi
sketchybar "${args[@]}"

# flash the island when something new starts waiting on the user
STATE=/tmp/sketchybar_ai_waiting
PREV=$(cat "$STATE" 2>/dev/null || echo 0)
echo "$WAITING" > "$STATE"
if [ "$WAITING" -gt "${PREV:-0}" ]; then
  for _ in 1 2; do
    sketchybar --animate tanh 8 --set right_island background.color=$YELLOW
    sleep 0.35
    sketchybar --animate tanh 8 --set right_island background.color=$ISLAND
    sleep 0.35
  done
fi
