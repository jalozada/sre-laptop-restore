#!/usr/bin/env bash
#
# dconf_backup.sh
# --------------------------------------------------------------------
# Creates a full backup of GNOME/Tiling Assistant/Keybindings settings.
# Produces a timestamped dconf dump file suitable for full-system restore.
#
# Output: configs/dconf/backups/dconf_full_YYYYMMDD_HHMMSS.ini
# Logs:   configs/dconf/logs/dconf_backup_*.log
# --------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$HOME/repos/sre-laptop-restore"
LOG_DIR="$SCRIPT_DIR/logs"
BACKUP_DIR="$SCRIPT_DIR/backups"

mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_DIR"

LOG_FILE="$LOG_DIR/dconf_backup_$(date +%Y%m%d_%H%M%S).log"
BACKUP_FILE="$BACKUP_DIR/dconf_full_$(date +%Y%m%d_%H%M%S).ini"

# Source logging
source "$ROOT_DIR/scripts/log.sh"

log_info "--------------------------------------------------------"
log_info "SRE Laptop Restore – dconf Backup"
log_info "Start: $(date)"
log_info "--------------------------------------------------------"

# --- Phase 1: Verify dconf availability ---------------------------------------
log_info "[1/4] Checking for dconf..."
if command -v dconf >/dev/null 2>&1; then
    log_info "dconf found."
else
    log_error "dconf NOT installed. Cannot perform backup."
    exit 1
fi

# --- Phase 2: Perform full dconf dump -----------------------------------------
log_info "[2/4] Exporting full GNOME configuration..."
if dconf dump / > "$BACKUP_FILE"; then
    log_info "✓ GNOME configuration exported to:"
    log_info "  $BACKUP_FILE"
else
    log_error "✗ Failed to export GNOME configuration."
    exit 1
fi

# --- Phase 3: Validate backup file --------------------------------------------
log_info "[3/4] Validating backup file..."
if [[ -s "$BACKUP_FILE" ]]; then
    log_info "✓ Backup validated successfully."
else
    log_error "✗ Backup file is empty or corrupt."
    exit 1
fi

# --- Phase 4: Completed --------------------------------------------------------
log_info "[4/4] dconf backup completed."
log_info "Backup file saved to: $BACKUP_FILE"
log_info "Log saved to: $LOG_FILE"
log_info "--------------------------------------------------------"
