#!/usr/bin/env bash
#
# system_restore_validate.sh
# --------------------------------------------------------------------
# Pre-flight validation for the SRE Laptop Restore pipeline.
# Performs non-invasive checks to ensure all components exist and
# are ready before running system_restore.sh.
# --------------------------------------------------------------------

set -euo pipefail

ROOT_DIR="$HOME/repos/sre-laptop-restore"
LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/system_restore_validate_$(date +%Y%m%d_%H%M%S).log"

source "$ROOT_DIR/scripts/log.sh"

log_info "--------------------------------------------------------"
log_info "SRE Laptop Restore – Validation Script"
log_info "Start: $(date)"
log_info "--------------------------------------------------------"

ERRORS=0

check_file() {
    if [[ ! -f "$1" ]]; then
        log_error "Missing file: $1"
        ERRORS=$((ERRORS + 1))
    else
        log_success "File OK: $1"
    fi
}

check_binary() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log_error "Missing binary: $1"
        ERRORS=$((ERRORS + 1))
    else
        log_success "Binary OK: $1"
    fi
}

# --------------------------------------------------------------------
# PHASE 1 – Validate required binaries
# --------------------------------------------------------------------
log_info "Phase 1: Checking required binaries..."

check_binary "jq"
check_binary "xrandr"
check_binary "dconf"

# --------------------------------------------------------------------
# PHASE 2 – Validate script files
# --------------------------------------------------------------------
log_info "Phase 2: Checking script files..."

check_file "$ROOT_DIR/scripts/log.sh"
check_file "$ROOT_DIR/scripts/optimize_firefox.sh"
check_file "$ROOT_DIR/scripts/optimize_chrome.sh"
check_file "$ROOT_DIR/configs/gnome/monitor_layout_capture.sh"
check_file "$ROOT_DIR/configs/gnome/monitor_layout_restore.sh"
check_file "$ROOT_DIR/system_restore.sh"

# --------------------------------------------------------------------
# PHASE 3 – Validate GNOME config data
# --------------------------------------------------------------------
log_info "Phase 3: Checking GNOME/Tiling Assistant files..."

check_file "$ROOT_DIR/configs/gnome/dconf_backup.ini"

# --------------------------------------------------------------------
# PHASE 4 – Validate monitor layout JSON
# --------------------------------------------------------------------
log_info "Phase 4: Monitor layout JSON integrity..."

SNAPSHOT="$ROOT_DIR/configs/gnome/monitor_layout.json"

if [[ -f "$SNAPSHOT" ]]; then
    if jq empty "$SNAPSHOT" 2>/dev/null; then
        log_success "Monitor layout JSON is valid."
    else
        log_error "Monitor layout JSON is invalid or corrupted."
        ERRORS=$((ERRORS + 1))
    fi
else
    log_warning "Monitor layout JSON not found — must run capture before restore."
fi

# --------------------------------------------------------------------
# PHASE 5 – Repo cleanliness
# --------------------------------------------------------------------
log_info "Phase 5: Verifying git repo status..."

cd "$ROOT_DIR"
if git status --porcelain | grep -q .; then
    log_warning "Repo has uncommitted changes."
else
    log_success "Repo is clean."
fi

# --------------------------------------------------------------------
# RESULTS
# --------------------------------------------------------------------
if [[ "$ERRORS" -gt 0 ]]; then
    log_error "Validation completed with $ERRORS error(s). Fix before running system_restore.sh."
    exit 1
else
    log_success "Validation successful. All components ready."
    log_info "Safe to run: $ROOT_DIR/system_restore.sh"
fi

log_info "End: $(date)"

