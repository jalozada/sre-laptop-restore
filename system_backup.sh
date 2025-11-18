#!/usr/bin/env bash
#
# system_backup.sh
# ----------------------------------------------------------------------
# SRE Laptop Backup Pipeline (Borg-based)
#
# Features:
#   - Strict error handling (set -euo pipefail)
#   - Centralized logging under $BACKUP_ROOT/logs
#   - Borg-based archive creation with sane defaults
#   - Repo auto-init (if needed)
#   - Exclusion of noisy/ephemeral paths
#   - Prune policy for old archives
#   - Integrity check of the new archive
#
# Configuration via environment variables (all optional):
#   BACKUP_ROOT   - Root directory for backups/logs (default: $HOME/system-backups)
#   BORG_REPO     - Borg repository path (default: $BACKUP_ROOT/borg_repo)
#   BACKUP_TAG    - Prefix tag for archive names (default: system)
#   BORG_PRUNE_KEEP_DAILY   - Daily archives to keep (default: 7)
#   BORG_PRUNE_KEEP_WEEKLY  - Weekly archives to keep (default: 4)
#   BORG_PRUNE_KEEP_MONTHLY - Monthly archives to keep (default: 6)
#
# Usage:
#   ./system_backup.sh          # normal backup
#   ./system_backup.sh dry-run  # borg --dry-run (no data written)
#
# NOTE:
#   - For non-interactive runs, ensure you export BORG_PASSPHRASE or BORG_PASSCOMMAND.
# ----------------------------------------------------------------------

set -euo pipefail

# ----------------------------- Config ---------------------------------

BACKUP_ROOT="${BACKUP_ROOT:-$HOME/system-backups}"
BORG_REPO="${BORG_REPO:-$BACKUP_ROOT/borg_repo}"
BACKUP_TAG="${BACKUP_TAG:-system}"

BORG_PRUNE_KEEP_DAILY="${BORG_PRUNE_KEEP_DAILY:-7}"
BORG_PRUNE_KEEP_WEEKLY="${BORG_PRUNE_KEEP_WEEKLY:-4}"
BORG_PRUNE_KEEP_MONTHLY="${BORG_PRUNE_KEEP_MONTHLY:-6}"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
HOSTNAME_SHORT="$(hostname -s || echo "host")"
ARCHIVE_NAME="${BACKUP_TAG}_${HOSTNAME_SHORT}_${TIMESTAMP}"

LOCK_FILE="/tmp/system_backup.lock"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$HOME/repos/sre-laptop-restore"

# Logs live alongside the backups to keep everything together
LOG_DIR="${BACKUP_ROOT}/logs"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/system_backup_${TIMESTAMP}.log"

# --------------------------- Logging ----------------------------------

if [[ -f "${ROOT_DIR}/scripts/log.sh" ]]; then
  # shellcheck source=/dev/null
  source "${ROOT_DIR}/scripts/log.sh"
else
  log_info()  { echo "[INFO]  $*"; }
  log_warn()  { echo "[WARN]  $*" >&2; }
  log_error() { echo "[ERROR] $*" >&2; }
fi

# Redirect all stdout/stderr to log file (tee keeps it on console too)
mkdir -p "$(dirname "${LOG_FILE}")"
exec > >(tee -a "${LOG_FILE}") 2>&1

# --------------------------- Helpers ----------------------------------

cleanup_lock() {
  if [[ -f "${LOCK_FILE}" ]]; then
    rm -f "${LOCK_FILE}"
  fi
}

acquire_lock() {
  if [[ -f "${LOCK_FILE}" ]]; then
    log_error "Lock file exists: ${LOCK_FILE}. Another backup may be running."
    log_error "If no backup is running, delete the lock file and retry."
    exit 1
  fi
  echo "${TIMESTAMP}" > "${LOCK_FILE}"
  trap cleanup_lock EXIT INT TERM
}

print_header() {
  log_info "------------------------------------------------------------"
  log_info " SRE Laptop Backup – Borg"
  log_info " Host:       ${HOSTNAME_SHORT}"
  log_info " Start time: ${TIMESTAMP}"
  log_info " Backup root: ${BACKUP_ROOT}"
  log_info " Borg repo:   ${BORG_REPO}"
  log_info " Log file:    ${LOG_FILE}"
  log_info "------------------------------------------------------------"
}

usage() {
  cat <<USAGE
Usage: $(basename "$0") [dry-run]

Options:
  dry-run   Perform a borg --dry-run (no data written), no prune/check.

Environment:
  BACKUP_ROOT   (default: \$HOME/system-backups)
  BORG_REPO     (default: \$BACKUP_ROOT/borg_repo)
  BACKUP_TAG    (default: system)

  BORG_PRUNE_KEEP_DAILY   (default: ${BORG_PRUNE_KEEP_DAILY})
  BORG_PRUNE_KEEP_WEEKLY  (default: ${BORG_PRUNE_KEEP_WEEKLY})
  BORG_PRUNE_KEEP_MONTHLY (default: ${BORG_PRUNE_KEEP_MONTHLY})

Ensure BORG_PASSPHRASE or BORG_PASSCOMMAND is set for non-interactive runs.
USAGE
}

