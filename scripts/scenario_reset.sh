#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
PURGE_DATA=false
PURGE_IMAGES=false

for arg in "$@"; do
  case "$arg" in
    --purge-data) PURGE_DATA=true ;;
    --purge-images) PURGE_IMAGES=true ;;
    *) echo "Unknown option: $arg"; echo "Usage: $0 [--purge-data] [--purge-images]"; exit 1 ;;
  esac
done

[[ -f "$ENV_FILE" ]] || { echo "Missing $ENV_FILE. Run: cp .env.example .env"; exit 1; }

echo "[RESET] Stopping C3 stack..."
if [[ "$PURGE_DATA" == true ]]; then
  docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/App/microservice_python/monitoring-compose.yml" down --remove-orphans --volumes
else
  docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/App/microservice_python/monitoring-compose.yml" down --remove-orphans
fi

echo "[RESET] Stopping C2 stack..."
if [[ "$PURGE_DATA" == true ]]; then
  docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/Agent-Zabbix/docker-compose.yaml" down --remove-orphans --volumes
else
  docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/Agent-Zabbix/docker-compose.yaml" down --remove-orphans
fi

echo "[RESET] Stopping C1 stack..."
if [[ "$PURGE_DATA" == true ]]; then
  docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/Zabbix/docker-compose.yaml" down --remove-orphans --volumes
else
  docker compose --env-file "$ENV_FILE" -f "$ROOT_DIR/Zabbix/docker-compose.yaml" down --remove-orphans
fi

if [[ "$PURGE_IMAGES" == true ]]; then
  echo "[RESET] Removing local built API images..."
  docker image rm -f microservice_python-api-machine-1 microservice_python-api-machine-2 microservice_python-api-machine-3 2>/dev/null || true
fi

echo "[RESET] Done."
