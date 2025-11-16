#!/usr/bin/env bash
#
# vscode_backup.sh
# --------------------------------------------------------
# Captures current VS Code configuration and extensions
# into the repo for reproducible SRE restore.
#
# Outputs to: configs/vscode/
# Logs to: logs/vscode_backup_*.log
# --------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$ROOT_DIR/logs"
CONFIG_DIR="$ROOT_DIR/configs/vscode"
USER_DIR="$HOME/.config/Code/User"

mkdir -p "$LOG_DIR" "$CONFIG_DIR"
LOG_FILE="$LOG_DIR/vscode_backup_$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_FILE"; }

log "--------------------------------------------------------"
log "VS Code Backup Phase Started"
log "--------------------------------------------------------"

# Validate VS Code
if ! command -v code &>/dev/null; then
  log "VS Code not installed — cannot perform backup."
  exit 0
fi

# Backup settings.json
if [[ -f "$USER_DIR/settings.json" ]]; then
  cp -v "$USER_DIR/settings.json" "$CONFIG_DIR/" | tee -a "$LOG_FILE"
else
  log "No settings.json found."
fi

# Backup keybindings.json
if [[ -f "$USER_DIR/keybindings.json" ]]; then
  cp -v "$USER_DIR/keybindings.json" "$CONFIG_DIR/" | tee -a "$LOG_FILE"
else
  log "No keybindings.json found."
fi

# Backup snippets directory
if [[ -d "$USER_DIR/snippets" ]]; then
  mkdir -p "$CONFIG_DIR/snippets"
  cp -vr "$USER_DIR/snippets/" "$CONFIG_DIR/snippets/" | tee -a "$LOG_FILE"
else
  log "No snippets directory found."
fi

# Backup extensions list
EXT_FILE="$CONFIG_DIR/extensions.txt"
log "Exporting installed VS Code extensions..."
code --list-extensions > "$EXT_FILE"
log "Extensions list saved at: $EXT_FILE"

log "VS Code Backup Phase Completed"
log "--------------------------------------------------------"
