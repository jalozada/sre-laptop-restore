# Backup Automation Runbook

## Overview
This document outlines the automated nightly backup system using Borg Backup and a Samsung T9 external SSD. The system is implemented using systemd user-level service and timer units to ensure encrypted, deduplicated, and mirrored backups every night at 02:00 AM.

## Components
- **system_backup.sh** – Main backup script (Borg backup → prune → T9 rsync)
- **sre-backup.service** – Systemd service that executes the backup script
- **sre-backup.timer** – Systemd timer that schedules backups nightly at 02:00 AM
- **BORG_PASSCOMMAND** – Secure passphrase retrieval mechanism
- **T9 Mirror Path:** `/media/javier/T91/sre-backups`
- **Local Borg Repo:** `~/system-backups/borg_repo`

## Backup Flow
1. Run Borg backup (deduplicated, encrypted)
2. Apply retention policy (daily/weekly/monthly)
3. Mirror entire repo to Samsung T9
4. Log stored at `~/system-backups/logs/`
5. systemd tracks schedule and wake behavior

## Schedule
- **Nightly at:** 02:00 AM  
- **Persistent:** Yes — runs immediately on wake if laptop was sleeping

## Service File
`~/.config/systemd/user/sre-backup.service`

[Unit]
Description=SRE Laptop Automated Backup (Borg + T9 Sync)

[Service]
Type=oneshot
ExecStart=%h/repos/sre-laptop-restore/system_backup.sh
Nice=10
IOSchedulingClass=best-effort
IOSchedulingPriority=7
Environment="BORG_PASSCOMMAND=cat %h/.config/borg/passphrase"
StandardOutput=journal
StandardError=journal

## Timer File
`~/.config/systemd/user/sre-backup.timer`

[Unit]
Description=Nightly SRE Laptop Backup Timer (02:00 AM, run-on-wake)

[Timer]
OnCalendar=--* 02:00:00
Persistent=true
Unit=sre-backup.service

[Install]
WantedBy=timers.target

## Commands

### Enable Automation

systemctl --user daemon-reload
systemctl --user enable --now sre-backup.timer

### Validate Timer Status

systemctl --user list-timers | grep sre-backup

### Check Backup Logs

journalctl --user -u sre-backup.service

## Expected Behavior
- Nightly encrypted backup created  
- Local Borg repo updated  
- Retention applied  
- T9 mirror synced  
- No manual passphrase prompts  

## Troubleshooting
- If timer fails to start: verify unit syntax
- If backup stops early: check Borg exit handling (rc 1 warnings)
- Ensure T9 mount path `/media/javier/T91` exists before backup time
