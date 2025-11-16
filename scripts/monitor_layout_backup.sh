#!/usr/bin/env bash
#
# monitor_layout_backup.sh
# ------------------------------------------------------------
# Captures current monitor configuration (xrandr output) into
# a JSON file for reproducible GNOME monitor layout restore.
#
# Output:
#   configs/gnome/monitor_layout.json
#
# Logs:
#   logs/monitor_layout_backup_*.log
# ------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$ROOT_DIR/logs"
OUTPUT_DIR="$ROOT_DIR/configs/gnome"
OUTPUT_FILE="$OUTPUT_DIR/monitor_layout.json"

mkdir -p "$LOG_DIR" "$OUTPUT_DIR"

LOG_FILE="$LOG_DIR/monitor_layout_backup_$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_FILE"; }

log "------------------------------------------------------------"
log "Monitor Layout Backup Phase Started"
log "------------------------------------------------------------"

# Ensure xrandr is installed
if ! command -v xrandr &>/dev/null; then
  log "Error: xrandr not found. Cannot capture monitor layout."
  exit 1
fi

# Build JSON structure
echo "{}" > "$OUTPUT_FILE"

CONNECTED=$(xrandr --query | grep " connected" | awk '{print $1}')

for MON in $CONNECTED; do
  MODELINE=$(xrandr --query | grep -A1 "^$MON " | head -n2)
  ENABLED=true

  PRIMARY=false
  echo "$MODELINE" | grep -q "primary" && PRIMARY=true

  GEOM=$(echo "$MODELINE" | grep -oP '\d+x\d+\+\d+\+\d+')
  RES=$(echo "$GEOM" | cut -d+ -f1)
  POS=$(echo "$GEOM" | cut -d+ -f2- | sed 's/+/,/')

  jq --arg mon "$MON" \
     --arg enabled "$ENABLED" \
     --arg primary "$PRIMARY" \
     --arg mode "$RES" \
     --arg pos "$POS" \
     '. + {($mon): {enabled: ($enabled == "true"), primary: ($primary == "true"), mode: $mode, position: $pos}}' \
     "$OUTPUT_FILE" > "$OUTPUT_FILE.tmp"

  mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"

  log "Captured: $MON  mode=$RES  position=$POS  primary=$PRIMARY"
done

log "Monitor layout saved to: $OUTPUT_FILE"

log "Monitor Layout Backup Phase Completed"
log "------------------------------------------------------------"
