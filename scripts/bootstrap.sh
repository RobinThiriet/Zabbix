#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

[[ -f "$ENV_FILE" ]] || { echo "Missing $ENV_FILE. Run: cp .env.example .env"; exit 1; }

ENABLE_AUTOSCALE_STACK="$(grep -E '^ENABLE_AUTOSCALE_STACK=' "$ENV_FILE" 2>/dev/null | tail -n1 | cut -d= -f2- || true)"
ENABLE_AUTOSCALE_STACK="${ENABLE_AUTOSCALE_STACK:-false}"

if [[ "$ENABLE_AUTOSCALE_STACK" == "true" ]]; then
  echo "[bootstrap] ENABLE_AUTOSCALE_STACK=true -> running C2 (machine vierge)"
  exec "$ROOT_DIR/scripts/run_consigne_2_machine_vierge.sh"
else
  echo "[bootstrap] ENABLE_AUTOSCALE_STACK=false -> running C3 (trois machines)"
  exec "$ROOT_DIR/scripts/run_consigne_3_trois_machines.sh"
fi
