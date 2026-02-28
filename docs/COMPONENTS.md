# COMPONENTS

## `Zabbix/docker-compose.yaml`
Stack coeur (C1): PostgreSQL, Zabbix Server, Zabbix Web, agent local.

## `Agent-Zabbix/docker-compose.yaml`
Stack C2: 4 agents nommes (`agent-1..4`) avec metadata `agent`.

## `App/microservice_python/monitoring-compose.yml`
Stack C3: 3 machines logiques, chacune avec:
- 1 web (nginx)
- 1 api (flask)
- 1 agent zabbix

## `scripts/`
- `scenario_c1.sh`: execute C1
- `scenario_c2.sh`: execute C1 + C2
- `scenario_c3.sh`: execute C1 + C3
- `scenario_reset.sh`: stop/down propre
- `cleanup_stale_hosts.sh`: supprime hôtes techniques stale
- `configure_autoregistration.sh`: configure actions + corrige host local
- `bootstrap.sh`: route automatiquement vers C2 ou C3
