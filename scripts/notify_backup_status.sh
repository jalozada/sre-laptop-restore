#!/usr/bin/env bash
#
# notify_backup_status.sh
# ---------------------------------------------------------------
# Sends a JSON payload to $BACKUP_WEBHOOK_URL if defined.
# Compatible with Slack/Discord/custom webhook endpoints.
# If BACKUP_WEBHOOK_URL is not set, exits quietly.
# ---------------------------------------------------------------

set -euo pipefail

WEBHOOK_URL="${BACKUP_WEBHOOK_URL:-}"
BACKUP_JSON="$HOME/backup_health.json"

if [[ -z "$WEBHOOK_URL" ]]; then
  exit 0
fi

if ! command -v jq >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
  exit 0
fi

status="unknown"
if [[ -f "$BACKUP_JSON" ]]; then
  status="$(jq -r '.borg_backup // "unknown"' "$BACKUP_JSON" 2>/dev/null || echo "unknown")"
fi

timestamp="$(date +'%Y-%m-%d %H:%M:%S')"
hostname="$(hostname)"

payload=$(jq -n \
  --arg text "SRE Laptop backup on $hostname: status=$status at $timestamp" \
  '{text: $text}')

curl -sS -X POST -H "Content-Type: application/json" \
  -d "$payload" \
  "$WEBHOOK_URL" >/dev/null 2>&1 || true
