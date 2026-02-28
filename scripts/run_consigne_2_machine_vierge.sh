#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

[[ -f "$ENV_FILE" ]] || { echo "Missing $ENV_FILE. Run: cp .env.example .env"; exit 1; }

"$ROOT_DIR/scripts/run_consigne_1_core.sh"

echo "[C2] Stopping C3 stack to keep C2 view clean..."
docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/App/microservice_python/monitoring-compose.yml" down --remove-orphans >/dev/null 2>&1 || true

echo "[C2] Starting blank-machine agents (agent-1..4)..."
docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/Agent-Zabbix/docker-compose.yaml" up -d

sleep 5
"$ROOT_DIR/scripts/cleanup_hosts.sh" --mode c2 --apply

echo "[C2] Ready: hosts agent-1..4 should auto-register in Zabbix."
