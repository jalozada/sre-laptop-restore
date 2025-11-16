#!/usr/bin/env bash
#
# remove_logrotate_cron.sh
# --------------------------------------------------------------------
# Removes the user-level cronjob that runs log rotation weekly.
# Ensures no unrelated entries are modified.
# --------------------------------------------------------------------

set -euo pipefail

ROOT_DIR="$HOME/repos/sre-laptop-restore"
LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$LOG_DIR"

UNINSTALL_LOG="$LOG_DIR/cron_uninstall_$(date +%Y%m%d_%H%M%S).log"
SCRIPT_PATH="$ROOT_DIR/scripts/log_rotate.sh"

echo "--------------------------------------------------------" | tee -a "$UNINSTALL_LOG"
echo "SRE Laptop Restore – CRON Removal Script" | tee -a "$UNINSTALL_LOG"
echo "Start: $(date)" | tee -a "$UNINSTALL_LOG"
echo "--------------------------------------------------------" | tee -a "$UNINSTALL_LOG"

TEMP_CRON=$(mktemp)
NEW_CRON=$(mktemp)

# Dump current crontab
crontab -l 2>/dev/null > "$TEMP_CRON" || true

# Check if cron entry exists
if ! grep -Fq "$SCRIPT_PATH" "$TEMP_CRON"; then
    echo "[INFO] No matching cronjob found. Nothing to remove." | tee -a "$UNINSTALL_LOG"
    rm -f "$TEMP_CRON" "$NEW_CRON"
    exit 0
fi

echo "[INFO] Removing cron entry associated with: $SCRIPT_PATH" | tee -a "$UNINSTALL_LOG"

# Remove only the matching entry
grep -Fv "$SCRIPT_PATH" "$TEMP_CRON" > "$NEW_CRON"

# Apply new crontab
crontab "$NEW_CRON"

echo "[SUCCESS] Cron entry removed." | tee -a "$UNINSTALL_LOG"

rm -f "$TEMP_CRON" "$NEW_CRON"

echo "End: $(date)" | tee -a "$UNINSTALL_LOG"
