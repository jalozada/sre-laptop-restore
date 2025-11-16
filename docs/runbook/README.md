# SRE Laptop Restore – Runbook Index  
**Author:** Javier Antonio Lozada  
**Repository:** grafana-cloud-sre-lab/sre-laptop-restore  
**Last Updated:** $(date +%Y-%m-%d)

---

## 📘 Overview

This directory contains the authoritative **runbook documentation** for the SRE Laptop Restore project.  
It provides complete procedures, architecture diagrams, scripts, and recovery workflows required to rebuild a workstation from a clean OS install.

All documents follow SRE best practices: repeatability, clarity, determinism, and full version control.

---

## 📂 Runbook Modules

### **1. System Restore Pipeline**
The full end-to-end automation pipeline, including:
- Validation
- Monitor layout capture + restore
- GNOME/TilingAssistant restore
- Browser optimization
- Repo consistency checks  

📄 **File:** [`System_Restore_Pipeline.md`](System_Restore_Pipeline.md)

---

## 🧩 Additional Modules (Upcoming)

These pages will be added as the project continues to expand and stabilize:

### **2. GNOME Configuration & Tiling Assistant**
- dconf backup/restore  
- Hotkey mapping  
- Multi-monitor workflow  

### **3. Browser Optimization (Firefox & Chrome)**
- Telemetry disablement  
- Privacy/security hardening  
- Extension preservation (e.g., 1Password)  

### **4. Monitor Configuration System**
- JSON capture format  
- xrandr application  
- Multi-monitor troubleshooting  

---

## 📁 Directory Structure


docs/
└── runbook/
├── README.md
└── System_Restore_Pipeline.md

---

## 🛠 How to Use the Runbook

After a fresh OS install, follow this workflow:

1. Clone the repo  
2. Navigate to this folder  
3. Review the pipeline runbook  
4. Run:  

bash system_restore_runner.sh
5. Validate successful restore using the checklist  

---

## ⭐ SRE Principles Followed

- Deterministic builds  
- Idempotent operations  
- Automatic validation  
- Explicit logging  
- Zero configuration drift  
- Full reproducibility  
- All scripts version-controlled  

---

## 🔗 Related Projects (Future Integration)

- Grafana Cloud SRE Homelab Runbook  
- Kubernetes automation layer  
- Terraform/OIDC pipelines for lab infra  

