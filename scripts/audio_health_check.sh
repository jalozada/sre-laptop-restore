#!/usr/bin/env bash
#
# audio_health_check.sh
# --------------------------------------------------------------------
# Quick health check for PipeWire / PulseAudio / ALSA routing.
# Non-destructive: just prints status.
#

set -euo pipefail

echo "[audio-health] ===== Audio Health Check ====="

echo "[audio-health] PipeWire status:"
systemctl --user is-active pipewire || echo "pipewire: INACTIVE"
systemctl --user is-active wireplumber || echo "wireplumber: INACTIVE"

echo
echo "[audio-health] Default sink:"
pactl info | grep "Default Sink" || echo "No default sink found"

echo
echo "[audio-health] Available sinks:"
pactl list short sinks || echo "No sinks found"

echo
echo "[audio-health] Available cards:"
pactl list short cards || echo "No cards found"

echo
echo "[audio-health] Recent journal entries for audio (last 50 lines):"
journalctl --user -u pipewire --no-pager -n 20 || true
journalctl --user -u wireplumber --no-pager -n 20 || true

echo "[audio-health] ===== End of Audio Health Check ====="
