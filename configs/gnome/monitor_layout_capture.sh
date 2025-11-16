#!/usr/bin/env bash
#
# monitor_layout_capture.sh
# --------------------------------------------------------------------
# Captures the current monitor layout using xrandr and stores the
# configuration in JSON format.
#
# This scaffold version:
#   - Detects monitors
#   - Parses geometry, refresh rate, primary flag, rotation
#   - Writes JSON snapshot to configs/gnome/monitor_layout.json
#
# Logs: configs/gnome/logs/monitor_layout_capture_*.log
# --------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$HOME/repos/sre-laptop-restore"
LOG_DIR="$SCRIPT_DIR/logs"
OUTPUT_FILE="$SCRIPT_DIR/monitor_layout.json"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/monitor_layout_capture_$(date +%Y%m%d_%H%M%S).log"

# Load logging utility
source "$ROOT_DIR/scripts/log.sh"

log_info "--------------------------------------------------------"
log_info "SRE Laptop Restore – Monitor Layout Capture (Scaffold)"
log_info "Start: $(date)"
log_info "--------------------------------------------------------"

# --- Phase 1: Check xrandr availability ----------------------------------------
log_info "[1/4] Checking for xrandr..."
if command -v xrandr >/dev/null 2>&1; then
    log_info "xrandr detected."
else
    log_error "xrandr NOT installed. Cannot capture monitor layout."
    exit 1
fi

# --- Phase 2: Query monitor info ------------------------------------------------
log_info "[2/4] Querying monitor layout with xrandr --query..."

XRANDR_OUTPUT=$(xrandr --query)
log_info "Raw xrandr output captured."

# --- Phase 3: Parse monitor data ------------------------------------------------
log_info "[3/4] Parsing monitor information..."

# Initialize JSON array
JSON_CONTENT="["
FIRST_ENTRY=true

while IFS= read -r line; do
    # Match connected monitors
    if [[ "$line" =~ ^([A-Za-z0-9-]+)\ connected ]]; then
        NAME="${BASH_REMATCH[1]}"

        # Determine if primary
        PRIMARY="false"
        if [[ "$line" =~ primary ]]; then
            PRIMARY="true"
        fi

        # Extract geometry: 1920x1080+0+0
        if [[ "$line" =~ ([0-9]+x[0-9]+\+[0-9]+\+[0-9]+) ]]; then
            GEOMETRY="${BASH_REMATCH[1]}"
        else
            GEOMETRY="unknown"
        fi

        # Extract rotation (normal, left, right, inverted)
        if [[ "$line" =~ (normal|left|right|inverted) ]]; then
            ROTATION="${BASH_REMATCH[1]}"
        else
            ROTATION="unknown"
        fi

        # Extract refresh rate (look for something like 59.97*)
        REFRESH="unknown"
        RATE_LINE=$(echo "$XRANDR_OUTPUT" | grep -A1 "^$NAME ")
        if [[ "$RATE_LINE" =~ ([0-9]+\.[0-9]+)\* ]]; then
            REFRESH="${BASH_REMATCH[1]}"
        fi

        # Append JSON entry
        if [ "$FIRST_ENTRY" = true ]; then
            FIRST_ENTRY=false
        else
            JSON_CONTENT+=","
        fi

        JSON_CONTENT+="
        {
            \"name\": \"$NAME\",
            \"primary\": $PRIMARY,
            \"geometry\": \"$GEOMETRY\",
            \"rotation\": \"$ROTATION\",
            \"refresh_hz\": \"$REFRESH\"
        }"

        log_info "Detected monitor: $NAME | geometry=$GEOMETRY | primary=$PRIMARY | rotation=$ROTATION | refresh=$REFRESH"
    fi
done <<< "$XRANDR_OUTPUT"

JSON_CONTENT+="]"

# --- Phase 4: Write output ------------------------------------------------------
log_info "[4/4] Writing monitor layout to $OUTPUT_FILE..."

echo -e "$JSON_CONTENT" > "$OUTPUT_FILE"

log_info "✓ Monitor layout captured successfully."
log_info "Output saved to: $OUTPUT_FILE"
log_info "Log saved to: $LOG_FILE"
log_info "--------------------------------------------------------"
