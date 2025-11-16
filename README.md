# SRE Laptop Restore – Private Repo

This repository contains the complete rebuild, recovery, and configuration automation for my SRE workstation environment.  
It is a **private, non-public** repository and will **never be published** due to personal system paths, logs, and sensitive details.

## Purpose
- Automate full laptop recovery after hardware failure, OS reinstall, or environment corruption.
- Restore GNOME / tiling / keyboard / dconf settings.
- Reapply browser optimizations (Firefox/Chrome).
- Reinstall required SRE tooling and development environment.
- Reapply container and VM configuration.
- Restore backup logs, snapshots, and SRE-specific scripts.
- Maintain reproducibility of the workstation as an SRE platform.

## Repository Structure

- `backup/`  – Backup scripts, snapshot definitions, and backup-related logs.
- `configs/` – dconf exports, GNOME layouts, Firefox/Chrome configs, app settings.
- `docs/`    – Internal-only documentation and rebuild runbooks.
- `restore/` – End-to-end restore pipelines and orchestration scripts.
- `scripts/` – General-purpose helper scripts used during setup/restore.

## Security & Privacy
This repository includes system-level paths and metadata and must **remain private indefinitely**.  
No secrets, tokens, SSH keys, or cloud credentials should ever be committed.

## Rebuild Philosophy
- One-step-at-a-time execution with validation between steps.
- Use only full files (via cat/sed), not fragments.
- Avoid storing logs that reveal personal or legal information.
- Keep restore logic deterministic and reproducible.
