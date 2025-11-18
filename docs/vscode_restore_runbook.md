# VS Code Restore Guide – SRE Laptop Restore Project

**Author:** Javier Antonio Lozada  
**Repository:** jalozada/sre-laptop-restore  
**Last Updated:** 2025-11-18  

---

# 📌 Purpose
This runbook documents the full restore workflow for Visual Studio Code as part of the SRE Laptop Restore project.

It includes:

- Installing VS Code  
- Restoring extensions  
- Restoring settings.json  
- Restoring keybindings.json  
- Restoring snippets  
- Post-restore validation  

This document is separate from the Grafana Homelab and belongs exclusively to the SRE Laptop Restore project.

---

# 🧩 1. Install VS Code

### Step 1 — Install from apt repository
sudo apt install -y code

### Step 2 — Validate installation
code --version

---

# 📦 2. Restore Extensions

### Step 1 — Restore primary SRE/DevOps extensions
code --install-extension ms-vscode-remote.remote-containers
code --install-extension hashicorp.terraform
code --install-extension redhat.vscode-yaml
code --install-extension ms-azuretools.vscode-docker
code --install-extension github.copilot
code --install-extension github.vscode-github-actions
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools

### Step 2 — Restore all extensions from backup list (optional)
xargs -n1 code --install-extension < ~/repos/sre-laptop-restore/configs/vscode/extensions.list

---

# ⚙️ 3. Restore settings.json

### Step 1 — Copy settings.json
cp ~/repos/sre-laptop-restore/configs/vscode/settings.json ~/.config/Code/User/settings.json

### Step 2 — Validate  
cat ~/.config/Code/User/settings.json

---

# 🎹 4. Restore keybindings.json (optional)

### Step 1 — Copy keybindings  
cp ~/repos/sre-laptop-restore/configs/vscode/keybindings.json ~/.config/Code/User/keybindings.json

### Step 2 — Validate  
cat ~/.config/Code/User/keybindings.json

---

# 🧩 5. Restore Snippets (optional)

### Step 1 — Ensure snippet directory exists  
mkdir -p ~/.config/Code/User/snippets

### Step 2 — Restore snippets  
cp ~/repos/sre-laptop-restore/configs/vscode/snippets/* ~/.config/Code/User/snippets/

---

# 🧪 6. Post-Restore Validation

### Step 1 — Validate extension list  
code --list-extensions

### Step 2 — Validate settings.json in UI  
Open VS Code → File → Preferences → Settings

### Step 3 — Test language extensions  
Open Terraform/YAML → verify syntax highlighting

### Step 4 — Verify GitHub Copilot  
Command Palette → “Copilot: Status”

---

# ✔️ Completed
VS Code is fully restored with your extensions, preferences, and development environment settings.

