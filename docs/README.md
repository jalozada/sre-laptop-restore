# SRE Laptop Restore – Master Runbook

**Author:** Javier Antonio Lozada  
**Repository:** jalozada/sre-laptop-restore  
**Last Updated:** 2025-11-18  

---

# 📌 Purpose
This Master Runbook provides a **single navigation point** for all restore and configuration documentation used in the **SRE Laptop Restore Project**.

This project is **stand-alone** and **NOT part of the Grafana Cloud SRE Homelab**.

It contains:

- Full backup/restore automation  
- GNOME environment restore  
- VS Code environment restore  
- Monitor layout capture & restore  
- Browser optimization restores  
- SSH and system state restore  

Each page includes exact commands, one-step restore instructions, and SRE-grade reproducibility.

---

# 📚 Runbook Sections

## 1. **System Backup Runbook**
Path:  

docs/system_backup_runbook.md
Covers:
- Borg backup pipeline  
- Deduplication  
- Repo initialization  
- Prune policy  
- Restore from archive  
- Verification  
- Troubleshooting  

---

## 2. **System Restore Pipeline**
Path:  

docs/system_restore_runbook.md
Includes:
- Full system_restore.sh automation  
- GNOME restore  
- VS Code/Browser restore  
- SSH restore  
- Post-reinstall validation  
- Optional Borg archive extraction  

---

## 3. **VS Code Restore Guide**
Path:  

docs/vscode_restore_runbook.md
Includes:
- Install VS Code  
- Restore all required extensions  
- Restore settings.json  
- Restore keybindings/snippets  
- Validation steps  

---

## 4. **GNOME + Tiling Assistant Restore Guide**
Path:  

docs/gnome_restore_runbook.md
Includes:
- dconf restore  
- Keyboard shortcuts  
- Tiling Assistant config  
- Shell extension validation  
- GNOME layout integrity checks  

---

## 5. **Monitor Layout Capture & Restore Guide**
Path:  

docs/monitor_layout_runbook.md
Includes:
- Capture multi-monitor layout  
- JSON structure  
- Manual restore steps  
- Validation  
- Future automation notes  

---

# 🗃️ Project Directory Structure (Reference)


sre-laptop-restore/
├── backup/
├── configs/
│ ├── firefox/
│ ├── gnome/
│ ├── vscode/
│ ├── ssh/
├── docs/
│ ├── README.md ← Master Runbook (this file)
│ ├── system_backup_runbook.md
│ ├── system_restore_runbook.md
│ ├── vscode_restore_runbook.md
│ ├── gnome_restore_runbook.md
│ ├── monitor_layout_runbook.md
├── scripts/
├── logs/
├── system_backup.sh
├── system_restore.sh
├── system_restore_runner.sh
└── system_restore_validate.sh

---

# ✔️ Completed
Your **Master Runbook** now provides a clean, unified, professional SRE documentation hub for the entire laptop restore project.

