#!/usr/bin/env bash
# First-time setup on AlmaLinux / RHEL-family (run as root).
# Stops legacy AxiMate demo containers, clones this repo for scripts/env, then runs native HiClaw install.
# HiClaw upstream bundles Higress + orchestration; CoPaw is available as a Worker runtime inside HiClaw.
set -euo pipefail

: "${AXIMATE_GIT_URL:=https://github.com/Jacksonhuf/AxiMate.git}"
: "${AXIMATE_DEPLOY_DIR:=/opt/aximate}"

log() { printf '%s\n' "$*"; }

if [[ "${EUID:-0}" -ne 0 ]]; then
  log "Run as root (e.g. sudo $0)"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  log "Installing git..."
  dnf install -y git
fi

if ! command -v docker >/dev/null 2>&1; then
  log "Installing Docker Engine + Compose plugin..."
  dnf install -y dnf-plugins-core
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  systemctl enable --now docker
fi

parent_dir="$(dirname "$AXIMATE_DEPLOY_DIR")"
mkdir -p "$parent_dir"

if [[ ! -d "$AXIMATE_DEPLOY_DIR/.git" ]]; then
  log "Cloning $AXIMATE_GIT_URL -> $AXIMATE_DEPLOY_DIR"
  git clone "$AXIMATE_GIT_URL" "$AXIMATE_DEPLOY_DIR"
else
  log "Repository exists; pulling latest..."
  git -C "$AXIMATE_DEPLOY_DIR" fetch --all --prune
  git -C "$AXIMATE_DEPLOY_DIR" pull --ff-only
fi

if [[ ! -f "$AXIMATE_DEPLOY_DIR/deploy/.env" ]]; then
  cp "$AXIMATE_DEPLOY_DIR/deploy/.env.example" "$AXIMATE_DEPLOY_DIR/deploy/.env"
  log "Created deploy/.env — set HICLAW_LLM_API_KEY (and optional vars), then re-run this script."
  exit 2
fi

# Legacy demo stack (removed from repo): shut down if still present on the host
if [[ -f "$AXIMATE_DEPLOY_DIR/deploy/docker-compose.yml" ]]; then
  log "Stopping legacy AxiMate docker-compose stack (if running)..."
  (cd "$AXIMATE_DEPLOY_DIR" && docker compose -f deploy/docker-compose.yml down --remove-orphans 2>/dev/null) || true
fi

set -a
# shellcheck disable=SC1091
source "$AXIMATE_DEPLOY_DIR/deploy/.env"
set +a

# Default to unattended install on servers (SSH pipes are non-interactive). Set HICLAW_NON_INTERACTIVE=0 in .env for wizard.
export HICLAW_NON_INTERACTIVE="${HICLAW_NON_INTERACTIVE:-1}"

if [[ "${HICLAW_NON_INTERACTIVE}" == "1" ]] && [[ -z "${HICLAW_LLM_API_KEY:-}" ]]; then
  log "HICLAW_NON_INTERACTIVE=1 but HICLAW_LLM_API_KEY is empty. Edit $AXIMATE_DEPLOY_DIR/deploy/.env"
  exit 3
fi

open_hiclaw_ports() {
  if ! systemctl is-active firewalld >/dev/null 2>&1; then
    return 0
  fi
  if ! firewall-cmd --state >/dev/null 2>&1; then
    return 0
  fi
  log "Opening HiClaw-related ports in firewalld (adjust if you use custom HICLAW_PORT_*)..."
  for p in "${HICLAW_PORT_GATEWAY:-18080}" "${HICLAW_PORT_CONSOLE:-18001}" "${HICLAW_PORT_ELEMENT_WEB:-18088}" "${HICLAW_PORT_MANAGER_CONSOLE:-18888}" 8443; do
    firewall-cmd --permanent --add-port="${p}/tcp" >/dev/null 2>&1 || true
  done
  firewall-cmd --reload >/dev/null 2>&1 || true
}

open_hiclaw_ports

log "Starting native HiClaw (upstream) installer — includes Higress; use CoPaw Workers from HiClaw UI..."
bash "$AXIMATE_DEPLOY_DIR/deploy/native/install-hiclaw.sh"

log "Done. Open Element Web at http://127.0.0.1:${HICLAW_PORT_ELEMENT_WEB:-18088} (or your server IP). Higress console: port ${HICLAW_PORT_CONSOLE:-18001}."
