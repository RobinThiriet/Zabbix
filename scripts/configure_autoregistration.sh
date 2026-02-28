#!/usr/bin/env bash
set -euo pipefail

ZBX_URL="${ZBX_URL:-http://localhost:8080/api_jsonrpc.php}"
ZBX_USER="${ZBX_USER:-Admin}"
ZBX_PASS="${ZBX_PASS:-zabbix}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
  ZBX_URL="${ZBX_URL:-${ZABBIX_API_URL:-http://localhost:${ZABBIX_WEB_PORT:-8080}/api_jsonrpc.php}}"
  ZBX_USER="${ZBX_USER:-${ZABBIX_ADMIN_USER:-Admin}}"
  ZBX_PASS="${ZBX_PASS:-${ZABBIX_ADMIN_PASSWORD:-zabbix}}"
fi

json_call() {
  local payload="$1"
  curl -sS -H 'Content-Type: application/json-rpc' -d "$payload" "$ZBX_URL"
}

login() {
  json_call '{"jsonrpc":"2.0","method":"user.login","params":{"username":"'"$ZBX_USER"'","password":"'"$ZBX_PASS"'"},"id":1}' \
    | sed -n 's/.*"result":"\([^"]*\)".*/\1/p'
}

api_call_auth() {
  local token="$1"
  local payload="$2"
  curl -sS -H 'Content-Type: application/json-rpc' -H "Authorization: Bearer $token" -d "$payload" "$ZBX_URL"
}

create_or_update_action() {
  local token="$1"
  local name="$2"
  local metadata="$3"

  local existing
  existing=$(api_call_auth "$token" '{"jsonrpc":"2.0","method":"action.get","params":{"output":["actionid","name"],"filter":{"name":["'"$name"'"]}},"id":10}' | sed -n 's/.*"actionid":"\([0-9]*\)".*/\1/p' | head -n1)

  local params
  params='{"name":"'"$name"'","eventsource":2,"status":0,"filter":{"evaltype":0,"conditions":[{"conditiontype":24,"operator":2,"value":"'"$metadata"'"}]},"operations":[{"operationtype":2},{"operationtype":4,"opgroup":[{"groupid":"2"}]},{"operationtype":6,"optemplate":[{"templateid":"10001"}]},{"operationtype":8}]}'

  if [[ -n "$existing" ]]; then
    api_call_auth "$token" '{"jsonrpc":"2.0","method":"action.update","params":{"actionid":"'"$existing"'","status":0,"filter":{"evaltype":0,"conditions":[{"conditiontype":24,"operator":2,"value":"'"$metadata"'"}]},"operations":[{"operationtype":2},{"operationtype":4,"opgroup":[{"groupid":"2"}]},{"operationtype":6,"optemplate":[{"templateid":"10001"}]},{"operationtype":8}]},"id":11}' >/dev/null
    echo "Updated action: $name"
  else
    api_call_auth "$token" '{"jsonrpc":"2.0","method":"action.create","params":'"$params"',"id":12}' >/dev/null
    echo "Created action: $name"
  fi
}

echo "Configuring Zabbix auto-registration actions..."
TOKEN="$(login)"
if [[ -z "$TOKEN" ]]; then
  echo "ERROR: Cannot authenticate on Zabbix API ($ZBX_URL)"
  exit 1
fi

create_or_update_action "$TOKEN" "auto-registration-agent" "agent"
create_or_update_action "$TOKEN" "auto-registration-webapi" "webapi-linux"
create_or_update_action "$TOKEN" "auto-registration-autoscale" "autoscale-linux"

echo "Done."
