# VS Code Backup & Restore  
**Author:** Javier Antonio Lozada  
**Project:** SRE Laptop Restore  
**Last Updated:** $(date +%Y-%m-%d)

---

# 1. Purpose

This runbook defines the workflow to **backup and restore Visual Studio Code** as part of the SRE Laptop Restore Pipeline.

It ensures:
- Deterministic rebuilds of the development environment
- Restoration of all settings, keybindings, snippets, extensions
- Zero configuration drift across OS reinstalls

---

# 2. Components

### **2.1 Backup Script**
`scripts/vscode_backup.sh`

Performs:
- Export of all installed extensions
- Archive of entire user directory:

~/.config/Code/User/
- Timestamped `.tar.gz` stored under:


### **2.2 Restore Script**
`scripts/vscode_restore.sh`

Restores:
- Latest `.tar.gz` user directory backup
- Matching extension list file
- Reinstalls all extensions

### **2.3 System Restore Integration**
The VS Code restore runs in **Phase 5** of:

`system_restore.sh`

---

# 3. Backup Workflow

### Run manually:

bash scripts/vscode_backup.sh

This will:
1. Produce a timestamped archive:

configs/vscode/backup/vscode_user_YYYYMMDD_HHMMSS.tar.gz
2. Export installed extensions:

configs/vscode/backup/vscode_extensions_YYYYMMDD_HHMMSS.txt
3. Write logs to:

logs/vscode_backup_*.log

---

# 4. Restore Workflow

### Run manually:

bash scripts/vscode_restore.sh

The script automatically:
- Selects the newest config archive
- Selects the newest extension list
- Replaces all contents of:

~/.config/Code/User/
- Reinstalls every extension in the list

Logs:

logs/vscode_restore_*.log

---

# 5. Architecture


VS Code User Dir
↓
Tar Archive
↓
configs/vscode/backup/
↓
system_restore.sh (Phase 5)
↓
vscode_restore.sh

---

# 6. Idempotency Notes

- Running restore multiple times overwrites only VS Code’s own user directory.
- Extensions reinstall safely with `--force`, avoiding duplicates.
- Archives are read-only and timestamped to avoid conflicts.
- Backup script is always safe to run.

---

# 7. Failure Modes & Recovery

### **Missing backup archive**
- Run `vscode_backup.sh` at least once before running restore.

### **Code binary missing**
Restore script will log:

[ERROR] code: command not found
Install VS Code first:

sudo apt install code

### **Corrupted archive**
Verify integrity:


### **Corrupted archive**
Verify integrity:

tar -tzf <archive>

### **Extensions fail to install**
Network-related; retry using:

code --install-extension <EXTENSION>

---

# 8. Integration with Full Restore Pipeline

The VS Code restore executes in:


Phase 5 – system_restore.sh

Meaning:
- GNOME is restored first
- Browsers are optimized
- THEN VS Code receives its config and extensions

This ensures a predictable and consistent order of operations.

---

# 9. Summary

Your development environment becomes **fully portable**:

- Extensions ✔  
- Settings ✔  
- Keybindings ✔  
- Snippets ✔  
- Workspace config ✔  
- Logs ✔  

Everything required to rebuild VS Code is tracked in your repo and automatically restored after a clean OS install.

