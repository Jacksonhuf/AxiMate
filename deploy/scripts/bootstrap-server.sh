#!/usr/bin/env bash
# First-time setup on AlmaLinux / RHEL-family (run as root over SSH).
# Defaults match project docs; override with environment variables.
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
  log "Created deploy/.env from example — edit AXIMATE_PUBLIC_HOST and secrets, then re-run update-stack.sh"
fi

if systemctl is-active firewalld >/dev/null 2>&1; then
  if firewall-cmd --state >/dev/null 2>&1; then
    log "Opening http service in firewalld (if not already)..."
    firewall-cmd --permanent --add-service=http >/dev/null 2>&1 || true
    firewall-cmd --reload >/dev/null 2>&1 || true
  fi
fi

cd "$AXIMATE_DEPLOY_DIR"
log "Building and starting stack..."
docker compose -f deploy/docker-compose.yml --env-file deploy/.env up -d --build
docker compose -f deploy/docker-compose.yml ps

log "Done. Health: curl -s http://127.0.0.1/healthz"
