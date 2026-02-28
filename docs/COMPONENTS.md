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
- `run_consigne_1_core.sh`: execute C1
- `run_consigne_2_machine_vierge.sh`: execute C1 + C2
- `run_consigne_3_trois_machines.sh`: execute C1 + C3
- `reset_lab.sh`: stop/down propre
- `cleanup_hosts.sh`: supprime hotes techniques stale
- `configure_autoregistration.sh`: configure actions + corrige host local
- `bootstrap.sh`: route automatiquement vers C2 ou C3

## `Makefile`
- `make c1`, `make c2`, `make c3`, `make reset`, `make cleanup`, etc.
