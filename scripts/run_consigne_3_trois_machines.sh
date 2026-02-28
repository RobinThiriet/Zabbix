#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

[[ -f "$ENV_FILE" ]] || { echo "Missing $ENV_FILE. Run: cp .env.example .env"; exit 1; }

"$ROOT_DIR/scripts/run_consigne_1_core.sh"

echo "[C3] Stopping C2 fixed agents to keep C3 view clean..."
docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/Agent-Zabbix/docker-compose.yaml" down --remove-orphans >/dev/null 2>&1 || true

echo "[C3] Starting application monitoring stack (3 machines)..."
docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/App/microservice_python/monitoring-compose.yml" up -d --build

sleep 5
"$ROOT_DIR/scripts/cleanup_hosts.sh" --mode c3 --apply

echo "[C3] Ready: machine-1, machine-2, machine-3"
