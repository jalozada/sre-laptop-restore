#!/usr/bin/env bash
#
# log_rotate.sh
# --------------------------------------------------------------------
# Automated log rotation for SRE Laptop Restore.
# - Compress logs older than 7 days
# - Delete logs older than 30 days
# - Maintain log hygiene across the project
# --------------------------------------------------------------------

set -euo pipefail

ROOT_DIR="$HOME/repos/sre-laptop-restore"
LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$LOG_DIR"

ROTATE_LOG="$LOG_DIR/log_rotate_$(date +%Y%m%d_%H%M%S).log"

echo "--------------------------------------------------------" | tee -a "$ROTATE_LOG"
echo "SRE Laptop Restore – Log Rotation" | tee -a "$ROTATE_LOG"
echo "Start: $(date)" | tee -a "$ROTATE_LOG"
echo "--------------------------------------------------------" | tee -a "$ROTATE_LOG"

# Compress logs older than 7 days
echo "[INFO] Compressing logs older than 7 days..." | tee -a "$ROTATE_LOG"
find "$LOG_DIR" -type f -name "*.log" -mtime +7 -print -exec gzip {} \; | tee -a "$ROTATE_LOG"

# Delete logs older than 30 days
echo "[INFO] Deleting logs older than 30 days..." | tee -a "$ROTATE_LOG"
find "$LOG_DIR" -type f -mtime +30 -print -exec rm {} \; | tee -a "$ROTATE_LOG"

echo "[SUCCESS] Log rotation completed." | tee -a "$ROTATE_LOG"
echo "End: $(date)" | tee -a "$ROTATE_LOG"

