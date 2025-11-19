#!/usr/bin/env bash
#
# apply_audio_power_fix.sh
# ---------------------------------------------------------------
# Disable aggressive snd_hda_intel power saving to prevent
# audio popping/clicking, HDMI/USB-C audio dropouts, and
# external monitor audio instability.
#
# Idempotent: safe to run repeatedly.
# ---------------------------------------------------------------

set -euo pipefail

CONF_DIR="/etc/modprobe.d"
CONF_FILE="$CONF_DIR/audio-power-save.conf"

echo "[audio-power-fix] Ensuring $CONF_DIR exists..."
sudo mkdir -p "$CONF_DIR"

echo "[audio-power-fix] Writing $CONF_FILE ..."
sudo bash -c "cat > '$CONF_FILE'" << 'CONFEOF'
# Disable snd_hda_intel aggressive power saving
# Prevents audio popping, clicking, and device dropouts
options snd_hda_intel power_save=0 power_save_controller=N
CONFEOF

echo "[audio-power-fix] Fix applied successfully."
echo "[audio-power-fix] Reboot recommended for full effect."
