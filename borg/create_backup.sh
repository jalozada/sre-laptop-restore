#!/usr/bin/env bash
#
# create_backup.sh — LOCAL BORG REPO VERSION
# ---------------------------------------------------------------
# Crash-proof:
#   - Quiet output (no terminal flooding)
#   - Full logs written to ~/borg_backup.log
#
# Uses LOCAL repository:
#   /home/javier/system-backups/borg_repo
#
# Idempotent and safe to run repeatedly.
# Includes sensible exclusions for heavy, reproducible data.
# ---------------------------------------------------------------

set -euo pipefail

LOGFILE="$HOME/borg_backup.log"
REPO="$HOME/system-backups/borg_repo"
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
ARCHIVE_NAME="backup_$TIMESTAMP"

echo "[borg] --------------------------------------------------" | tee -a "$LOGFILE"
echo "[borg] Starting Borg Backup at: $TIMESTAMP" | tee -a "$LOGFILE"

# Load passphrase
export BORG_PASSCOMMAND="cat $HOME/.config/borg/passphrase"

# Verify local repo exists
if ! borg info "$REPO" > /dev/null 2>&1; then
    echo "[borg] ERROR: Local Borg repo not found at: $REPO" | tee -a "$LOGFILE"
    echo "[borg] Please create it with:" | tee -a "$LOGFILE"
    echo "       borg init --encryption=repokey $REPO" | tee -a "$LOGFILE"
    exit 1
fi

echo "[borg] Using local repository: $REPO" | tee -a "$LOGFILE"

# Run backup (with exclusions)
echo "[borg] Creating archive: $ARCHIVE_NAME" | tee -a "$LOGFILE"

borg create \
    --verbose \
    --stats \
    --compression zstd \
    --exclude '*/node_modules' \
    --exclude '*/.terraform' \
    --exclude '*/.venv' \
    --exclude '*/venv' \
    --exclude '*/.git' \
    "$REPO::$ARCHIVE_NAME" \
    "$HOME/Documents" \
    "$HOME/.config" \
    "$HOME/scripts" \
    "$HOME/repos" \
    >> "$LOGFILE" 2>&1

echo "[borg] Archive created." | tee -a "$LOGFILE"

# Prune old backups
echo "[borg] Pruning old archives..." | tee -a "$LOGFILE"
borg prune \
    --stats \
    --keep-daily=7 \
    --keep-weekly=4 \
    --keep-monthly=3 \
    "$REPO" \
    >> "$LOGFILE" 2>&1

echo "[borg] Pruning complete." | tee -a "$LOGFILE"
echo "[borg] Backup completed successfully." | tee -a "$LOGFILE"
echo "[borg] Logs saved to $LOGFILE" | tee -a "$LOGFILE"
echo "[borg] --------------------------------------------------" | tee -a "$LOGFILE"
