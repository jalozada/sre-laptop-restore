#!/usr/bin/env bash
#
# fix_default_audio.sh
# ------------------------------------------------------------
# Intelligent audio routing helper.
#
# Modes:
#   1) Default (no args)  -> Force laptop 3.5mm jack as default
#   2) "headset"          -> Force Plantronics/Blackwire USB headset
#
# Both modes:
#   - Set the chosen sink as default
#   - Move all active audio streams to that sink
#
# This script is also called at login via:
#   ~/.config/systemd/user/fix-default-audio.service
# which runs it with NO arguments (3.5mm jack).
# ------------------------------------------------------------

set -euo pipefail

# --- CONFIG --------------------------------------------------

# 3.5mm laptop jack sink (primary default)
PRIMARY_SINK="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink"

# Pattern to detect Plantronics Blackwire USB headset sinks
# Adjust if your actual sink name looks different (use: pactl list short sinks)
HEADSET_PATTERN="${HEADSET_PATTERN:-plantronics|blackwire}"

MODE="${1:-primary}"  # "primary" (default) or "headset"

# --- HELPERS -------------------------------------------------

log() {
  echo "[fix_default_audio] $*" >&2
}

die() {
  log "ERROR: $*"
  exit 1
}

get_sinks() {
  pactl list short sinks
}

set_default_sink() {
  local sink="$1"
  log "Setting default sink to: ${sink}"
  pactl set-default-sink "${sink}"
}

move_all_inputs_to_sink() {
  local sink="$1"
  local inputs
  inputs="$(pactl list short sink-inputs | awk '{print $1}')"

  if [[ -z "${inputs}" ]]; then
    log "No active sink inputs to move."
    return 0
  fi

  for INPUT in ${inputs}; do
    log "Moving sink-input ${INPUT} to ${sink}"
    pactl move-sink-input "${INPUT}" "${sink}" || log "Failed to move sink-input ${INPUT}"
  done
}

find_headset_sink() {
  local sinks="$1"
  # Match by name using HEADSET_PATTERN (case-insensitive)
  echo "${sinks}" | awk -v pat="${HEADSET_PATTERN}" 'BEGIN{IGNORECASE=1} $2 ~ pat {print $2}' | head -n1
}

# --- MAIN LOGIC ----------------------------------------------

SINKS="$(get_sinks)"

case "${MODE}" in
  primary)
    # Always force 3.5mm laptop jack
    if ! echo "${SINKS}" | grep -q "${PRIMARY_SINK}"; then
      die "Primary 3.5mm sink not found: ${PRIMARY_SINK}"
    fi

    TARGET_SINK="${PRIMARY_SINK}"
    ;;

  headset)
    HEADSET_SINK="$(find_headset_sink "${SINKS}")"
    if [[ -z "${HEADSET_SINK}" ]]; then
      die "No headset sink matching pattern '${HEADSET_PATTERN}' found. Check 'pactl list short sinks'."
    fi

    TARGET_SINK="${HEADSET_SINK}"
    log "Detected headset sink: ${TARGET_SINK}"
    ;;

  *)
    die "Unknown mode: ${MODE}. Use: primary (default) or headset"
    ;;
esac

set_default_sink "${TARGET_SINK}"
move_all_inputs_to_sink "${TARGET_SINK}"

log "Done. Active default sink: ${TARGET_SINK}"
exit 0
