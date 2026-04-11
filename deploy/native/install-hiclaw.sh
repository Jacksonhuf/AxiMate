#!/usr/bin/env bash
# Run upstream HiClaw Manager installer (bundles Higress AI Gateway + Matrix + Manager; CoPaw as Worker runtime).
# Docs: https://github.com/alibaba/hiclaw
set -euo pipefail

: "${HICLAW_INSTALLER_URL:=https://raw.githubusercontent.com/alibaba/hiclaw/main/install/hiclaw-install.sh}"

log() { printf '%s\n' "$*"; }

log "Downloading HiClaw installer from upstream..."
curl -fsSL "${HICLAW_INSTALLER_URL}" -o /tmp/hiclaw-install.sh
bash /tmp/hiclaw-install.sh manager
