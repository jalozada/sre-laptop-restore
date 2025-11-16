#!/usr/bin/env bash
#
# vscode_restore.sh
# --------------------------------------------------------
# Restores VS Code configuration (settings, keybindings,
# snippets) and extensions list from tracked repo config.
#
# Logs to: logs/vscode_restore_*.log
# --------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$ROOT_DIR/logs"
CONFIG_DIR="$ROOT_DIR/configs/vscode"
BACKUP_DIR="$HOME/.config/Code/User"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/vscode_restore_$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG_FILE"; }

log "--------------------------------------------------------"
log "VS Code Restore Phase Started"
log "--------------------------------------------------------"

# Ensure VS Code exists
if ! command -v code &>/dev/null; then
  log "VS Code not found — installing..."
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | sudo gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list

  sudo apt update
  sudo apt install -y code
  log "VS Code installed."
else
  log "VS Code already installed."
fi

mkdir -p "$BACKUP_DIR"

# Restore settings.json
if [[ -f "$CONFIG_DIR/settings.json" ]]; then
  cp -v "$CONFIG_DIR/settings.json" "$BACKUP_DIR/" | tee -a "$LOG_FILE"
else
  log "No settings.json found in repo; skipping."
fi

# Restore keybindings
if [[ -f "$CONFIG_DIR/keybindings.json" ]]; then
  cp -v "$CONFIG_DIR/keybindings.json" "$BACKUP_DIR/" | tee -a "$LOG_FILE"
else
  log "No keybindings.json found in repo; skipping."
fi

# Restore snippets
if [[ -d "$CONFIG_DIR/snippets" ]]; then
  mkdir -p "$BACKUP_DIR/snippets"
  cp -vr "$CONFIG_DIR/snippets/"* "$BACKUP_DIR/snippets/" | tee -a "$LOG_FILE"
else
  log "No snippets directory found in repo; skipping."
fi

# Restore extensions
EXT_FILE="$CONFIG_DIR/extensions.txt"
if [[ -f "$EXT_FILE" ]]; then
  log "Restoring VS Code extensions…"
  while read -r ext; do
    [[ -n "$ext" ]] && code --install-extension "$ext" | tee -a "$LOG_FILE"
  done < "$EXT_FILE"
else
  log "No extensions.txt found; skipping extension install."
fi

log "VS Code Restore Phase Completed"
log "--------------------------------------------------------"
