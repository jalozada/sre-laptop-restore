#!/usr/bin/env bash
#
# system_restore.sh
# --------------------------------------------------------------------
# Full SRE Laptop Restore Pipeline
# Includes:
#   - Monitor Layout Capture
#   - GNOME/TilingAssistant restore
#   - Firefox/Chrome optimization
#   - VS Code restore
#   - Repo integrity checks
#   - Monitor layout restore
#   - Optional log rotation
# --------------------------------------------------------------------

set -euo pipefail

ROOT_DIR="$HOME/repos/sre-laptop-restore"
LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/system_restore_$(date +%Y%m%d_%H%M%S).log"

source "$ROOT_DIR/scripts/log.sh"

log_info "--------------------------------------------------------"
log_info "SRE Laptop Restore – Full Pipeline Start"
log_info "Start: $(date)"
log_info "--------------------------------------------------------"

# --------------------------------------------------------------------
# PHASE 1 – Monitor Layout Capture
# --------------------------------------------------------------------
log_info "Phase 1: Capturing current monitor layout..."
if [[ -f "$ROOT_DIR/configs/gnome/monitor_layout_capture.sh" ]]; then
    bash "$ROOT_DIR/configs/gnome/monitor_layout_capture.sh"
else
    log_error "Monitor layout capture script missing!"
fi

# --------------------------------------------------------------------
# PHASE 2 – Restore GNOME/Tiling Assistant
# --------------------------------------------------------------------
log_info "Phase 2: Restoring GNOME/Tiling Assistant settings..."
if command -v dconf >/dev/null 2>&1; then
    if [[ -f "$ROOT_DIR/configs/gnome/dconf_backup.ini" ]]; then
        dconf load / < "$ROOT_DIR/configs/gnome/dconf_backup.ini"
        log_success "GNOME configuration restored."
    else
        log_error "Missing dconf_backup.ini — skipping GNOME restore."
    fi
else
    log_error "dconf not installed. Cannot restore GNOME settings."
fi

# --------------------------------------------------------------------
# PHASE 3 – Firefox
# --------------------------------------------------------------------
log_info "Phase 3: Applying Firefox optimizations..."
if [[ -f "$ROOT_DIR/scripts/optimize_firefox.sh" ]]; then
    bash "$ROOT_DIR/scripts/optimize_firefox.sh"
    log_success "Firefox optimized."
else
    log_error "optimize_firefox.sh missing!"
fi

# --------------------------------------------------------------------
# PHASE 4 – Chrome
# --------------------------------------------------------------------
log_info "Phase 4: Applying Chrome optimizations..."
if [[ -f "$ROOT_DIR/scripts/optimize_chrome.sh" ]]; then
    bash "$ROOT_DIR/scripts/optimize_chrome.sh"
    log_success "Chrome optimized."
else
    log_error "optimize_chrome.sh missing!"
fi

# --------------------------------------------------------------------
# PHASE 5 – VS Code Restore
# --------------------------------------------------------------------
log_info "Phase 5: Restoring VS Code configuration..."
if [[ -f "$ROOT_DIR/scripts/vscode_restore.sh" ]]; then
    bash "$ROOT_DIR/scripts/vscode_restore.sh"
    log_success "VS Code restore completed."
else
    log_warning "vscode_restore.sh missing — skipping VS Code."
fi

# --------------------------------------------------------------------
# PHASE 6 – Repo Validation
# --------------------------------------------------------------------
log_info "Phase 6: Validating git repository..."
cd "$ROOT_DIR"
if git status --porcelain | grep -q .; then
    log_warning "Repo has uncommitted changes."
else
    log_success "Repo clean."
fi

# --------------------------------------------------------------------
# PHASE 7 – Monitor Layout Restore
# --------------------------------------------------------------------
log_info "Phase 7: Restoring monitor layout..."
if [[ -f "$ROOT_DIR/configs/gnome/monitor_layout_restore.sh" ]]; then
    bash "$ROOT_DIR/configs/gnome/monitor_layout_restore.sh"
    log_success "Monitor layout restored."
else
    log_error "Monitor layout restore script missing!"
fi

# --------------------------------------------------------------------
# PHASE 8 – Log Rotation (optional)
# --------------------------------------------------------------------
log_info "Phase 8: Running optional log rotation..."
if [[ -f "$ROOT_DIR/scripts/log_rotate.sh" ]]; then
    bash "$ROOT_DIR/scripts/log_rotate.sh"
else
    log_warning "log_rotate.sh missing — skipping."
fi

# --------------------------------------------------------------------
# COMPLETE
# --------------------------------------------------------------------
log_success "SRE Laptop Restore – Pipeline completed."
log_info "End: $(date)"


# --- VS Code Restore Start -------------------------------------------------
log_info "Starting VS Code Restore..."
"$SCRIPT_DIR/scripts/vscode_restore.sh"
log_info "Completed VS Code Restore."
# --- VS Code Restore End ---------------------------------------------------
