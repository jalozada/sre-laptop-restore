# SRE Laptop Backup Pipeline — Runbook
Project: sre-laptop-restore  
Backup Engine: BorgBackup  
Location: $HOME/system-backups/

---

## 1. Purpose
This runbook documents all steps, commands, and workflow used for the laptop backup pipeline.

---

## 2. Run a Normal Backup

~/repos/sre-laptop-restore/system_backup.sh

---

## 3. Run a Dry-Run Backup (No Changes)

~/repos/sre-laptop-restore/system_backup.sh dry-run

---

## 4. View Backup Logs


ls -lh ~/system-backups/logs/
cat ~/system-backups/logs/system_backup_$(ls ~/system-backups/logs | sort | tail -n1)

---

## 5. List All Archives

borg list ~/system-backups/borg_repo

---

## 6. Show Info for a Specific Archive

borg info ~/system-backups/borg_repo::ARCHIVE_NAME

---

## 7. Verify Archive Integrity

borg check ~/system-backups/borg_repo::ARCHIVE_NAME

---

## 8. Restore a Single File

borg extract ~/system-backups/borg_repo::ARCHIVE_NAME path/to/file

---

## 9. Restore a Directory

borg extract ~/system-backups/borg_repo::ARCHIVE_NAME Documents/

---

## 10. Restore Home Directory

borg extract ~/system-backups/borg_repo::ARCHIVE_NAME home/javier

---

## 11. Mount an Archive (Browse)

mkdir -p ~/borg-mount
borg mount ~/system-backups/borg_repo::ARCHIVE_NAME ~/borg-mount

Unmount:

borg umount ~/borg-mount

---

## 12. Manual Prune (Optional)

borg prune --list
--keep-daily 7
--keep-weekly 4
--keep-monthly 6
~/system-backups/borg_repo

---

## 13. Repo Size

du -sh ~/system-backups/borg_repo

---

## 14. Lock File Check

ls -l /tmp/system_backup.lock
rm -f /tmp/system_backup.lock

---

## 15. Quick Full Restore Test

borg mount ~/system-backups/borg_repo::ARCHIVE_NAME ~/borg-mount

---

## 16. Repo Integrity Check

borg check ~/system-backups/borg_repo

---

## 17. Reset Repo (Last Resort)

rm -rf ~/system-backups/borg_repo
borg init --encryption=repokey-blake2 ~/system-backups/borg_repo

---

