#!/usr/bin/env bash
# Idempotent redeploy: git pull + docker compose up --build.
# Run on the server (manually, cron, or CI SSH). Default deploy dir: /opt/aximate
set -euo pipefail

: "${AXIMATE_DEPLOY_DIR:=/opt/aximate}"

if [[ ! -d "$AXIMATE_DEPLOY_DIR/.git" ]]; then
  printf 'AXIMATE_DEPLOY_DIR=%s is not a git clone. Run bootstrap-server.sh first.\n' "$AXIMATE_DEPLOY_DIR" >&2
  exit 1
fi

cd "$AXIMATE_DEPLOY_DIR"
git pull --ff-only

if [[ ! -f deploy/.env ]]; then
  cp deploy/.env.example deploy/.env
  printf 'Created deploy/.env from example — review before production.\n' >&2
fi

docker compose -f deploy/docker-compose.yml --env-file deploy/.env up -d --build
docker compose -f deploy/docker-compose.yml ps
