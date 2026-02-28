#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
APPLY=false
MODE="c3"

usage() {
  echo "Usage: $0 [--dry-run|--apply] [--mode c1|c2|c3]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=true; shift ;;
    --dry-run) APPLY=false; shift ;;
    --mode)
      MODE="${2:-}"
      [[ -z "$MODE" ]] && { usage; exit 1; }
      shift 2
      ;;
    *) usage; exit 1 ;;
  esac
done

if [[ -f "$ENV_FILE" ]]; then
  while IFS='=' read -r key value; do
    [[ -z "${key// }" ]] && continue
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    if [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
      export "$key=$value"
    fi
  done < "$ENV_FILE"
fi

ZBX_URL="${ZABBIX_API_URL:-http://localhost:${ZABBIX_WEB_PORT:-8080}/api_jsonrpc.php}"
ZBX_USER="${ZABBIX_ADMIN_USER:-Admin}"
ZBX_PASS="${ZABBIX_ADMIN_PASSWORD:-zabbix}"

case "$MODE" in
  c1) KEEP_REGEX='^(Zabbix server)$' ;;
  c2) KEEP_REGEX='^(Zabbix server|agent-1|agent-2|agent-3|agent-4)$' ;;
  c3) KEEP_REGEX='^(Zabbix server|machine-1|machine-2|machine-3)$' ;;
  *) echo "Invalid mode: $MODE"; exit 1 ;;
esac

login() {
  curl -sS -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"user.login","params":{"username":"'"$ZBX_USER"'","password":"'"$ZBX_PASS"'"},"id":1}' "$ZBX_URL" | sed -n 's/.*"result":"\([^"]*\)".*/\1/p'
}

TOKEN="$(login)"
[[ -z "$TOKEN" ]] && { echo "ERROR: API login failed"; exit 1; }

RESP=$(curl -sS -H 'Content-Type: application/json-rpc' -H "Authorization: Bearer $TOKEN" -d '{"jsonrpc":"2.0","method":"host.get","params":{"output":["hostid","host"],"sortfield":"host"},"id":2}' "$ZBX_URL")
mapfile -t HOST_LINES < <(echo "$RESP" | sed 's/},{/}\n{/g' | sed -n 's/.*"hostid":"\([0-9]\+\)".*"host":"\([^"]*\)".*/\1 \2/p')

DELETE_IDS=()
for line in "${HOST_LINES[@]}"; do
  hostid="${line%% *}"
  host="${line#* }"

  if [[ "$host" =~ $KEEP_REGEX ]]; then
    continue
  fi

  # delete stale technical hosts and hosts out-of-scope for selected mode
  if [[ "$host" =~ ^[0-9a-f]{10,}$ ]] || [[ "$host" == "Zabbix-server" ]] || [[ "$host" =~ ^(agent-[1-4]|machine-[1-3])$ ]]; then
    DELETE_IDS+=("$hostid")
    echo "Marked for deletion ($MODE): $host ($hostid)"
  fi
done

if [[ ${#DELETE_IDS[@]} -eq 0 ]]; then
  echo "No stale hosts detected for mode $MODE."
  exit 0
fi

if [[ "$APPLY" != true ]]; then
  echo "Dry-run complete. Re-run with --apply to delete ${#DELETE_IDS[@]} host(s)."
  exit 0
fi

JSON_IDS=$(printf '"%s",' "${DELETE_IDS[@]}")
JSON_IDS="[${JSON_IDS%,}]"

curl -sS -H 'Content-Type: application/json-rpc' -H "Authorization: Bearer $TOKEN" -d '{"jsonrpc":"2.0","method":"host.delete","params":'"$JSON_IDS"',"id":3}' "$ZBX_URL" >/dev/null

echo "Deleted ${#DELETE_IDS[@]} stale host(s) for mode $MODE."
