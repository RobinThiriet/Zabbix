#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

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
META_AGENT="${ZBX_METADATA_AGENT:-agent}"
META_WEBAPI="${ZBX_METADATA_WEBAPI:-webapi-linux}"
META_AUTOSCALE="${ZBX_METADATA_AUTOSCALE:-autoscale-linux}"
LOCAL_HOSTNAME="${ZBX_LOCAL_AGENT_HOSTNAME:-Zabbix server}"

json_call() {
  local payload="$1"
  curl -sS -H 'Content-Type: application/json-rpc' -d "$payload" "$ZBX_URL"
}

api_call_auth() {
  local token="$1"
  local payload="$2"
  curl -sS -H 'Content-Type: application/json-rpc' -H "Authorization: Bearer $token" -d "$payload" "$ZBX_URL"
}

login() {
  json_call '{"jsonrpc":"2.0","method":"user.login","params":{"username":"'"$ZBX_USER"'","password":"'"$ZBX_PASS"'"},"id":1}' \
    | sed -n 's/.*"result":"\([^"]*\)".*/\1/p'
}

create_or_update_action() {
  local token="$1"
  local name="$2"
  local metadata="$3"

  local existing
  existing=$(api_call_auth "$token" '{"jsonrpc":"2.0","method":"action.get","params":{"output":["actionid","name"],"filter":{"name":["'"$name"'"]}},"id":10}' | sed -n 's/.*"actionid":"\([0-9]*\)".*/\1/p' | head -n1)

  if [[ -n "$existing" ]]; then
    api_call_auth "$token" '{"jsonrpc":"2.0","method":"action.update","params":{"actionid":"'"$existing"'","status":0,"filter":{"evaltype":0,"conditions":[{"conditiontype":24,"operator":2,"value":"'"$metadata"'"}]},"operations":[{"operationtype":2},{"operationtype":4,"opgroup":[{"groupid":"2"}]},{"operationtype":6,"optemplate":[{"templateid":"10001"}]},{"operationtype":8}]},"id":11}' >/dev/null
    echo "Updated action: $name"
  else
    api_call_auth "$token" '{"jsonrpc":"2.0","method":"action.create","params":{"name":"'"$name"'","eventsource":2,"status":0,"filter":{"evaltype":0,"conditions":[{"conditiontype":24,"operator":2,"value":"'"$metadata"'"}]},"operations":[{"operationtype":2},{"operationtype":4,"opgroup":[{"groupid":"2"}]},{"operationtype":6,"optemplate":[{"templateid":"10001"}]},{"operationtype":8}]},"id":12}' >/dev/null
    echo "Created action: $name"
  fi
}

fix_local_server_host() {
  local token="$1"
  local host_json
  local hostid
  local interfaceid

  host_json=$(api_call_auth "$token" '{"jsonrpc":"2.0","method":"host.get","params":{"output":["hostid","host"],"selectInterfaces":["interfaceid"],"filter":{"host":["Zabbix server","Zabbix-server"]}},"id":20}')
  hostid=$(echo "$host_json" | sed -n 's/.*"hostid":"\([0-9]\+\)".*/\1/p' | head -n1)
  interfaceid=$(echo "$host_json" | sed -n 's/.*"interfaceid":"\([0-9]\+\)".*/\1/p' | head -n1)

  [[ -z "$hostid" || -z "$interfaceid" ]] && return 0

  # Normalize host name expected by local agent active checks.
  api_call_auth "$token" '{"jsonrpc":"2.0","method":"host.update","params":{"hostid":"'"$hostid"'","host":"'"$LOCAL_HOSTNAME"'"},"id":21}' >/dev/null

  # Use Docker DNS between server and local agent container.
  api_call_auth "$token" '{"jsonrpc":"2.0","method":"hostinterface.update","params":{"interfaceid":"'"$interfaceid"'","useip":0,"ip":"","dns":"zabbix-agent","port":"10050","main":1},"id":22}' >/dev/null

  echo "Updated local host/interface: $LOCAL_HOSTNAME -> zabbix-agent:10050"
}

echo "Configuring Zabbix auto-registration actions..."
TOKEN="$(login)"
if [[ -z "$TOKEN" ]]; then
  echo "ERROR: Cannot authenticate on Zabbix API ($ZBX_URL)"
  exit 1
fi

create_or_update_action "$TOKEN" "auto-registration-agent" "$META_AGENT"
create_or_update_action "$TOKEN" "auto-registration-webapi" "$META_WEBAPI"
create_or_update_action "$TOKEN" "auto-registration-autoscale" "$META_AUTOSCALE"
fix_local_server_host "$TOKEN"

echo "Done."
