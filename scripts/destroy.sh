#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZBX_DIR="$ROOT_DIR/Zabbix"
AGENT_DIR="$ROOT_DIR/Agent-Zabbix"
APP_DIR="$ROOT_DIR/App/microservice_python"

PURGE_DATA=false
PURGE_IMAGES=false

usage() {
  cat <<USAGE
Usage: ./scripts/destroy.sh [options]

Stop and remove the full lab cleanly.

Options:
  --purge-data     Also remove Docker volumes (including PostgreSQL data)
  --purge-images   Also remove locally built images for the app stack
  -h, --help       Show this help
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --purge-data) PURGE_DATA=true ;;
    --purge-images) PURGE_IMAGES=true ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown option: $arg"
      usage
      exit 1
      ;;
  esac
done

down_compose() {
  local compose_file="$1"
  local desc="$2"

  if [[ "$PURGE_DATA" == true ]]; then
    echo "- Stopping $desc (with volumes)..."
    docker compose -f "$compose_file" down --remove-orphans --volumes
  else
    echo "- Stopping $desc..."
    docker compose -f "$compose_file" down --remove-orphans
  fi
}

echo "[1/4] Stopping application monitoring stack..."
down_compose "$APP_DIR/monitoring-compose.yml" "application stack"

echo "[2/4] Stopping autoscale agents stack..."
down_compose "$AGENT_DIR/docker-compose.yaml" "autoscale agents"

echo "[3/4] Stopping Zabbix core stack..."
down_compose "$ZBX_DIR/docker-compose.yaml" "Zabbix core"

if [[ "$PURGE_IMAGES" == true ]]; then
  echo "[4/4] Removing locally built application images..."
  docker image rm -f \
    microservice_python-api-machine-1 \
    microservice_python-api-machine-2 \
    microservice_python-api-machine-3 2>/dev/null || true
else
  echo "[4/4] Image purge skipped (use --purge-images to enable)."
fi

echo "Done."
if [[ "$PURGE_DATA" == true ]]; then
  echo "All stacks stopped and volumes removed."
else
  echo "All stacks stopped and containers removed. Persistent data kept."
fi
