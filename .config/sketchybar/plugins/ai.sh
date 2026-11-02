#!/usr/bin/env bash
# T3 Code agents, read straight from its local projection DB (read-only, ~10ms).
# ai = robot + running count (green), ai_wait = threads waiting on you (yellow).
# Hover lists the active threads. Hidden when nothing is active or T3 is absent.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
DB="$HOME/.t3/userdata/statev2.sqlite"

active_threads() {
  [ -r "$DB" ] || return
  sqlite3 -readonly -separator $'\t' "$DB" "
    WITH runs AS (
      SELECT thread_id, status FROM orchestration_v2_projection_runs
      WHERE status IN ('queued','preparing','starting','running','waiting')
    ), asks AS (
      SELECT thread_id FROM orchestration_v2_projection_runtime_requests
      WHERE status = 'pending'
    )
    SELECT CASE WHEN t.thread_id IN (SELECT thread_id FROM asks)
                  OR t.thread_id IN (SELECT thread_id FROM runs WHERE status = 'waiting')
                THEN 'wait' ELSE 'run' END, t.title
    FROM orchestration_v2_projection_threads t
    WHERE t.deleted_at IS NULL AND t.archived_at IS NULL
      AND (t.thread_id IN (SELECT thread_id FROM runs) OR t.thread_id IN (SELECT thread_id FROM asks))
    ORDER BY 1 DESC, t.updated_at DESC" 2>/dev/null
}

case "$SENDER" in
  mouse.entered)
    sketchybar --remove '/popup\.ai\..*/' >/dev/null 2>&1
    args=() i=0
    while IFS=$'\t' read -r state title; do
      [ -z "$state" ] && continue
      COLOR=$GREEN
      [ "$state" = wait ] && COLOR=$YELLOW
      args+=(--add item "popup.ai.$i" popup.ai
        --set "popup.ai.$i" icon=● icon.color=$COLOR label="${title:0:50}")
      i=$((i + 1))
    done < <(active_threads)
    [ "$i" -gt 0 ] && sketchybar "${args[@]}" --set ai popup.drawing=on
    exit 0
    ;;
  mouse.exited|mouse.exited.global)
    sketchybar --set ai popup.drawing=off
    exit 0
    ;;
esac

STATES=$(active_threads | cut -f1)
RUNNING=$(grep -c '^run$' <<< "$STATES")
WAITING=$(grep -c '^wait$' <<< "$STATES")

# Polls are the common case: do nothing unless the counts changed
STATE=/tmp/sketchybar_ai_state
read -r PREV_RUNNING PREV_WAITING 2>/dev/null < "$STATE"
[ "$SENDER" = routine ] && [ "$RUNNING $WAITING" = "$PREV_RUNNING $PREV_WAITING" ] && exit 0
echo "$RUNNING $WAITING" > "$STATE"

if [ $((RUNNING + WAITING)) -eq 0 ]; then
  sketchybar --set ai drawing=off --set ai_wait drawing=off
else
  args=(--set ai drawing=on label="${RUNNING}▸")
  [ "$RUNNING" -gt 0 ] && args+=(icon.color=$GREEN label.drawing=on) || args+=(icon.color=$DIM label.drawing=off)
  [ "$WAITING" -gt 0 ] && args+=(--set ai_wait drawing=on label="${WAITING}󰏤") || args+=(--set ai_wait drawing=off)
  sketchybar "${args[@]}"
fi

# the island width changed; refit the meeting label to the notch (AX call, keep rare)
NAME=meeting "$CONFIG_DIR/plugins/calendar.sh" >/dev/null 2>&1 &

# flash the island when something new starts waiting on you
if [ "$WAITING" -gt "${PREV_WAITING:-0}" ]; then
  for _ in 1 2; do
    sketchybar --animate tanh 8 --set right_island background.color=$YELLOW
    sleep 0.35
    sketchybar --animate tanh 8 --set right_island background.color=$ISLAND
    sleep 0.35
  done
fi
