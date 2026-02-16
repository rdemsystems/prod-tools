#!/usr/bin/env bash
# Install check_cluster_time_sync for CheckMK or Nagios/NRPE
set -euo pipefail

SCRIPT_NAME="check_cluster_time_sync"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_SRC="${SCRIPT_DIR}/${SCRIPT_NAME}"

# CheckMK local check paths
CMK_LOCAL_BASE="/usr/lib/check_mk_agent/local"
CMK_LOCAL_CACHED="${CMK_LOCAL_BASE}/900"

# Nagios plugin path
NAGIOS_PLUGINS="/usr/lib/nagios/plugins"

if [[ ! -f "$SCRIPT_SRC" ]]; then
    echo "ERROR: ${SCRIPT_NAME} not found in ${SCRIPT_DIR}"
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Run as root (sudo $0)"
    exit 1
fi

# Detect monitoring system
if [[ -d "$CMK_LOCAL_BASE" ]]; then
    mkdir -p "$CMK_LOCAL_CACHED"
    cp "$SCRIPT_SRC" "${CMK_LOCAL_CACHED}/${SCRIPT_NAME}"
    chmod +x "${CMK_LOCAL_CACHED}/${SCRIPT_NAME}"
    echo "Installed: ${CMK_LOCAL_CACHED}/${SCRIPT_NAME} (CheckMK local check, 900s cache)"
elif [[ -d "$NAGIOS_PLUGINS" ]]; then
    cp "$SCRIPT_SRC" "${NAGIOS_PLUGINS}/${SCRIPT_NAME}"
    chmod +x "${NAGIOS_PLUGINS}/${SCRIPT_NAME}"
    echo "Installed: ${NAGIOS_PLUGINS}/${SCRIPT_NAME} (Nagios/NRPE)"
else
    echo "No monitoring agent detected."
    echo "  CheckMK: mkdir -p ${CMK_LOCAL_CACHED} && cp ${SCRIPT_SRC} ${CMK_LOCAL_CACHED}/"
    echo "  Nagios:  mkdir -p ${NAGIOS_PLUGINS} && cp ${SCRIPT_SRC} ${NAGIOS_PLUGINS}/"
    exit 1
fi
