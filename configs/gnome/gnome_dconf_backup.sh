#!/usr/bin/env bash
#
# gnome_dconf_backup.sh
# --------------------------------------------------------------------
# Back up GNOME dconf settings so they can be restored after a
# reinstall. This script:
#   - Dumps /org/gnome/ to a stable backup file
#   - Archives the previous backup with a timestamp (if present)
#   - Logs to configs/gnome/logs/
#
# Expected repo layout:
#   ~/repos/sre-laptop-restore/
#     scripts/log.sh
#     configs/gnome/gnome_dconf_backup.sh
#     configs/gnome/dconf-gnome.conf
#     configs/gnome/archive/
#     configs/gnome/logs/
# --------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$HOME/repos/sre-laptop-restore"

CONFIG_DIR="$ROOT_DIR/configs/gnome"
ARCHIVE_DIR="$CONFIG_DIR/archive"
LOG_DIR="$CONFIG_DIR/logs"

BACKUP_FILE="$CONFIG_DIR/dconf-gnome.conf"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$LOG_DIR/dconf_backup_${TIMESTAMP}.log"

mkdir -p "$CONFIG_DIR" "$ARCHIVE_DIR" "$LOG_DIR"

# Load shared logging helpers
if [[ -f "$ROOT_DIR/scripts/log.sh" ]]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/scripts/log.sh"
else
  # Fallback minimal log functions if log.sh is missing
  log_info()  { printf '[INFO ] %s\n' "$*"; }
  log_warn()  { printf '[WARN ] %s\n' "$*"; }
  log_error() { printf '[ERROR] %s\n' "$*" >&2; }
fi

# Tee all output to log file
exec > >(tee -a "$LOG_FILE") 2>&1

log_info "--------------------------------------------------------"
log_info "SRE Laptop Restore – GNOME dconf backup"
log_info "Start: $(date)"
log_info "Config dir:    $CONFIG_DIR"
log_info "Backup target: $BACKUP_FILE"
log_info "Log file:      $LOG_FILE"
log_info "--------------------------------------------------------"

# --- Phase 1: Preconditions -------------------------------------------

if ! command -v dconf >/dev/null 2>&1; then
  log_error "dconf command not found. Install it (usually via 'sudo apt install dconf-cli') and retry."
  exit 1
fi

# --- Phase 2: Archive existing backup (if any) ------------------------

if [[ -f "$BACKUP_FILE" ]]; then
  ARCHIVE_FILE="$ARCHIVE_DIR/dconf-gnome_${TIMESTAMP}.conf"
  log_info "Existing backup found at $BACKUP_FILE"
  log_info "Archiving current backup to $ARCHIVE_FILE"
  cp "$BACKUP_FILE" "$ARCHIVE_FILE"
else
  log_info "No existing backup file found – this looks like the first run."
fi

# --- Phase 3: Create fresh backup ------------------------------------

TEMP_FILE="${BACKUP_FILE}.tmp"

log_info "Running: dconf dump /org/gnome/ > \"$TEMP_FILE\""

if dconf dump /org/gnome/ > "$TEMP_FILE"; then
  mv "$TEMP_FILE" "$BACKUP_FILE"
  log_info "GNOME dconf backup successfully written to:"
  log_info "  $BACKUP_FILE"
else
  log_error "dconf dump failed. Leaving previous backup intact (if any)."
  rm -f "$TEMP_FILE" || true
  exit 1
fi

log_info "GNOME dconf backup completed successfully."
log_info "End: $(date)"
log_info "--------------------------------------------------------"
