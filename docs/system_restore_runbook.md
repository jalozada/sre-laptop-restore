# System Restore Pipeline – SRE Laptop Restore Project

**Author:** Javier Antonio Lozada  
**Repository:** jalozada/sre-laptop-restore  
**Last Updated:** 2025-11-18  

---

# 📌 Purpose
This runbook documents the **full restore process** used after reinstalling Ubuntu, including:

- System restore automation script
- GNOME/Tiling Assistant restore
- Firefox and Chrome hardening restore
- VS Code restore
- Monitor layout restore
- Backup archive extraction (if needed)

Each step is designed for **repeatable**, **SRE-grade**, **post-reinstall recovery**.

---

# 📂 1. Prerequisites After a Fresh Install

### Step 1 — Ensure Git is installed  

sudo apt install -y git

### Step 2 — Clone the restore repo  

git clone https://github.com/jalozada/sre-laptop-restore

### Step 3 — Make all scripts executable  

chmod -R +x ~/repos/sre-laptop-restore

---

# 🔁 2. Run the Full Restore Pipeline

Your main restore orchestrator is:

~/repos/sre-laptop-restore/system_restore.sh

### Step 1 — Execute the restore pipeline  

~/repos/sre-laptop-restore/system_restore.sh

This script performs:

- GNOME dconf restore  
- VS Code extension restore  
- Firefox optimization restore  
- Chrome optimization restore  
- Monitor layout detection  
- Post-restore system updates  
- Validation checks  

---

# 🖥️ 3. GNOME + Tiling Assistant Restore

### Step 1 — Import GNOME configuration  

dconf load / < ~/repos/sre-laptop-restore/configs/gnome/dconf-backup.conf

### Step 2 — Install Tiling Assistant  

sudo apt install -y gnome-shell-extension-manager

### Step 3 — Enable extensions (if required):

gnome-extensions enable tiling-assistant@leleat-on-github

Your restore script handles most of this automatically.

---

# 🧭 4. Monitor Layout Restore

### Step 1 — View most recent captured layout  

cat ~/repos/sre-laptop-restore/configs/gnome/monitor_layout.json

### Step 2 — Apply GNOME layout  

~/repos/sre-laptop-restore/scripts/monitor_layout_capture.sh

### (Optional) If manually restoring layouts:  
Use GNOME Control Center → Displays.

---

# 🌐 5. Firefox Restore

### Step 1 — Restore Firefox user.js  

cp ~/repos/sre-laptop-restore/configs/firefox/user.js ~/.mozilla/firefox/*.default-release/

### Step 2 — Run your optimization script  

~/scripts/optimize_firefox.sh

---

# 🌐 6. Chrome Restore

### Step 1 — Restore Chrome settings  

~/scripts/optimize_chrome.sh

Everything for Chrome is handled in a single step.

---

# 💻 7. VS Code Restore

### Step 1 — Install VS Code  

sudo apt install -y code

### Step 2 — Restore extensions  

code --install-extension ms-vscode-remote.remote-containers
code --install-extension hashicorp.terraform
code --install-extension redhat.vscode-yaml
code --install-extension ms-azuretools.vscode-docker
code --install-extension github.copilot

(Your restore script automates this list.)

### Step 3 — Restore settings.json  

cp ~/repos/sre-laptop-restore/configs/vscode/settings.json ~/.config/Code/User/settings.json

---

# 🔐 8. SSH Restore

### Step 1 — Copy SSH folder  

cp -r ~/repos/sre-laptop-restore/configs/ssh ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

### Step 2 — Test  

ssh -T git@github.com

---

# 🗄️ 9. Restore From Backup Archive (If Needed)

### Step 1 — List Borg archives  

borg list ~/system-backups/borg_repo

### Step 2 — Restore home directory  

borg extract ~/system-backups/borg_repo::ARCHIVE_NAME home/javier

### Step 3 — Restore specific folders  

borg extract ~/system-backups/borg_repo::ARCHIVE_NAME Documents/

### Step 4 — Mount for browsing  

borg mount ~/system-backups/borg_repo::ARCHIVE_NAME ~/borg-mount

Unmount:

borg umount ~/borg-mount

---

# 🧪 10. Post-Restore Validation (Critical)

### Step 1 — Validate GNOME  

gnome-extensions list

### Step 2 — Validate Firefox hardening  

grep -i privacy ~/.mozilla/firefox/*.default-release/user.js

### Step 3 — Validate VS Code  

code --list-extensions

### Step 4 — Validate Chrome  
Open Chrome → settings → check extensions.

### Step 5 — Validate Monitor Layout  
Open Settings → Displays.

---

# ✔️ Completed  
Your system is now restored using a fully automated SRE-grade process.
