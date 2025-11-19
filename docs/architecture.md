# 🧩 SRE Pipeline Architecture Diagram

### **Author: Javier Antonio Lozada — Lead SRE Architect**

---

## 📘 Overview

This diagram illustrates the **end-to-end lifecycle** of backup, validation, and workstation restoration within the SRE Laptop Restore Framework.

The objective is to ensure:

- Full reproducibility
- Minimal manual touch
- Single-source-of-truth automation
- Clear phase separation
- Observability of each component

---

```mermaid
flowchart TD

    A[Borg Backup Job] --> B[Local Borg Repository]
    B --> C[Backup Validation]
    C --> D[System Restore Pipeline]
    D --> E[GNOME / Tiling Restore]
    D --> F[Browser / VS Code Restore]
    F --> G[Final QA Checks]

    subgraph Automation
        C
        D
        E
        F
    end
```
