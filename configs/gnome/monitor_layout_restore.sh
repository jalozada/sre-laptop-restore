#!/usr/bin/env bash
#
# monitor_layout_restore.sh
# ------------------------------------------------------------
# Applies the monitor layout stored in monitor_layout.json.
# Works with xrandr-based multi-monitor setups.
#
# Input:
#   configs/gnome/monitor_layout.json
#
# Logs:
#   logs/monitor_layout_restore_*.log
# ------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
LOG_DIR="$ROOT_DIR/logs"
LAYOUT_FILE="$SCRIPT_DIR/monitor_layout.json"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/monitor_layout_restore_$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_FILE"; }

log "------------------------------------------------------------"
log "Monitor Layout Restore Phase Started"
log "------------------------------------------------------------"

# Validate layout JSON file
if [[ ! -f "$LAYOUT_FILE" ]]; then
  log "Error: monitor_layout.json not found. Skipping."
  exit 0
fi

log "Using layout file: $LAYOUT_FILE"

# Parse monitors from JSON
MONITORS=$(jq -r 'keys[]' "$LAYOUT_FILE")

if [[ -z "$MONITORS" ]]; then
  log "No monitor entries found in JSON. Exiting."
  exit 0
fi

for MON in $MONITORS; do
  ENABLED=$(jq -r ".\"$MON\".enabled" "$LAYOUT_FILE")
  POS=$(jq -r ".\"$MON\".position" "$LAYOUT_FILE")
  MODE=$(jq -r ".\"$MON\".mode" "$LAYOUT_FILE")
  PRIMARY=$(jq -r ".\"$MON\".primary" "$LAYOUT_FILE")

  if [[ "$ENABLED" == "true" ]]; then
    CMD="xrandr --output \"$MON\" --mode \"$MODE\" --pos \"$POS\" --rotate normal"

    if [[ "$PRIMARY" == "true" ]]; then
      CMD="$CMD --primary"
    fi

    log "Applying: $CMD"
    eval $CMD
  else
    log "Disabling monitor: $MON"
    xrandr --output "$MON" --off
  fi
done

log "Monitor Layout Restore Phase Completed"
log "------------------------------------------------------------"
