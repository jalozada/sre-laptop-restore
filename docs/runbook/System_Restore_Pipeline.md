# SRE Laptop Restore Pipeline  
**Author:** Javier Antonio Lozada  
**Project:** SRE Laptop Restore  
**Repository:** `grafana-cloud-sre-lab/sre-laptop-restore`  
**Last Updated:** $(date +%Y-%m-%d)

---

# 1. Purpose

This runbook defines the **end-to-end SRE Laptop Restore Pipeline**, enabling a complete workstation rebuild after:

- OS reinstall  
- Hardware replacement  
- Profile corruption  
- GNOME reset  
- Major configuration drift  

The pipeline ensures **full reproducibility**, **predictable state**, and **rapid recovery** using version-controlled scripts.

---

# 2. High-Level Architecture


┌────────────────────────┐
│ system_restore_runner │
│ (single entrypoint) │
└─────────────┬──────────┘
│
▼
┌────────────────────────┐
│ system_restore_validate│
│ Pre-flight checks │
│ (files, binaries, json)│
└─────────────┬──────────┘
│ OK
▼
┌────────────────────────┐
│ system_restore.sh │
│ Full restore pipeline │
│ - GNOME/Tiling │
│ - Browser prefs │
│ - Monitor layout │
│ - Repo check │
└─────────────┬──────────┘
│
▼
Logs → logs/system_restore_*.log

---

# 3. Components

### **3.1 system_restore_runner.sh**
Single entrypoint.  
Executes validation → executes restore → writes unified logs.

### **3.2 system_restore_validate.sh**
Pre-flight validation:
- Ensures required binaries (`jq`, `xrandr`, `dconf`)
- Verifies all scripts exist  
- Checks JSON integrity  
- Confirms GNOME config file exists  
- Ensures repo consistency  

### **3.3 system_restore.sh**
The full restore workflow:
- Monitor layout capture  
- GNOME + TilingAssistant restoration  
- Firefox optimization  
- Chrome optimization  
- Repo validation  
- Monitor layout restore  

### **3.4 Supporting Scripts**
- `monitor_layout_capture.sh`  
- `monitor_layout_restore.sh`  
- `optimize_firefox.sh`  
- `optimize_chrome.sh`  
- `log.sh`  

---

# 4. Execution Flow

### **4.1 Pre-flight**

bash system_restore_runner.sh
└── runs validation
└── halts if any failure

### **4.2 Restore**
If validation passes:
- Load GNOME settings  
- Apply browser optimizations  
- Capture and restore monitor layout  
- Verify repo clean state  
- Log all operations  

---

# 5. Logs

All logs stored under:


~/repos/sre-laptop-restore/logs/

Key files include:
- `system_restore_runner_*.log`
- `system_restore_validate_*.log`
- `system_restore_*.log`
- `monitor_layout_capture_*.log`
- `monitor_layout_restore_*.log`

---

# 6. Troubleshooting

### **Validation fails**
Check:
- Missing scripts  
- Missing binaries  
- Corrupted JSON  
- GNOME backup not present  

### **Monitor layout incorrect**
Check:
- JSON file validity  
- Display names from `xrandr`  

### **GNOME not restoring**
Ensure:

dconf load / < configs/gnome/dconf_backup.ini

### **Browser optimizations not applied**
Ensure:
- Firefox/Chrome installed  
- Scripts exist and executable  

---

# 7. Recovery Steps

If restore fails:
1. Review logs in `logs/`.  
2. Fix missing files/binaries.  
3. Re-run:

bash system_restore_runner.sh

If JSON is invalid:

bash configs/gnome/monitor_layout_capture.sh

---

# 8. Idempotency

All restore operations are designed to be **safe to run repeatedly**:
- dconf loads overwrite only intended keys  
- Monitor layout restore re-applies geometry safely  
- Browser scripts are side-effect–safe  
- Repo validation never modifies content  

---

# 9. Post-Restore Checklist

☐ GNOME hotkeys restored  
☐ Tiling Assistant active  
☐ Monitors aligned  
☐ Firefox settings applied  
☐ Chrome telemetry disabled  
☐ Git repo clean  
☐ Logs archived  

---

# 10. Summary

This pipeline ensures:
- Fast recovery  
- Deterministic results  
- Reproducible environment  
- Full automation  

Run anytime after OS reinstall:

bash system_restore_runner.sh
