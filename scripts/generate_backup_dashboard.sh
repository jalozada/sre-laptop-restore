#!/usr/bin/env bash
#
# generate_backup_dashboard.sh
# ---------------------------------------------------------------
# Generates a simple HTML dashboard with:
#   - backup_health.json
#   - restore_status.json (if present)
#   - Borg repo summary
# Output: ~/system-backups/health/backup_dashboard.html
# ---------------------------------------------------------------

set -euo pipefail

HEALTH_DIR="$HOME/system-backups/health"
LOG_DIR="$HOME/system-backups/logs/health"
mkdir -p "$HEALTH_DIR" "$LOG_DIR"

OUTFILE="$HEALTH_DIR/backup_dashboard.html"
LOGFILE="$LOG_DIR/dashboard_$(date +'%Y-%m-%d').log"

BACKUP_JSON="$HOME/backup_health.json"
RESTORE_JSON="$HOME/restore_status.json"
BORG_REPO="$HOME/system-backups/borg_repo"

echo "[dashboard] Generating dashboard at $(date)" | tee -a "$LOGFILE"

backup_data="{}"
if [[ -f "$BACKUP_JSON" ]]; then
  backup_data="$(jq '.' "$BACKUP_JSON" 2>/dev/null || echo '{}')"
fi

restore_data="{}"
if [[ -f "$RESTORE_JSON" ]]; then
  restore_data="$(jq '.' "$RESTORE_JSON" 2>/dev/null || echo '{}')"
fi

borg_info="$(borg info "$BORG_REPO" 2>/dev/null || echo 'Borg info not available.')"

cat > "$OUTFILE" << EOF_HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>SRE Laptop Backup Dashboard</title>
  <style>
    body { font-family: sans-serif; margin: 2rem; background: #111; color: #eee; }
    h1, h2 { color: #7dd3fc; }
    pre { background: #222; padding: 1rem; border-radius: 8px; overflow-x: auto; }
    .card { border: 1px solid #333; border-radius: 8px; padding: 1rem; margin-bottom: 1.5rem; background: #181818; }
    code { color: #a5b4fc; }
  </style>
</head>
<body>
  <h1>SRE Laptop Backup Dashboard</h1>
  <p>Generated at: $(date)</p>

  <div class="card">
    <h2>Backup Health (backup_health.json)</h2>
    <pre><code>$(echo "$backup_data")</code></pre>
  </div>

  <div class="card">
    <h2>Restore Status (restore_status.json)</h2>
    <pre><code>$(echo "$restore_data")</code></pre>
  </div>

  <div class="card">
    <h2>Borg Repository Summary</h2>
    <pre><code>$(echo "$borg_info")</code></pre>
  </div>
</body>
</html>
EOF_HTML

echo "[dashboard] Dashboard written to $OUTFILE" | tee -a "$LOGFILE"
