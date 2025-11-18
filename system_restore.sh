#!/usr/bin/env bash
#
# system_restore.sh
# --------------------------------------------------------------------
# Full SRE Laptop Restore Pipeline
# Includes:
#   - Monitor Layout Capture
#   - GNOME dconf backup (pre-restore safety snapshot)
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

# Shared logging helpers
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/log.sh"

log_info "--------------------------------------------------------"
log_info "SRE Laptop Restore – Full Pipeline Start"
log_info "Start: $(date)"
log_info "Log file (external scripts may also log separately): $LOG_FILE"
log_info "--------------------------------------------------------"

# --------------------------------------------------------------------
# PHASE 1 – Monitor Layout Capture
# --------------------------------------------------------------------
log_info "Phase 1: Capturing current monitor layout..."
MONITOR_CAPTURE_SCRIPT="$ROOT_DIR/configs/gnome/monitor_layout_capture.sh"

if [[ -x "$MONITOR_CAPTURE_SCRIPT" ]]; then
    bash "$MONITOR_CAPTURE_SCRIPT"
    log_success "Monitor layout captured."
else
    log_warning "Monitor layout capture script missing or not executable: $MONITOR_CAPTURE_SCRIPT"
fi

# --------------------------------------------------------------------
# PHASE 2 – GNOME dconf Backup (Pre-Restore Safety Snapshot)
# --------------------------------------------------------------------
log_info "Phase 2: Taking GNOME dconf backup (pre-restore snapshot)..."
GNOME_BACKUP_SCRIPT="$ROOT_DIR/configs/gnome/gnome_dconf_backup.sh"

if [[ -x "$GNOME_BACKUP_SCRIPT" ]]; then
    bash "$GNOME_BACKUP_SCRIPT"
    log_success "GNOME dconf backup completed via gnome_dconf_backup.sh."
else
    log_warning "GNOME backup script not found or not executable at: $GNOME_BACKUP_SCRIPT"
    log_warning "Skipping pre-restore GNOME dconf backup."
fi

# --------------------------------------------------------------------
# PHASE 3 – Restore GNOME/Tiling Assistant (via helper script)
# --------------------------------------------------------------------
log_info "Phase 3: Restoring GNOME/Tiling Assistant settings..."
GNOME_RESTORE_SCRIPT="$ROOT_DIR/configs/gnome/gnome_dconf_restore.sh"

if [[ -x "$GNOME_RESTORE_SCRIPT" ]]; then
    bash "$GNOME_RESTORE_SCRIPT"
    log_success "GNOME/TilingAssistant settings restored via gnome_dconf_restore.sh."
else
    log_warning "GNOME restore script not found or not executable at: $GNOME_RESTORE_SCRIPT"
    log_warning "Skipping GNOME/TilingAssistant restore."
fi

# --------------------------------------------------------------------
# PHASE 4 – Firefox
# --------------------------------------------------------------------
log_info "Phase 4: Applying Firefox optimizations..."
FIREFOX_SCRIPT="$ROOT_DIR/scripts/optimize_firefox.sh"

if [[ -x "$FIREFOX_SCRIPT" ]]; then
    bash "$FIREFOX_SCRIPT"
    log_success "Firefox optimized."
else
    log_error "optimize_firefox.sh missing or not executable at: $FIREFOX_SCRIPT"
fi

# --------------------------------------------------------------------
# PHASE 5 – Chrome
# --------------------------------------------------------------------
log_info "Phase 5: Applying Chrome optimizations..."
CHROME_SCRIPT="$ROOT_DIR/scripts/optimize_chrome.sh"

if [[ -x "$CHROME_SCRIPT" ]]; then
    bash "$CHROME_SCRIPT"
    log_success "Chrome optimized."
else
    log_error "optimize_chrome.sh missing or not executable at: $CHROME_SCRIPT"
fi

# --------------------------------------------------------------------
# PHASE 6 – VS Code Restore
# --------------------------------------------------------------------
log_info "Phase 6: Restoring VS Code configuration..."
VSCODE_RESTORE_SCRIPT="$ROOT_DIR/scripts/vscode_restore.sh"

if [[ -x "$VSCODE_RESTORE_SCRIPT" ]]; then
    bash "$VSCODE_RESTORE_SCRIPT"
    log_success "VS Code restore completed."
else
    log_warning "vscode_restore.sh missing or not executable — skipping VS Code restore."
fi

# --------------------------------------------------------------------
# PHASE 7 – Repo Validation
# --------------------------------------------------------------------
log_info "Phase 7: Validating git repository at $ROOT_DIR..."

if [[ -d "$ROOT_DIR/.git" ]]; then
    (
        cd "$ROOT_DIR"

        # Ensure this script is executable inside the repo
        if chmod +x system_restore.sh 2>/dev/null; then
            log_success "Ensured system_restore.sh is executable."
        else
            log_warning "Could not chmod +x system_restore.sh (permission issue?)."
        fi

        if git status --short >/dev/null 2>&1; then
            log_success "Git status OK."
        else
            log_error "git status reported an issue."
        fi

        if git fsck --no-progress >/dev/null 2>&1; then
            log_success "git fsck integrity check passed."
        else
            log_error "git fsck reported repository issues."
        fi
    )
else
    log_warning "No .git directory found at $ROOT_DIR — skipping repo validation."
fi

# --------------------------------------------------------------------
# PHASE 8 – Monitor Layout Restore
# --------------------------------------------------------------------
log_info "Phase 8: Restoring monitor layout..."
MONITOR_RESTORE_SCRIPT="$ROOT_DIR/configs/gnome/monitor_layout_restore.sh"

if [[ -x "$MONITOR_RESTORE_SCRIPT" ]]; then
    bash "$MONITOR_RESTORE_SCRIPT"
    log_success "Monitor layout restore completed."
else
    log_warning "Monitor layout restore script missing or not executable: $MONITOR_RESTORE_SCRIPT"
fi

# --------------------------------------------------------------------
# PHASE 9 – Optional Log Rotation
# --------------------------------------------------------------------
log_info "Phase 9: Running optional log rotation (if configured)..."
LOG_ROTATE_SCRIPT="$ROOT_DIR/scripts/log_rotate.sh"

if [[ -x "$LOG_ROTATE_SCRIPT" ]]; then
    bash "$LOG_ROTATE_SCRIPT" || log_warning "log_rotate.sh exited with a non-zero status."
    log_success "Log rotation script executed (see its own logs for details)."
else
    log_warning "log_rotate.sh not found or not executable — skipping log rotation."
fi

# --------------------------------------------------------------------
# COMPLETION
# --------------------------------------------------------------------
log_success "SRE Laptop Restore – Full Pipeline Completed Successfully."
log_info "End: $(date)"
log_info "--------------------------------------------------------"
