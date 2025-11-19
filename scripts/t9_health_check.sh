#!/usr/bin/env bash
#
# t9_health_check.sh
# ------------------------------------------------------------
# Samsung T9 SSD health check with SMART and dual alerting.
# ------------------------------------------------------------

set -euo pipefail

# -------------------------- Config ---------------------------

# Path to the T9 device (prefer /dev/disk/by-id).
T9_DEVICE="${T9_DEVICE:-/dev/disk/by-id/usb-Samsung_PSSD_T9_S742NL0YA00767V-0:0}"

# smartctl binary and options. For USB T9, "-d scsi" is required.
SMARTCTL_BIN="${SMARTCTL_BIN:-/usr/sbin/smartctl}"
SMART_OPTS="${SMART_OPTS:--a -d scsi}"

# Logging
LOG_ROOT="${LOG_ROOT:-$HOME/system-backups/health}"
LOG_FILE="${LOG_ROOT}/t9_health_$(date +%Y%m%d).log"

# Alerting
USE_DESKTOP_ALERTS="${USE_DESKTOP_ALERTS:-true}"
USE_EMAIL_ALERTS="${USE_EMAIL_ALERTS:-true}"
ALERT_EMAIL="${ALERT_EMAIL:-jalozada@gmail.com}"

HOSTNAME="$(hostname)"
NOW="$(date --iso-8601=seconds)"

mkdir -p "${LOG_ROOT}"

# ------------------------ Functions --------------------------

log() {
  local level="$1"; shift
  local msg="$*"
  echo "[$NOW] [${level}] ${msg}" | tee -a "${LOG_FILE}"
}

notify_desktop() {
  local title="$1"
  local body="$2"

  if [[ "${USE_DESKTOP_ALERTS}" == "true" ]] && command -v notify-send >/dev/null 2>&1; then
    notify-send "T9 SSD: ${title}" "${body}" || true
  fi
}

notify_email() {
  local subject="$1"
  local body="$2"

  if [[ "${USE_EMAIL_ALERTS}" == "true" ]] && [[ -n "${ALERT_EMAIL}" ]] && command -v mail >/dev/null 2>&1; then
    printf "%s\n" "${body}" | mail -s "${subject}" "${ALERT_EMAIL}" || true
  fi
}

fail() {
  local msg="$1"
  log "ERROR" "${msg}"
  notify_desktop "check FAILED" "${msg}"
  notify_email "T9 SSD health check FAILED on ${HOSTNAME}" "${msg}"
  exit 1
}

# ----------------------- Pre-flight --------------------------

if [[ ! -e "${T9_DEVICE}" ]]; then
  fail "T9 device not found at ${T9_DEVICE}. Is the drive connected?"
fi

if [[ ! -x "${SMARTCTL_BIN}" ]]; then
  fail "smartctl not found at ${SMARTCTL_BIN}. Install smartmontools."
fi

# -------------------- SMART collection -----------------------

log "INFO" "Starting T9 SSD SMART health check on ${T9_DEVICE}"

SMART_OUTPUT_TMP="$(mktemp)"
trap 'rm -f "${SMART_OUTPUT_TMP}"' EXIT

if ! "${SMARTCTL_BIN}" ${SMART_OPTS} "${T9_DEVICE}" >"${SMART_OUTPUT_TMP}" 2>&1; then
  fail "smartctl command failed. See log file for details."
fi

cat "${SMART_OUTPUT_TMP}" >> "${LOG_FILE}"
log "INFO" "Captured SMART output"

# -------------------- SMART evaluation -----------------------

status="OK"
reason="Overall SMART health PASSED, no critical attributes detected."
temp="unknown"
realloc="unknown"
pending="unknown"

if grep -q "SMART overall-health self-assessment test result" "${SMART_OUTPUT_TMP}"; then
  overall_line="$(grep -m1 'SMART overall-health self-assessment test result' "${SMART_OUTPUT_TMP}")"
  if ! echo "${overall_line}" | grep -q "PASSED"; then
    status="CRIT"
    reason="SMART self-assessment is not PASSED: ${overall_line}"
  fi
fi

if grep -q "Current Drive Temperature" "${SMART_OUTPUT_TMP}"; then
  temp="$(grep 'Current Drive Temperature' "${SMART_OUTPUT_TMP}" | head -n1 | awk '{print $4}')"
fi

if grep -q -i "Reallocated_Sector_Ct" "${SMART_OUTPUT_TMP}"; then
  realloc="$(grep -i 'Reallocated_Sector_Ct' "${SMART_OUTPUT_TMP}" | awk '{print $10}')"
fi

if grep -q -i "Current_Pending_Sector" "${SMART_OUTPUT_TMP}"; then
  pending="$(grep -i 'Current_Pending_Sector' "${SMART_OUTPUT_TMP}" | awk '{print $10}')"
fi

if [[ "${realloc}" != "unknown" ]] && [[ "${realloc}" != "0" ]]; then
  status="WARN"
  reason="Reallocated sectors detected (${realloc})."
fi

if [[ "${pending}" != "unknown" ]] && [[ "${pending}" != "0" ]]; then
  status="CRIT"
  reason="Pending sectors detected (${pending})."
fi

if [[ "${temp}" != "unknown" ]]; then
  if (( temp >= 70 )); then
    status="CRIT"
    reason="High drive temperature: ${temp}°C"
  elif (( temp >= 60 )) && [[ "${status}" == "OK" ]]; then
    status="WARN"
    reason="Elevated drive temperature: ${temp}°C"
  fi
fi

summary="status=${status} reason=\"${reason}\" temp=${temp} realloc=${realloc} pending=${pending}"
log "INFO" "Summary: ${summary}"

case "${status}" in
  OK)
    ;;
  WARN)
    notify_desktop "WARNING" "T9 SSD health warning on ${HOSTNAME}: ${reason}"
    notify_email "T9 SSD health WARNING on ${HOSTNAME}" "Warning at ${NOW}:\n\n${summary}\n\nSee ${LOG_FILE} for details."
    ;;
  CRIT)
    notify_desktop "CRITICAL" "T9 SSD health CRITICAL on ${HOSTNAME}: ${reason}"
    notify_email "T9 SSD health CRITICAL on ${HOSTNAME}" "CRITICAL at ${NOW}:\n\n${summary}\n\nImmediate backup verification recommended.\n\nSee ${LOG_FILE}."
    ;;
esac

log "INFO" "T9 SSD health check completed with status: ${status}"
exit 0
