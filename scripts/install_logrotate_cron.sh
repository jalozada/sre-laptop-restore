#!/usr/bin/env bash
#
# install_logrotate_cron.sh
# --------------------------------------------------------------------
# Installs a user-level cronjob to run log rotation weekly.
# Prevents duplicate entries and logs installation details.
# --------------------------------------------------------------------

set -euo pipefail

ROOT_DIR="$HOME/repos/sre-laptop-restore"
LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$LOG_DIR"

CRON_LOG="$LOG_DIR/cron_install_$(date +%Y%m%d_%H%M%S).log"
SCRIPT_PATH="$ROOT_DIR/scripts/log_rotate.sh"
CRON_ENTRY="0 3 * * 0 bash \"$SCRIPT_PATH\" >> \"$LOG_DIR/cron_log_rotate_output.log\" 2>&1"

echo "--------------------------------------------------------" | tee -a "$CRON_LOG"
echo "SRE Laptop Restore – Cron Install Utility" | tee -a "$CRON_LOG"
echo "Start: $(date)" | tee -a "$CRON_LOG"
echo "--------------------------------------------------------" | tee -a "$CRON_LOG"

# Validate script exists
if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "[ERROR] log_rotate.sh not found at: $SCRIPT_PATH" | tee -a "$CRON_LOG"
    exit 1
fi

# Dump current crontab
CURRENT_CRON=$(mktemp)
crontab -l 2>/dev/null > "$CURRENT_CRON" || true

# Check for duplicate
if grep -Fq "$SCRIPT_PATH" "$CURRENT_CRON"; then
    echo "[INFO] Cronjob already installed. No changes made." | tee -a "$CRON_LOG"
else
    echo "[INFO] Installing weekly cronjob..." | tee -a "$CRON_LOG"
    echo "$CRON_ENTRY" >> "$CURRENT_CRON"
    crontab "$CURRENT_CRON"
    echo "[SUCCESS] Cronjob installed." | tee -a "$CRON_LOG"
fi

rm -f "$CURRENT_CRON"

echo "End: $(date)" | tee -a "$CRON_LOG"

