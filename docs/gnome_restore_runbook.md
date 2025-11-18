# GNOME + Tiling Assistant Restore Guide – SRE Laptop Restore Project

**Author:** Javier Antonio Lozada  
**Repository:** jalozada/sre-laptop-restore  
**Last Updated:** 2025-11-18  

---

# 📌 Purpose
This runbook documents the **complete GNOME desktop environment restore process**, including:

- GNOME dconf restore  
- Tiling Assistant setup  
- Keybindings/shortcuts  
- Extensions  
- Monitor layout integration  
- Validation steps  

This guide is part of the **SRE Laptop Restore Project** and is separate from the Grafana Homelab.

---

# 🧩 1. Restore GNOME Settings via dconf

### Step 1 — Apply GNOME configuration backup
dconf load / < ~/repos/sre-laptop-restore/configs/gnome/dconf-backup.conf

### Step 2 — Restart GNOME Shell (X11 only)
Press:

Alt + F2  
r  
Enter

### Step 3 — Wayland users
Logout → Login again  
(GNOME cannot hard-restart under Wayland.)

---

# 🧱 2. Install & Enable GNOME Extensions

### Step 1 — Install GNOME Shell Extension Manager
sudo apt install -y gnome-shell-extension-manager

### Step 2 — Enable Tiling Assistant
gnome-extensions enable tiling-assistant@leleat-on-github

### Step 3 — Validate GNOME recognizes the extension
gnome-extensions info tiling-assistant@leleat-on-github

Expected:
State: ENABLED

---

# 🪟 3. Restore GNOME Keyboard Shortcuts (Optional)

If shortcuts were backed up separately, restore them with:

### Step 1 — Restore WM Window Manager shortcuts
dconf load /org/gnome/desktop/wm/keybindings/ < \
~/repos/sre-laptop-restore/configs/gnome/wm-keybindings.conf

### Step 2 — Restore media keys (volume, brightness, etc.)
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < \
~/repos/sre-laptop-restore/configs/gnome/media-keys.conf

### Step 3 — Restore mutter (window tiling, edge resistance)
dconf load /org/gnome/mutter/ < \
~/repos/sre-laptop-restore/configs/gnome/mutter.conf

---

# 🧭 4. Restore Tiling Assistant Configuration

### Step 1 — Restore Tiling Assistant keybindings & settings
dconf load /org/gnome/shell/extensions/tiling-assistant/ < \
~/repos/sre-laptop-restore/configs/gnome/tiling-assistant.conf

### Step 2 — Validate values applied
dconf dump /org/gnome/shell/extensions/tiling-assistant/

---

# 🖥️ 5. Monitor Layout Integration

The display restore operation is handled in the **Monitor Layout Runbook**, but GNOME integration steps are included here for completeness.

### Step 1 — Validate current layout
cat ~/repos/sre-laptop-restore/configs/gnome/monitor_layout.json

### Step 2 — Capture current layout (post-restore)
~/repos/sre-laptop-restore/scripts/monitor_layout_capture.sh

### Step 3 — Apply layout if needed
Use **Settings → Displays**  
(or define a layout restore function in future script versions)

---

# 🛠️ 6. GNOME Shell Extensions Validation

### Step 1 — List all installed extensions
gnome-extensions list

### Step 2 — Show status of each
gnome-extensions show tiling-assistant@leleat-on-github

### Step 3 — Reload GNOME environment (optional)
gnome-shell --replace &
*(X11 only — dangerous on Wayland)*

---

# 🧪 7. Post-Restore Validation (Critical)

### Confirm GNOME settings applied
gsettings list-recursively | wc -l

### Confirm fractional scaling / performance settings
gsettings get org.gnome.mutter experimental-features

### Confirm Tiling Assistant works  
- Drag windows to edges  
- Use tiling shortcuts  
- Open Tiling Assistant preferences

### Confirm UI elements  
- Dock position  
- Hot corners  
- Workspaces behavior  

### Confirm keyboard shortcuts  
gsettings list-recursively org.gnome.desktop.wm.keybindings

---

# ✔️ Completed
Your GNOME desktop environment — including Tiling Assistant, shortcuts, preferences, and UI — is now fully restored using your SRE-grade reproducible configuration.
