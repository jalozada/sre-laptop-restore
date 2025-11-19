#!/usr/bin/env bash
#
# run_borg_integrity_check.sh
# ---------------------------------------------------------------
# Weekly Borg integrity check.
# Logs to ~/system-backups/logs/health/borg_check_YYYY-MM-DD_HHMM.log
# ---------------------------------------------------------------

set -euo pipefail

BORG_REPO="$HOME/system-backups/borg_repo"
LOG_DIR="$HOME/system-backups/logs/health"
mkdir -p "$LOG_DIR"

LOGFILE="$LOG_DIR/borg_check_$(date +'%Y-%m-%d_%H%M').log"

echo "[borg-check] Starting borg check at $(date)" | tee -a "$LOGFILE"

if ! command -v borg >/dev/null 2>&1; then
  echo "[borg-check] ERROR: borg not installed." | tee -a "$LOGFILE"
  exit 1
fi

export BORG_PASSCOMMAND="cat $HOME/.config/borg/passphrase"

borg check "$BORG_REPO" >> "$LOGFILE" 2>&1

echo "[borg-check] Borg integrity check completed at $(date)" | tee -a "$LOGFILE"
echo "[borg-check] Log: $LOGFILE" | tee -a "$LOGFILE"