# ------------------------- Pre-flight ---------------------------------

if [[ "${1:-}" == "help" || "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

DRY_RUN=false
if [[ "${1:-}" == "dry-run" ]]; then
  DRY_RUN=true
fi

acquire_lock
print_header

log_info "Step 1: Verifying required tools..."
if ! command -v borg >/dev/null 2>&1; then
  log_error "borg command not found. Install BorgBackup and retry."
  exit 1
fi
log_info "borg: $(command -v borg)"

log_info "Step 2: Ensuring backup root exists..."
mkdir -p "${BACKUP_ROOT}"

log_info "Step 3: Validating Borg repository..."
mkdir -p "$(dirname "${BORG_REPO}")"
if [[ ! -d "${BORG_REPO}" ]] || [[ -z "$(ls -A "${BORG_REPO}" 2>/dev/null || true)" ]]; then
  log_warn "Borg repo not initialized or empty at: ${BORG_REPO}"
  log_info "Initializing Borg repository (repokey-blake2)..."
  borg init --encryption=repokey-blake2 "${BORG_REPO}"
else
  log_info "Borg repository seems present at ${BORG_REPO}"
fi

if [[ -z "${BORG_PASSPHRASE:-}" && -z "${BORG_PASSCOMMAND:-}" ]]; then
  log_warn "BORG_PASSPHRASE / BORG_PASSCOMMAND not set."
  log_warn "borg may prompt interactively for the passphrase."
fi

# -------------------- Source & Exclude Sets ---------------------------

log_info "Step 4: Building source and exclude sets..."

# Curated include set to avoid noisy/ephemeral content
INCLUDE_PATHS=(
  "$HOME/Documents"
  "$HOME/Pictures"
  "$HOME/Music"
  "$HOME/Videos"
  "$HOME/repos"
  "$HOME/.config"
  "$HOME/.ssh"
  "/etc"
)

# Exclusions tuned for SRE workstation usage
EXCLUDE_PATTERNS=(
  "$HOME/.cache"
  "$HOME/.local/share/Trash"
  "$HOME/Downloads"
  "$HOME/db"
  "$HOME/.thunderbird"
  "$BACKUP_ROOT"
  "/proc"
  "/sys"
  "/dev"
  "/run"
  "/tmp"
  "/var/tmp"
  "/var/cache"
)

SOURCES=()
for path in "${INCLUDE_PATHS[@]}"; do
  if [[ -e "${path}" ]]; then
    SOURCES+=("${path}")
  else
    log_warn "Skipping missing path: ${path}"
  fi
done

if ((${#SOURCES[@]} == 0)); then
  log_error "No valid source paths found to back up. Aborting."
  exit 1
fi

EXCLUDE_ARGS=()
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
  EXCLUDE_ARGS+=( "--exclude" "${pattern}" )
done

log_info "Sources to back up:"
for s in "${SOURCES[@]}"; do
  log_info "  - ${s}"
done

log_info "Exclude patterns:"
for e in "${EXCLUDE_PATTERNS[@]}"; do
  log_info "  - ${e}"
done

# -------------------- Borg Create / Prune / Check ---------------------

log_info "Step 5: Running borg create..."

BORG_CREATE_FLAGS=(
  "--verbose"
  "--stats"
  "--filter" "AME"
  "--compression" "lz4"
  "--exclude-caches"
)

if "${DRY_RUN}"; then
  BORG_CREATE_FLAGS+=( "--dry-run" )
  log_warn "DRY RUN ENABLED: No data will be written to the repository."
fi

log_info "Archive name: ${ARCHIVE_NAME}"

borg create \
  "${BORG_CREATE_FLAGS[@]}" \
  "${EXCLUDE_ARGS[@]}" \
  "${BORG_REPO}::${ARCHIVE_NAME}" \
  "${SOURCES[@]}"

log_info "borg create completed."

if ! "${DRY_RUN}"; then
  log_info "Step 6: Pruning old archives..."
  borg prune \
    --list \
    --keep-daily="${BORG_PRUNE_KEEP_DAILY}" \
    --keep-weekly="${BORG_PRUNE_KEEP_WEEKLY}" \
    --keep-monthly="${BORG_PRUNE_KEEP_MONTHLY}" \
    "${BORG_REPO}"

  log_info "Prune completed."

  log_info "Step 7: Running integrity check on new archive..."
  borg check --verbose "${BORG_REPO}::${ARCHIVE_NAME}"
  log_info "Integrity check completed."
else
  log_info "Dry run enabled: skipping prune and check."
fi

log_info "------------------------------------------------------------"
log_info "Backup completed successfully."
log_info "Archive: ${BORG_REPO}::${ARCHIVE_NAME}"
log_info "Log:     ${LOG_FILE}"
log_info "------------------------------------------------------------"

exit 0
