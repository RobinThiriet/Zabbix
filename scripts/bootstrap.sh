#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

# Deployment targets inside this repository
ZBX_DIR="$ROOT_DIR/Zabbix"
AGENT_DIR="$ROOT_DIR/Agent-Zabbix"
APP_DIR="$ROOT_DIR/App/microservice_python"
ENABLE_AUTOSCALE_STACK="$(grep -E '^ENABLE_AUTOSCALE_STACK=' "$ENV_FILE" 2>/dev/null | tail -n1 | cut -d= -f2- || true)"
ENABLE_AUTOSCALE_STACK="${ENABLE_AUTOSCALE_STACK:-false}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: missing $ENV_FILE"
  echo "Create it from .env.example:"
  echo "  cp $ROOT_DIR/.env.example $ENV_FILE"
  exit 1
fi

echo "[1/5] Starting Zabbix core stack..."
docker compose --env-file "$ENV_FILE" -f "$ZBX_DIR/docker-compose.yaml" up -d

echo "[2/5] Waiting for Zabbix API..."
for _ in {1..60}; do
  if curl -fsS http://localhost:8080/api_jsonrpc.php >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "[3/5] Configuring auto-registration actions..."
"$ROOT_DIR/scripts/configure_autoregistration.sh"

if [[ "$ENABLE_AUTOSCALE_STACK" == "true" ]]; then
  echo "[4/5] Starting autoscale agents..."
  docker compose --env-file "$ENV_FILE" -f "$AGENT_DIR/docker-compose.yaml" up -d --scale zbx-agent-autoscale=4
else
  echo "[4/5] Autoscale agents disabled (ENABLE_AUTOSCALE_STACK=false)."
fi

echo "[5/5] Starting application monitoring stack (3 machines)..."
docker compose --env-file "$ENV_FILE" -f "$APP_DIR/monitoring-compose.yml" up -d --build

echo "Deployment complete."
echo "Zabbix UI: http://localhost:8080 (Admin / zabbix)"
echo "Machine web endpoints: http://localhost:8181, http://localhost:8082, http://localhost:8083"
