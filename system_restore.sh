#!/usr/bin/env bash
#
# system_restore.sh
# --------------------------------------------------------------------
# Full SRE Laptop Restore Pipeline
# Now includes:
#   - Monitor Layout Capture
#   - Monitor Layout Restore
#   - GNOME/TilingAssistant restore
#   - Firefox/Chrome optimization
#   - Repo integrity checks
#   - Full logging framework
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
# PHASE 1 – Monitor Layout Capture (pre-restore baseline)
# --------------------------------------------------------------------
log_info "Phase 1: Capturing current monitor layout..."

if [[ -f "$ROOT_DIR/configs/gnome/monitor_layout_capture.sh" ]]; then
    bash "$ROOT_DIR/configs/gnome/monitor_layout_capture.sh"
else
    log_error "Monitor layout capture script missing!"
fi

# --------------------------------------------------------------------
# PHASE 2 – Restore GNOME + Tiling Assistant Settings
# --------------------------------------------------------------------
log_info "Phase 2: Restoring GNOME/Tiling Assistant settings..."

if command -v dconf >/dev/null 2>&1; then
    if [[ -f "$ROOT_DIR/configs/gnome/dconf_backup.ini" ]]; then
        dconf load / < "$ROOT_DIR/configs/gnome/dconf_backup.ini"
        log_success "GNOME configuration restored."
    else
        log_error "Missing: dconf_backup.ini — skipping GNOME restore."
    fi
else
    log_error "dconf not installed. Cannot restore GNOME settings."
fi

# --------------------------------------------------------------------
# PHASE 3 – Firefox browser restore
# --------------------------------------------------------------------
log_info "Phase 3: Restoring Firefox optimizations..."

if [[ -f "$ROOT_DIR/scripts/optimize_firefox.sh" ]]; then
    bash "$ROOT_DIR/scripts/optimize_firefox.sh"
    log_success "Firefox optimized."
else
    log_error "optimize_firefox.sh missing!"
fi

# --------------------------------------------------------------------
# PHASE 4 – Chrome browser restore
# --------------------------------------------------------------------
log_info "Phase 4: Restoring Chrome optimizations..."

if [[ -f "$ROOT_DIR/scripts/optimize_chrome.sh" ]]; then
    bash "$ROOT_DIR/scripts/optimize_chrome.sh"
    log_success "Chrome optimized."
else
    log_error "optimize_chrome.sh missing!"
fi

# --------------------------------------------------------------------
# PHASE 5 – Repo Validation
# --------------------------------------------------------------------
log_info "Phase 5: Validating repository..."

cd "$ROOT_DIR"
if git status --porcelain | grep -q .; then
    log_warning "Repo has uncommitted changes."
else
    log_success "Repo clean and consistent."
fi

# --------------------------------------------------------------------
# PHASE 6 – Restore Monitor Layout (post-GNOME restore)
# --------------------------------------------------------------------
log_info "Phase 6: Restoring monitor layout..."

if [[ -f "$ROOT_DIR/configs/gnome/monitor_layout_restore.sh" ]]; then
    bash "$ROOT_DIR/configs/gnome/monitor_layout_restore.sh"
    log_success "Monitor layout restored."
else
    log_error "Monitor layout restore script missing!"
fi

# --------------------------------------------------------------------
# DONE
# --------------------------------------------------------------------
log_success "SRE Laptop Restore – Pipeline completed."
log_info "End: $(date)"

