# Architecture reseau - Plateforme Zabbix

## Topologie

- Stack coeur Zabbix: `/root/Zabbix/Zabbix/docker-compose.yaml`
- Stack agents autoscale: `/root/Zabbix/Agent-Zabbix/docker-compose.yaml`
- Stack applicative (3 machines): `/root/Zabbix/App/microservice_python/monitoring-compose.yml`

## Reseaux Docker

- `zabbix_default` (externe): reseau commun pour Zabbix Server et tous les agents.
- `lab` (local a la stack applicative): communication interne web <-> api pour les 3 machines.

## Flux

1. Les agents Zabbix envoient des checks actifs vers `zabbix-server:10051`.
2. Zabbix Server interroge ensuite les agents en passif sur `10050`.
3. Les serveurs web des machines sont exposes sur l'hote:
- machine-1: `8181`
- machine-2: `8082`
- machine-3: `8083`

## Schema logique

```text
                        +--------------------------+
                        |      zabbix_default      |
                        |                          |
                        |  +--------------------+  |
                        |  | zabbix-server:10051|  |
                        |  +---------+----------+  |
                        |            |             |
                        |  +---------v----------+  |
                        |  | zbx-agent-machine-1|  |
                        |  | zbx-agent-machine-2|  |
                        |  | zbx-agent-machine-3|  |
                        |  | zbx-agent-autoscale|  |
                        |  +--------------------+  |
                        +--------------------------+

+--------------------------------------------------------------+
|                            lab                               |
|  +---------------+      +---------------+      +----------+  |
|  | web-machine-1 | ---> | api-machine-1 |      | port8181 |  |
|  +---------------+      +---------------+      +----------+  |
|  +---------------+      +---------------+      +----------+  |
|  | web-machine-2 | ---> | api-machine-2 |      | port8082 |  |
|  +---------------+      +---------------+      +----------+  |
|  +---------------+      +---------------+      +----------+  |
|  | web-machine-3 | ---> | api-machine-3 |      | port8083 |  |
|  +---------------+      +---------------+      +----------+  |
+--------------------------------------------------------------+
```
