#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

[[ -f "$ENV_FILE" ]] || { echo "Missing $ENV_FILE. Run: cp .env.example .env"; exit 1; }

while IFS='=' read -r key value; do
  [[ -z "${key// }" ]] && continue
  [[ "$key" =~ ^[[:space:]]*# ]] && continue
  if [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    export "$key=$value"
  fi
done < "$ENV_FILE"

echo "[C1] Starting Zabbix core..."
docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/Zabbix/docker-compose.yaml" up -d
docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/Zabbix/docker-compose.yaml" up -d --force-recreate zabbix-agent

for _ in {1..60}; do
  if curl -fsS "http://localhost:${ZABBIX_WEB_PORT:-8080}/api_jsonrpc.php" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

"$ROOT_DIR/scripts/configure_autoregistration.sh"
"$ROOT_DIR/scripts/cleanup_stale_hosts.sh" --mode c1 --apply

echo "[C1] Ready: http://localhost:${ZABBIX_WEB_PORT:-8080}"
