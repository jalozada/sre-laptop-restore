#!/usr/bin/env bash
#
# gnome_dconf_restore.sh
# --------------------------------------------------------------------
# Restore GNOME dconf settings from the main backup file.
# This script:
#   - Validates the existence of the backup
#   - Archives current GNOME dconf state before changing anything
#   - Applies the backup using "dconf load"
#   - Logs actions to configs/gnome/logs/
#
# Expected repo layout:
#   ~/repos/sre-laptop-restore/
#     scripts/log.sh
#     configs/gnome/gnome_dconf_restore.sh
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
LOG_FILE="$LOG_DIR/dconf_restore_${TIMESTAMP}.log"

mkdir -p "$CONFIG_DIR" "$ARCHIVE_DIR" "$LOG_DIR"

# Load logging helpers
if [[ -f "$ROOT_DIR/scripts/log.sh" ]]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/scripts/log.sh"
else
  log_info()  { printf '[INFO ] %s\n' "$*"; }
  log_warn()  { printf '[WARN ] %s\n' "$*"; }
  log_error() { printf '[ERROR] %s\n' "$*" >&2; }
fi

# Tee to log file
exec > >(tee -a "$LOG_FILE") 2>&1

log_info "--------------------------------------------------------"
log_info "SRE Laptop Restore – GNOME dconf restore"
log_info "Start: $(date)"
log_info "Restore source: $BACKUP_FILE"
log_info "--------------------------------------------------------"

# --- Phase 1: Preconditions -------------------------------------------

if ! command -v dconf >/dev/null 2>&1; then
  log_error "dconf command not found. Install 'dconf-cli' and retry."
  exit 1
fi

if [[ ! -f "$BACKUP_FILE" ]]; then
  log_error "Backup file not found: $BACKUP_FILE"
  exit 1
fi

# --- Phase 2: Archive current on-system GNOME state -------------------

ARCHIVE_CURRENT="$ARCHIVE_DIR/current_before_restore_${TIMESTAMP}.conf"

log_info "Archiving current GNOME state to:"
log_info "  $ARCHIVE_CURRENT"

if dconf dump /org/gnome/ > "$ARCHIVE_CURRENT"; then
  log_info "Current GNOME state archived."
else
  log_warn "Unable to archive current GNOME state; continuing with caution."
fi

# --- Phase 3: Restore backup -----------------------------------------

log_info "Applying GNOME settings from backup..."

if dconf load /org/gnome/ < "$BACKUP_FILE"; then
  log_info "GNOME dconf restore completed successfully."
else
  log_error "Failed to load GNOME settings."
  exit 1
fi

log_info "End: $(date)"
log_info "--------------------------------------------------------"
