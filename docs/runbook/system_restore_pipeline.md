# System Restore Pipeline Runbook

## Overview
This runbook documents the complete disaster recovery (DR) process for restoring the SRE Laptop using Borg Backup, encrypted repositories, and the Samsung T9 mirrored backup.

This guide restores:
- User files  
- Configurations  
- VS Code setup  
- GNOME/TilingAssistant settings  
- SSH keys  
- System-level customizations  
- Backup automation itself  

It assumes access to:
- **Local Borg repo**: `~/system-backups/borg_repo`
- **T9 mirror**: `/media/javier/T91/sre-backups`
- **Restore script**: `system_restore.sh`
- **Passphrase file**: `~/.config/borg/passphrase`

---

## Prerequisites

### 1. Ensure required packages are installed

sudo apt update
sudo apt install borgbackup rsync gnupg curl

### 2. Ensure T9 SSD is mounted

lsblk
ls /media/javier/T91

### 3. Export Borg passphrase command

export BORG_PASSCOMMAND="cat $HOME/.config/borg/passphrase"

---

## Restore Flow Overview

1. Validate hardware + T9 availability  
2. Restore GNOME/TilingAssistant layout  
3. Restore Firefox and Chrome optimizations  
4. Restore SSH keys  
5. Restore repositories  
6. Restore Documents/Pictures/Video directories  
7. Restore VS Code configuration  
8. Restore system packages and extensions  
9. Validate restored environment  
10. Re-enable backup automation  

---

## Step-by-Step Restore Process

### **Step 1 — Mount the T9 Mirror**

lsblk
sudo mkdir -p /media/javier/T91
sudo mount /dev/sda1 /media/javier/T91

### **Step 2 — Sync Borg repo back to laptop**
rsync -avh --delete /media/javier/T91/sre-backups/ ~/system-backups/borg_repo/

### **Step 3 — List available snapshots**

borg list ~/system-backups/borg_repo

### **Step 4 — Extract the latest snapshot**

borg extract ~/system-backups/borg_repo::<LATEST_ARCHIVE_NAME>

Replace `<LATEST_ARCHIVE_NAME>` with the newest archive — typically:


ThinkPad-P1-Gen-5-YYYYMMDD_HHMMSS

---

## Restore GNOME/TilingAssistant Configuration

If using a dconf backup:

dconf load / < ~/system-backups/gnome/backup.dconf

Validate:

dconf read /org/gnome/desktop/interface/clock-show-seconds

---

## Restore SSH keys

chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

---

## Restore VS Code Settings

Copy user settings:

rsync -avh restored_home/.config/Code/ ~/.config/Code/

---

## Restore Repositories


rsync -avh restored_home/repos/ ~/repos/

---

## Validate the Restore

### Check GNOME layout

gsettings get org.gnome.desktop.interface enable-animations

### Check backup health

borg check ~/system-backups/borg_repo

---

## Re-Enable Backup Automation


systemctl --user daemon-reload
systemctl --user enable --now sre-backup.timer

Check:

systemctl --user list-timers | grep sre-backup

---

## Final Notes

- This restore pipeline assumes full disk wipe or new hardware setup.  
- All data remains encrypted via Borg until restored.  
- T9 mirroring ensures DR even if the laptop fails completely.  

