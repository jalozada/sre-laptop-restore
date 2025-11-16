#!/usr/bin/env bash
#
# keybindings_restore.sh
# --------------------------------------------------------------------
# Safely restores GNOME keybindings from your dconf backup.
# NON-DESTRUCTIVE placeholder version (scaffold).
#
# Future version will:
#   - Parse dconf_full.ini
#   - Restore relevant keybinding sections
#   - Validate missing or custom shortcuts
#
# Logs: configs/gnome/logs/keybindings_restore_*.log
# --------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$HOME/repos/sre-laptop-restore"
DCONF_BACKUP_DIR="$ROOT_DIR/configs/dconf/backups"
LOG_DIR="$SCRIPT_DIR/logs"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/keybindings_restore_$(date +%Y%m%d_%H%M%S).log"

# Logging framework
source "$ROOT_DIR/scripts/log.sh"

log_info "--------------------------------------------------------"
log_info "SRE Laptop Restore – Keybindings Restore (Scaffold)"
log_info "Start: $(date)"
log_info "--------------------------------------------------------"

# --- Phase 1: Check for dconf ---------------------------------------------------
log_info "[1/4] Checking for dconf..."
if command -v dconf >/dev/null 2>&1; then
    log_info "dconf detected."
else
    log_error "dconf NOT installed. Cannot restore keybindings."
    exit 1
fi

# --- Phase 2: Locate the latest dconf backup -----------------------------------
log_info "[2/4] Detecting latest dconf backup file..."

LATEST_BACKUP=$(ls -1 "$DCONF_BACKUP_DIR"/dconf_full_*.ini 2>/dev/null | tail -n 1 || true)

if [[ -z "$LATEST_BACKUP" ]]; then
    log_warn "No dconf backup found. Keybinding restore skipped."
else
    log_info "Using backup file: $LATEST_BACKUP"
fi

# --- Phase 3: Future parsing logic ---------------------------------------------
log_info "[3/4] Placeholder for parsing keybinding sections..."
log_info "Will extract from:"
log_info "  /org/gnome/settings-daemon/plugins/media-keys/"
log_info "  /org/gnome/desktop/wm/keybindings/"
log_info "  /org/gnome/mutter/keybindings/"

# --- Phase 4: Completion --------------------------------------------------------
log_info "[4/4] Keybindings restore scaffold completed."
log_info "Log saved to: $LOG_FILE"
log_info "--------------------------------------------------------"
