#!/usr/bin/env bash
# From your laptop (Linux/macOS): SSH to server and run bootstrap or update.
# Usage:
#   export AXIMATE_DEPLOY_HOST=212.50.255.125 AXIMATE_DEPLOY_USER=root
#   ./deploy/scripts/deploy-remote.sh           # update
#   ./deploy/scripts/deploy-remote.sh bootstrap # first time
set -euo pipefail

: "${AXIMATE_DEPLOY_HOST:=212.50.255.125}"
: "${AXIMATE_DEPLOY_USER:=root}"
: "${AXIMATE_DEPLOY_DIR:=/opt/aximate}"
: "${AXIMATE_GIT_URL:=https://github.com/Jacksonhuf/AxiMate.git}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${AXIMATE_DEPLOY_USER}@${AXIMATE_DEPLOY_HOST}"
SSH_OPTS=()
if [[ -n "${AXIMATE_SSH_KEY:-}" ]]; then
  SSH_OPTS+=(-i "$AXIMATE_SSH_KEY")
fi

export_remote="export AXIMATE_DEPLOY_DIR='${AXIMATE_DEPLOY_DIR}' AXIMATE_GIT_URL='${AXIMATE_GIT_URL}'"

mode="${1:-update}"
case "$mode" in
  bootstrap)
    ssh "${SSH_OPTS[@]}" "$TARGET" "$export_remote; bash -s" <"$SCRIPT_DIR/bootstrap-server.sh"
    ;;
  update)
    ssh "${SSH_OPTS[@]}" "$TARGET" "$export_remote; bash -s" <"$SCRIPT_DIR/update-stack.sh"
    ;;
  *)
    echo "Usage: $0 [bootstrap|update]" >&2
    exit 1
    ;;
esac
