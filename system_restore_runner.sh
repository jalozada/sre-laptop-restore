#!/usr/bin/env bash
#
# system_restore_runner.sh
# --------------------------------------------------------------------
# Orchestrates the full SRE Laptop Restore process:
#   1. Runs pre-flight validation
#   2. Stops if validation fails
#   3. If valid, executes the full restore pipeline
#   4. Logs all output and errors
# --------------------------------------------------------------------

set -euo pipefail

ROOT_DIR="$HOME/repos/sre-laptop-restore"
LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/system_restore_runner_$(date +%Y%m%d_%H%M%S).log"

source "$ROOT_DIR/scripts/log.sh"

log_info "--------------------------------------------------------"
log_info "SRE Laptop Restore – Runner Script"
log_info "Start: $(date)"
log_info "Log Output: $LOG_FILE"
log_info "--------------------------------------------------------"

# --------------------------------------------------------------------
# PHASE 1 – Run Validation
# --------------------------------------------------------------------
log_info "Running validation script..."

VALIDATE_SCRIPT="$ROOT_DIR/system_restore_validate.sh"

if [[ ! -f "$VALIDATE_SCRIPT" ]]; then
    log_error "Validation script missing: $VALIDATE_SCRIPT"
    exit 1
fi

if ! bash "$VALIDATE_SCRIPT" 2>&1 | tee -a "$LOG_FILE"; then
    log_error "Validation failed. Aborting restore."
    exit 2
fi

log_success "Validation successful. Proceeding to system restore."

# --------------------------------------------------------------------
# PHASE 2 – Execute full restore
# --------------------------------------------------------------------
RESTORE_SCRIPT="$ROOT_DIR/system_restore.sh"

if [[ ! -f "$RESTORE_SCRIPT" ]]; then
    log_error "Restore script missing: $RESTORE_SCRIPT"
    exit 3
fi

log_info "Executing system restore..."

if ! bash "$RESTORE_SCRIPT" 2>&1 | tee -a "$LOG_FILE"; then
    log_error "Restore script encountered errors."
    exit 4
fi

log_success "System restore completed successfully."
log_info "Full log: $LOG_FILE"
log_info "End: $(date)"

