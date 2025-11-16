#!/usr/bin/env bash
#
# log.sh
# --------------------------------------------------------------------
# Unified logging functions for all SRE restore scripts.
# Provides consistent formatting, timestamping, and coloring.
#
# Usage:
#   source ./scripts/log.sh
#   log_info "message"
#   log_warn "message"
#   log_error "message"
# --------------------------------------------------------------------

# Color codes (safe fallback if terminal does not support colors)
if [[ -t 1 ]]; then
    COLOR_RESET="\033[0m"
    COLOR_INFO="\033[1;34m"   # Blue
    COLOR_WARN="\033[1;33m"   # Yellow
    COLOR_ERROR="\033[1;31m"  # Red
else
    COLOR_RESET=""
    COLOR_INFO=""
    COLOR_WARN=""
    COLOR_ERROR=""
fi

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log_info() {
    echo -e "${COLOR_INFO}[$(timestamp)] INFO:${COLOR_RESET} $1"
}

log_warn() {
    echo -e "${COLOR_WARN}[$(timestamp)] WARN:${COLOR_RESET} $1"
}

log_error() {
    echo -e "${COLOR_ERROR}[$(timestamp)] ERROR:${COLOR_RESET} $1"
}
