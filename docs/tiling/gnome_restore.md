# GNOME Environment Restore Runbook  
SRE Workstation – GNOME, Tiling Assistant, Keybindings, Monitors  
Author: Javier Lozada  
Status: Private Internal Document  
Last Updated: $(date)

---

## 1. Purpose  
This runbook documents how to **backup** and **restore** all GNOME environment settings on the SRE workstation, including:

- GNOME Shell settings  
- Tiling Assistant configuration  
- Custom keybindings  
- Workspaces  
- Keyboard delay/repeat settings  
- Display layout (ASUS + Samsung external monitors)  
- GNOME extensions  
- General GUI preferences  

These settings are backed up and restored using the `dconf` database.

---

## 2. Directory Structure  


configs/dconf/
├── dconf_backup.sh
├── dconf_restore.sh
├── backups/
│ └── dconf_full_YYYYMMDD_HHMMSS.ini
└── logs/
├── dconf_backup_.log
└── dconf_restore_.log

---

## 3. Backup Procedure (Before OS Wipe or System Migration)

Run the backup script:


~/repos/sre-laptop-restore/configs/dconf/dconf_backup.sh

This will produce an output file similar to:


configs/dconf/backups/dconf_full_20251115_230501.ini

### What Gets Backed Up

- Full GNOME preferences  
- Tiling Assistant settings  
- Hotkeys such as:
  - Move window to left/right  
  - Toggle tiling  
  - Workspace switching  
  - Custom shortcuts  
- Display configuration for:
  - Primary ASUS external monitor  
  - Samsung monitor  
- Input device settings  
- Extension preferences  

All logs go to:


configs/dconf/logs/dconf_backup_*.log

---

## 4. Restore Procedure (After reinstall or disaster recovery)

Restore is initiated with:


~/repos/sre-laptop-restore/configs/dconf/dconf_restore.sh

### The restore script currently performs:

- Validation of `dconf` availability  
- Validation of backup file presence  
- Non-destructive placeholder restore  
- Logging of the intended actions  

### Future destructive restore command:


dconf load / < configs/dconf/backups/dconf_full_YYYYMMDD.ini

This will **completely overwrite** GNOME settings with the ones previously exported.

---

## 5. Monitor Layout (ASUS + Samsung)

The dconf export captures:

- Monitor arrangement  
- Scale factor  
- Fractional scaling  
- Primary monitor selection  
- Refresh rate  

You do **not** need to manually reconfigure these after restore.

---

## 6. Validation After Restore

After running the restore script:

1. Log out and log back in  
2. Verify:  
   - Keybindings working  
   - Tiling Assistant auto-tiling  
   - Workspaces  
   - Display layout  
   - Keyboard repeat rate  
   - GNOME Shell Extensions

---

## 7. Troubleshooting

### Issue: Only partial settings restore  
Run:


dconf dump /

Compare with your backup file.

### Issue: Tiling Assistant not applying  
Make sure the GNOME extension is enabled:


gnome-extensions enable tiling-assistant@ubuntu.com

### Issue: Wrong monitor layout  
GNOME sometimes needs a restart:


killall -3 gnome-shell

(Will restart shell without closing windows.)

---

## 8. Notes

- Always regenerate a fresh backup after major UI changes.  
- Never restore an outdated GNOME configuration between major GNOME versions.  
- The backup prefix (`dconf_full_YYYYMMDD`) ensures no overwrites happen.  

---

## 9. Related Scripts

- `restore/system_restore.sh`  
- `restore/preflight_check.sh`  
- `configs/dconf/dconf_backup.sh`  
- `configs/dconf/dconf_restore.sh`  
