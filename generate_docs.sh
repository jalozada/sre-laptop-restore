#!/usr/bin/env bash

# ============================================================
# SRE Laptop Restore Runbook – Auto-Generate Full Docs Tree
# ============================================================

DOCS_DIR="docs/runbook"
BASE_DIR="docs"

echo "[INFO] Creating documentation directories..."
mkdir -p $BASE_DIR
mkdir -p $DOCS_DIR/{backup,restore,borg,monitor,audio,browser,tiling,troubleshooting}

# ------------------------------------------------------------
# _config.yml
# ------------------------------------------------------------
cat << 'EOF' > docs/_config.yml
title: "SRE Laptop Restore Runbook"
description: "Documentation for Javier Lozada’s full SRE laptop backup and restore environment."
theme: "just-the-docs"

search_enabled: true

markdown: kramdown
kramdown:
  input: GFM
EOF

# ------------------------------------------------------------
# index.md
# ------------------------------------------------------------
cat << 'EOF' > docs/index.md
---
title: "Home"
layout: default
nav_order: 1
---

# 🛠️ SRE Laptop Restore Runbook
Full documentation for restoring and maintaining Javier Lozada’s SRE laptop environment.

[TOC]

---

# Table of Contents (Manual)
- [Purpose](#purpose)
- [Architecture Overview](#architecture-overview)
- [Components](#components)
- [Runbook Sections](#runbook-sections)
- [Support Notes](#support-notes)

---

## Purpose
This runbook documents all restore steps for your SRE laptop, ensuring reproducibility and reliability after every rebuild.

## Architecture Overview
High-level overview of backup + restore pipeline.

## Components
- Borg repo
- Samsung T9 mirror
- Browser optimization
- GNOME/Tiling
- Monitor/audio fixes

## Runbook Sections
See left sidebar navigation.

## Support Notes
Supplemental info for rebuild process.
EOF

# ------------------------------------------------------------
# Backup Section
# ------------------------------------------------------------
cat << 'EOF' > docs/runbook/backup/README.md
---
title: "Backup Pipeline"
layout: default
nav_order: 2
---

# 🔐 Backup Pipeline

[TOC]

---

# Table of Contents (Manual)
- [Purpose](#purpose)
- [Backup Architecture](#backup-architecture)
- [Borg Repository](#borg-repository)
- [Samsung T9 Mirror](#samsung-t9-mirror)
- [System Backup Script](#system-backup-script)
- [Validation Steps](#validation-steps)
- [Troubleshooting](#troubleshooting)

---

## Purpose
This section documents your SRE-grade backup strategy.

## Backup Architecture
Borg + T9 mirror + scripts.

## Borg Repository
Location: `/home/javier/system-backups/borg_repo`

## Samsung T9 Mirror
Secondary rsync-based backup.

## System Backup Script
Place full script here.

## Validation Steps
Commands for Borg integrity checks.

## Troubleshooting
Common backup issues and resolutions.
EOF

# ------------------------------------------------------------
# Restore Section
# ------------------------------------------------------------
cat << 'EOF' > docs/runbook/restore/README.md
---
title: "Restore Pipeline"
layout: default
nav_order: 3
---

# 🔁 Restore Pipeline

[TOC]

---

# Table of Contents (Manual)
- [Purpose](#purpose)
- [Restore Flow](#restore-flow)
- [Restore Order](#restore-order)
- [System Scripts](#system-scripts)
- [GNOME/Tiling](#gnometiling)
- [Monitor + Audio](#monitor--audio)
- [Browser Optimization](#browser-optimization)
- [Validation](#validation)

---

## Purpose
Documents full rebuild workflow after OS reinstall.

## Restore Flow
High-level steps from reinstall to validation.

## Restore Order
Exact sequence to follow.

## System Scripts
Restore script documentation here.

## GNOME/Tiling
dconf restore details.

## Monitor + Audio
xrandr + PipeWire fixes.

## Browser Optimization
Firefox/Chrome cleanup scripts.

## Validation
Post-restore checklist.
EOF

# ------------------------------------------------------------
# Borg Section
# ------------------------------------------------------------
cat << 'EOF' > docs/runbook/borg/README.md
---
title: "Borg Backup"
layout: default
nav_order: 4
---

# 🗄️ Borg Backup

[TOC]

---

# Table of Contents (Manual)
- [Purpose](#purpose)
- [Repo Structure](#repo-structure)
- [Encryption](#encryption)
- [Key Management](#key-management)
- [Commands](#commands)
- [Troubleshooting](#troubleshooting)

---

## Purpose
Detailed documentation for Borg encrypted repo.

## Repo Structure
Paths, cache, security folders.

## Encryption
repokey-blake2 details.

## Key Management
Passphrase storage + key location.

## Commands
borg create/list/extract/check here.

## Troubleshooting
Typical Borg issues and fixes.
EOF

# ------------------------------------------------------------
# Monitor Section
# ------------------------------------------------------------
cat << 'EOF' > docs/runbook/monitor/README.md
---
title: "Monitor Configuration & Recovery"
layout: default
nav_order: 5
---

# 🖥️ Monitor Configuration & Recovery

[TOC]

---

# Table of Contents (Manual)
- [Purpose](#purpose)
- [External Monitor Boot Fix](#external-monitor-boot-fix)
- [xrandr Commands](#xrandr-commands)
- [GNOME Layout](#gnome-layout)
- [Troubleshooting](#troubleshooting)

---

## Purpose
Documents monitor detection and layout restore process.

## External Monitor Boot Fix
GRUB video parameters and fix script.

## xrandr Commands
Common output + mode settings.

## GNOME Layout
Layout persistence via dconf.

## Troubleshooting
Display detection issues and fixes.
EOF

# ------------------------------------------------------------
# Audio Section
# ------------------------------------------------------------
cat << 'EOF' > docs/runbook/audio/README.md
---
title: "Audio Sink Recovery"
layout: default
nav_order: 6
---

# 🔊 Audio Sink Recovery

[TOC]

---

# Table of Contents (Manual)
- [Purpose](#purpose)
- [Default Sink Script](#default-sink-script)
- [PipeWire Commands](#pipewire-commands)
- [Troubleshooting](#troubleshooting)

---

## Purpose
Documentation for audio fix script.

## Default Sink Script
Moves active streams, sets correct sink.

## PipeWire Commands
Common pactl commands.

## Troubleshooting
Fix common audio problems.
EOF

# ------------------------------------------------------------
# Browser Section
# ------------------------------------------------------------
cat << 'EOF' > docs/runbook/browser/README.md
---
title: "Browser Optimization"
layout: default
nav_order: 7
---

# 🌐 Browser Optimization

[TOC]

---

# Table of Contents (Manual)
- [Purpose](#purpose)
- [Firefox Optimization](#firefox-optimization)
- [Chrome Optimization](#chrome-optimization)
- [Troubleshooting](#troubleshooting)

---

## Purpose
Documents Firefox + Chrome hardening.

## Firefox Optimization
user.js, telemetry disable script.

## Chrome Optimization
Chromium prefs, cleanup script.

## Troubleshooting
Browser issues and fixes.
EOF

# ------------------------------------------------------------
# Tiling Section
# ------------------------------------------------------------
cat << 'EOF' > docs/runbook/tiling/README.md
---
title: "GNOME & Tiling Assistant"
layout: default
nav_order: 8
---

# 🪟 GNOME & Tiling Assistant

[TOC]

---

# Table of Contents (Manual)
- [Purpose](#purpose)
- [GNOME Settings](#gnome-settings)
- [Tiling Assistant](#tiling-assistant)
- [Backup/Restore](#backuprestore)
- [Troubleshooting](#troubleshooting)

---

## Purpose
GNOME + tiling config documentation.

## GNOME Settings
dconf backup/restore.

## Tiling Assistant
Shortcuts, presets.

## Backup/Restore
System restore integration.

## Troubleshooting
Fix layout or extension issues.
EOF

# ------------------------------------------------------------
# Troubleshooting Section
# ------------------------------------------------------------
cat << 'EOF' > docs/runbook/troubleshooting/README.md
---
title: "Troubleshooting"
layout: default
nav_order: 9
---

# 🧰 Troubleshooting

[TOC]

---

# Table of Contents (Manual)
- [System Failures](#system-failures)
- [Backup/Restore Issues](#backuprestore-issues)
- [Monitor Issues](#monitor-issues)
- [Audio Issues](#audio-issues)
- [Browser Issues](#browser-issues)
- [Networking](#networking)
- [Common Commands](#common-commands)

---

## System Failures
General diagnostic methods.

## Backup/Restore Issues
Borg + rsync checks.

## Monitor Issues
xrandr + video=GRUB flags.

## Audio Issues
PipeWire resets.

## Browser Issues
Extension or profile problems.

## Networking
nmcli diagnostics.

## Common Commands
Collection of useful commands.
EOF

echo "[SUCCESS] All documentation templates generated."
