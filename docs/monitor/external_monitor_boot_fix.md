# External Monitor Boot Fix (ThinkPad P1 Gen 5)

This document provides a full SRE-grade runbook entry for configuring a Lenovo ThinkPad P1 Gen 5 running Ubuntu so that the LUKS encryption prompt appears **only on external monitors**, with a **safe fallback** enabling the laptop panel when externals are disconnected.

## Overview
This configuration modifies GRUB kernel parameters to control early KMS (kernel mode setting) behavior. It:

- Forces the encryption screen to appear ONLY on external monitors (Acer + Samsung)
- Keeps the laptop panel (eDP-1) OFF during normal docked operation
- Provides **fallback** so the laptop panel turns ON automatically when externals are not connected
- Enables a faster, cleaner boot with `loglevel=3` and hidden systemd job noise

## Final Working Configuration

The final `/etc/default/grub` contains:


GRUB_CMDLINE_LINUX_DEFAULT="quiet splash usbcore.autosuspend=-1 pcie_aspm=off loglevel=3 rd.systemd.show_status=false video=eDP-1:off video=DP-1-0:3840x2160@60 video=DP-1:3840x2160@60"

### Parameter Explanation
- `video=eDP-1:off`: Laptop panel stays OFF unless it is the ONLY detected screen  
- `video=DP-1-0:3840x2160@60`: Force Acer monitor at boot  
- `video=DP-1:3840x2160@60`: Force Samsung monitor at boot  
- `loglevel=3`: Reduce kernel log noise  
- `rd.systemd.show_status=false`: Hide systemd status spam  
- `quiet splash`: Keep Plymouth active and stable  

## Implementation Steps

### **1. Overwrite GRUB Configuration**


sudo bash -c 'cat > /etc/default/grub' << 'GRUBEOF'

/etc/default/grub

GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=lsb_release -i -s 2> /dev/null || echo Debian
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash usbcore.autosuspend=-1 pcie_aspm=off loglevel=3 rd.systemd.show_status=false video=eDP-1:off video=DP-1-0:3840x2160@60 video=DP-1:3840x2160@60"
GRUB_CMDLINE_LINUX=""
GRUBEOF

### **2. Validate**


cat /etc/default/grub

### **3. Update GRUB**


sudo update-grub

### **4. Reboot Tests**

#### Test 1 — Docked (External Monitors Connected)
- Acer + Samsung show the encryption prompt  
- Laptop screen OFF  

#### Test 2 — Undocked (External Monitors Disconnected)
- Laptop panel lights up automatically  
- LUKS prompt appears on laptop screen  

Both tests passed successfully.

## Rollback Procedure

If external monitors fail during boot or unexpected behavior occurs:


sudo sed -i 's/video=eDP-1:off/video=eDP-1:on/' /etc/default/grub
sudo update-grub

## Status
**Current state: VERIFIED WORKING** on ThinkPad P1 Gen 5 with ASUS + Samsung external monitors.
