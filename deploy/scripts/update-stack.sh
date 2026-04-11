#!/usr/bin/env bash
# Pull AxiMate deploy scripts + re-run upstream HiClaw installer (upgrade path per HiClaw docs).
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
  printf 'Created deploy/.env from example — set HICLAW_LLM_API_KEY before non-interactive install.\n' >&2
  exit 2
fi

set -a
# shellcheck disable=SC1091
source deploy/.env
set +a

if [[ "${HICLAW_NON_INTERACTIVE:-0}" == "1" ]] && [[ -z "${HICLAW_LLM_API_KEY:-}" ]]; then
  echo "HICLAW_LLM_API_KEY is required when HICLAW_NON_INTERACTIVE=1" >&2
  exit 3
fi

bash deploy/native/install-hiclaw.sh
