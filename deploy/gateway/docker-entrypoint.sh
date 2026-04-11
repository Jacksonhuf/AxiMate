#!/bin/sh
set -e

ORCH_AUTH=""
if [ -n "${AXIMATE_GATEWAY_BASIC_USER:-}" ] && [ -n "${AXIMATE_GATEWAY_BASIC_PASS:-}" ]; then
  htpasswd -bc /etc/nginx/.htpasswd "$AXIMATE_GATEWAY_BASIC_USER" "$AXIMATE_GATEWAY_BASIC_PASS" >/dev/null
  ORCH_AUTH="    auth_basic \"AxiMate\";
    auth_basic_user_file /etc/nginx/.htpasswd;"
fi

cat >/etc/nginx/conf.d/default.conf <<EOF
server {
  listen 80;
  server_name _;

  location = /healthz {
    default_type application/json;
    return 200 '{"status":"ok","service":"aximate-gateway"}';
  }

  location /api/orchestrator/ {
${ORCH_AUTH}
    proxy_pass http://orchestrator:8080/;
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }

  location /api/worker/ {
${ORCH_AUTH}
    proxy_pass http://worker:8090/;
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOF

exec nginx -g "daemon off;"
