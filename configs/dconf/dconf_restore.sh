#!/usr/bin/env bash
#
# dconf_restore.sh
# --------------------------------------------------------------------
# Restores GNOME/Tiling Assistant/Keybinding settings using dconf.
# This version is NON-DESTRUCTIVE — it only validates and logs.
#
# Final version will:
#   - Load full dconf database from configs/dconf/dconf_full.ini
#   - Restore keybindings
#   - Restore monitor layouts (ASUS + Samsung setup)
#   - Restore tiling assistant preferences
#   - Validate GNOME extension settings
#
# Logs: configs/dconf/logs/dconf_restore_*.log
# --------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$HOME/repos/sre-laptop-restore"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/dconf_restore_$(date +%Y%m%d_%H%M%S).log"

# Source logging framework
source "$ROOT_DIR/scripts/log.sh"

log_info "--------------------------------------------------------"
log_info "SRE Laptop Restore – dconf Restore (Scaffold)"
log_info "Start: $(date)"
log_info "--------------------------------------------------------"

# --- Phase 1: Check dconf availability ----------------------------------------
log_info "[1/4] Checking for dconf executable..."
if command -v dconf >/dev/null 2>&1; then
    log_info "dconf found."
else
    log_error "dconf NOT found. Restore cannot continue."
    exit 1
fi

# --- Phase 2: Validate export file presence -----------------------------------
DCONF_EXPORT="$SCRIPT_DIR/dconf_full.ini"

log_info "[2/4] Checking for dconf export file..."
if [[ -f "$DCONF_EXPORT" ]]; then
    log_info "Found dconf export file: $DCONF_EXPORT"
else
    log_warn "No dconf export found. Placeholder mode only."
fi

# --- Phase 3: Future restore hook (NON-DESTRUCTIVE) ---------------------------
log_info "[3/4] Placeholder: Future dconf load command"
log_info "  (Will run: dconf load / < $DCONF_EXPORT )"

# --- Phase 4: Completed --------------------------------------------------------
log_info "[4/4] dconf restore scaffold complete."
log_info "Log saved to: $LOG_FILE"
log_info "--------------------------------------------------------"
