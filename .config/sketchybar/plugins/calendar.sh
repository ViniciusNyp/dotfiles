#!/usr/bin/env bash
# Meeting item fully backed by the official MeetingBar app:
# label mirrors its status item title (Accessibility API), click pops its
# real menu. Hidden when MeetingBar shows nothing or isn't reachable.
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

mb_status_item() {
  # NSStatusItem lands in "menu bar 2" for regular apps, "menu bar 1" for agents
  osascript -e "tell application \"System Events\" to tell process \"MeetingBar\" to $1 menu bar item 1 of menu bar 2" 2>/dev/null && return 0
  osascript -e "tell application \"System Events\" to tell process \"MeetingBar\" to $1 menu bar item 1 of menu bar 1" 2>/dev/null
}

if [ "$1" = "menu" ]; then
  mb_status_item "click" >/dev/null
  exit 0
fi

if LABEL=$(mb_status_item "get title of") && [ -n "$LABEL" ]; then
  case "$LABEL" in *" left)"*) COLOR=$GREEN ;; *) COLOR=$FG ;; esac

  # Fit the label so the meeting island never slides under the notch. It is
  # a standalone island, so only its own width matters: allowed px = current
  # width + slack between its left edge and the notch's right edge (notched
  # display = bar height 38). When hidden, anchor on the right island instead.
  # Hysteresis: shrink on any overflow, regrow only past 24px of slack.
  NOTCH_WIDTH=200  # keep in sync with --bar notch_width
  OVERHEAD=60      # icon + paddings + gap to the right island
  CAP_STATE=/tmp/sketchybar_meeting_cap
  CAP=$(cat "$CAP_STATE" 2>/dev/null)
  CAP=${CAP:-60}
  read -r SLACK MWIDTH <<< "$(jq -rn \
    --argjson m "$(sketchybar --query meeting)" \
    --argjson g "$(sketchybar --query right_island)" \
    --argjson ds "$(sketchybar --query displays)" \
    --arg nw "$NOTCH_WIDTH" '
    (if $m.geometry.drawing == "on"
     then ($m.bounding_rects // {} | to_entries[] | select(.value.size[1] == 38).value)
     else ($g.bounding_rects // {} | to_entries[] | select(.value.size[1] == 38).value
           | {origin: [(.origin[0] - 8), .origin[1]], size: [0, 38]}) end) as $r
    | ($ds[] | select(.frame.x <= $r.origin[0] and $r.origin[0] < .frame.x + .frame.w).frame) as $d
    | "\($r.origin[0] - ($d.x + $d.w/2 + ($nw|tonumber)/2) | floor) \($r.size[0] | floor)"
  ' 2>/dev/null)"
  if [ -n "$SLACK" ]; then
    ALLOWED=$(( (MWIDTH + SLACK - OVERHEAD) / 8 ))
    if [ "$SLACK" -lt 0 ]; then
      CAP=$ALLOWED
    elif [ "$SLACK" -gt 24 ] && [ "$ALLOWED" -gt "$CAP" ]; then
      CAP=$ALLOWED
    fi
    [ "$CAP" -lt 12 ] && CAP=12
    [ "$CAP" -gt 60 ] && CAP=60
    echo "$CAP" > "$CAP_STATE"
  fi

  # Truncate the title, never the countdown ("… in 45m" / "… now (12m left)")
  if [ ${#LABEL} -gt "$CAP" ]; then
    TAIL=""
    HEAD="$LABEL"
    case "$LABEL" in
      *" in "*)   TAIL=" in ${LABEL##* in }"     HEAD="${LABEL% in *}" ;;
      *" now ("*) TAIL=" now (${LABEL##* now (}" HEAD="${LABEL% now (*}" ;;
    esac
    BUDGET=$((CAP - ${#TAIL}))
    [ "$BUDGET" -lt 6 ] && BUDGET=6
    [ ${#HEAD} -gt "$BUDGET" ] && HEAD="${HEAD:0:$((BUDGET - 1))}…"
    LABEL="$HEAD$TAIL"
  fi

  sketchybar --set "$NAME" drawing=on label="$LABEL" label.color=$COLOR icon.color=$COLOR
else
  sketchybar --set "$NAME" drawing=off
fi
