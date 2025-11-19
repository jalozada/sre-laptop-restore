#!/usr/bin/env bash
#
# mirror_to_t9.sh
# ---------------------------------------------------------------
# Mirror local Borg/system-backups to Samsung T9 (T91) using rsync.
# - Skips cleanly if T9 is not mounted
# - Logs to ~/system-backups/logs/mirror_to_t9_YYYY-MM-DD.log
# ---------------------------------------------------------------

set -euo pipefail

SRC="$HOME/system-backups"
DEST="/media/$USER/T91/system-backups-mirror"

LOG_DIR="$HOME/system-backups/logs"
mkdir -p "$LOG_DIR"
LOGFILE="$LOG_DIR/mirror_to_t9_$(date +'%Y-%m-%d').log"

echo "[mirror] --------------------------------------------------" | tee -a "$LOGFILE"
echo "[mirror] Starting mirror at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOGFILE"

# Ensure T9 is mounted
if [[ ! -d "/media/$USER/T91" ]]; then
    echo "[mirror] T9 (T91) not mounted. Skipping mirror." | tee -a "$LOGFILE"
    exit 0
fi

mkdir -p "$DEST"

echo "[mirror] Mirroring $SRC -> $DEST" | tee -a "$LOGFILE"

rsync -aHAX --delete --numeric-ids \
  --log-file="$LOGFILE" \
  "$SRC/" "$DEST/"

echo "[mirror] Mirror completed successfully at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOGFILE"
echo "[mirror] Logs: $LOGFILE" | tee -a "$LOGFILE"
echo "[mirror] --------------------------------------------------" | tee -a "$LOGFILE"
