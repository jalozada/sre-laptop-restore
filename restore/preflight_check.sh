#!/usr/bin/env bash
#
# preflight_check.sh
# --------------------------------------------------------------------
# This script performs all validation required before running the full
# system restore pipeline.
#
# It MUST be idempotent, fast, and non-destructive.
# It SHOULD fail fast on any blocking issues.
#
# All output logs to restore/logs/preflight_*.log
# --------------------------------------------------------------------

set -euo pipefail

LOG_DIR="$HOME/repos/sre-laptop-restore/restore/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/preflight_$(date +%Y%m%d_%H%M%S).log"

echo "--------------------------------------------------------" | tee -a "$LOG_FILE"
echo " SRE Laptop Restore – Pre-Flight Validation"               | tee -a "$LOG_FILE"
echo " Start: $(date)"                                           | tee -a "$LOG_FILE"
echo "--------------------------------------------------------" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# --- Check: OS Info -----------------------------------------------------------
echo "[1/8] Checking OS version..." | tee -a "$LOG_FILE"
if command -v lsb_release >/dev/null 2>&1; then
    lsb_release -a 2>/dev/null | tee -a "$LOG_FILE"
else
    echo "Warning: lsb_release not available" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --- Check: Disk Space --------------------------------------------------------
echo "[2/8] Checking disk space..." | tee -a "$LOG_FILE"
df -h / | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# --- Check: Network Connectivity ----------------------------------------------
echo "[3/8] Checking network..." | tee -a "$LOG_FILE"
if ping -c 1 1.1.1.1 >/dev/null 2>&1; then
    echo "✓ Network reachable" | tee -a "$LOG_FILE"
else
    echo "✗ Network unreachable" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --- Check: sudo availability --------------------------------------------------
echo "[4/8] Checking sudo access..." | tee -a "$LOG_FILE"
if sudo -n true 2>/dev/null; then
    echo "✓ Sudo access confirmed" | tee -a "$LOG_FILE"
else
    echo "✗ Sudo requires password or not available" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --- Check: Required Directories ----------------------------------------------
echo "[5/8] Checking repository directory structure..." | tee -a "$LOG_FILE"
REQUIRED_DIRS=(
    "$HOME/repos/sre-laptop-restore/backup"
    "$HOME/repos/sre-laptop-restore/configs"
    "$HOME/repos/sre-laptop-restore/restore"
    "$HOME/repos/sre-laptop-restore/scripts"
    "$HOME/repos/sre-laptop-restore/docs"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        echo "✓ Exists: $dir" | tee -a "$LOG_FILE"
    else
        echo "✗ Missing: $dir" | tee -a "$LOG_FILE"
    fi
done
echo "" | tee -a "$LOG_FILE"

# --- Check: Required Tools -----------------------------------------------------
echo "[6/8] Checking required tools..." | tee -a "$LOG_FILE"
REQUIRED_TOOLS=(bash sed awk curl git jq)

for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✓ $tool" | tee -a "$LOG_FILE"
    else
        echo "✗ MISSING: $tool" | tee -a "$LOG_FILE"
    fi
done
echo "" | tee -a "$LOG_FILE"

# --- Check: Snapshot Artifacts -------------------------------------------------
echo "[7/8] Checking snapshot availability..." | tee -a "$LOG_FILE"
SNAPSHOT_GLOB="$HOME/system-backups/system_snapshot_*"
if compgen -G "$SNAPSHOT_GLOB" >/dev/null; then
    echo "✓ Snapshot files detected" | tee -a "$LOG_FILE"
else
    echo "✗ No snapshot files present" | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# --- Completed -----------------------------------------------------------------
echo "[8/8] Pre-flight validation complete." | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "--------------------------------------------------------" | tee -a "$LOG_FILE"
echo " Completed: $(date)" | tee -a "$LOG_FILE"
echo " Log saved to: $LOG_FILE" | tee -a "$LOG_FILE"
echo "--------------------------------------------------------" | tee -a "$LOG_FILE"
