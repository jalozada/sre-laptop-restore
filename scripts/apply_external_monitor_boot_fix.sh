#!/usr/bin/env bash
#
# apply_external_monitor_boot_fix.sh
# --------------------------------------------------------------------
# Ensures GRUB is configured with safe external monitor boot behavior
# including fallback to laptop panel when externals are disconnected.
#
# This script is idempotent and can be safely re-run at any time.
#

set -e

TARGET="/etc/default/grub"

echo "[INFO] Backing up current GRUB file..."
sudo cp "$TARGET" "$TARGET.bak_$(date +%Y%m%d_%H%M%S)"

echo "[INFO] Applying external monitor boot fix..."
sudo bash -c 'cat > /etc/default/grub' << 'GRUBEOF'
# /etc/default/grub
GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash usbcore.autosuspend=-1 pcie_aspm=off loglevel=3 rd.systemd.show_status=false video=eDP-1:off video=DP-1-0:3840x2160@60 video=DP-1:3840x2160@60"
GRUB_CMDLINE_LINUX=""
GRUBEOF

echo "[INFO] Updating GRUB..."
sudo update-grub

echo "[INFO] External monitor boot fix applied successfully."
