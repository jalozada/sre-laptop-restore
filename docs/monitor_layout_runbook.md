# Monitor Layout Capture & Restore – SRE Laptop Restore Project

**Author:** Javier Antonio Lozada  
**Repository:** jalozada/sre-laptop-restore  
**Last Updated:** 2025-11-18  

---

# 📌 Purpose
This runbook documents the **monitor layout capture and restore process** for multi-monitor SRE workstation setups.

It includes:

- Capturing monitor configuration (per-monitor geometry, refresh rate, rotation, primary display)
- Restoring monitor layout after reinstall
- Understanding JSON layout format
- Validating GNOME display settings  
- Integrating with system restore pipeline

This is part of the **SRE Laptop Restore project** and separate from the Grafana Homelab.

---

# 🧩 1. Monitor Layout Capture Script

The capture script is located at:

~/repos/sre-laptop-restore/scripts/monitor_layout_capture.sh

It saves the current monitor configuration to:

~/repos/sre-laptop-restore/configs/gnome/monitor_layout.json

---

# 🖥️ 2. Capture Current Monitor Layout

### Step 1 — Run capture script  
~/repos/sre-laptop-restore/scripts/monitor_layout_capture.sh

### Step 2 — Validate the output file  
cat ~/repos/sre-laptop-restore/configs/gnome/monitor_layout.json

Expected fields include:

- `name`
- `primary`
- `resolution`
- `position`
- `rotation`
- `refresh_rate`

Example snippet:
{
"HDMI-1": {
"primary": true,
"resolution": "3840x2160",
"position": "0x0",
"rotation": "normal",
"refresh_rate": "120.00"
}
}

---

# 🔁 3. Restore Monitor Layout (Manual Method)

Since GNOME does **not** provide a stable CLI API for layout restore, the method is:

### Step 1 — Open GNOME Display Settings  
gnome-control-center display

### Step 2 — Arrange monitors to match JSON  
cat ~/repos/sre-laptop-restore/configs/gnome/monitor_layout.json

### Step 3 — Apply resolution, scaling, rotation  
Use the GUI controls.

### Step 4 — Apply refresh rate  
Settings → Displays → Refresh Rate

---

# 🔁 4. Restore Monitor Layout (Future Automation – Optional)

If you want automated restore later, the script can parse:

monitor_layout.json

And apply via:

- `xrandr` (X11)
- Mutter DBus APIs (Wayland, unstable)
- GNOME shell extensions (not recommended)

Current restore remains manual for:

✔️ stability  
✔️ Wayland limitations  
✔️ avoiding GNOME crashes  

---

# 🧪 5. Post-Restore Validation

### Step 1 — Confirm detected monitors  
xrandr --listmonitors

### Step 2 — Confirm GNOME sees the correct layout  
gsettings get org.gnome.desktop.interface scaling-factor

### Step 3 — Validate resolution  
xrandr | grep -E " connected|[*]"

### Step 4 — Validate primary monitor  
gsettings get org.gnome.desktop.wm.preferences focus-new-windows

### Step 5 — Validate refresh rate  
Open Settings → Displays → Refresh Rate

### Step 6 — Validate orientation  
Check orientation per monitor.

---

# 📦 6. JSON Layout Backup Location

Backups stored at:

~/repos/sre-laptop-restore/configs/gnome/monitor_layout.json

List all captured layouts:

ls -lh ~/repos/sre-laptop-restore/configs/gnome/

---

# 🔍 7. Troubleshooting

### Issue: Wrong monitor numbering  
xrandr --listmonitors  
Match with JSON.

### Issue: Monitors swapped  
Use GNOME UI drag-and-drop.

### Issue: Wrong resolution  
Settings → Displays → Resolution

### Issue: Wrong refresh  
Settings → Displays → Refresh Rate  
(Some adapters/cables don’t support high refresh rates)

---

# ✔️ Completed
Your monitor layout is now fully captured, documented, and restorable as part of the SRE Laptop Restore project.
