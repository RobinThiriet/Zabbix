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

```mermaid
flowchart TB
  subgraph Core[Reseau zabbix_default]
    ZS[zabbix-server:10051]
    ZA0[zbx-agent (local)]
    ZS --> ZA0
  end

  subgraph Lab[Reseau lab - Application Monitoring Stack]
    subgraph M1[Machine 1]
      N1[machine-1]
      W1[web-machine-1 :8181]
      A1[api-machine-1]
      AG1[zbx-agent-machine-1]
      N1 --> W1
      N1 --> AG1
      W1 -->|/api| A1
    end

    subgraph M2[Machine 2]
      N2[machine-2]
      W2[web-machine-2 :8082]
      A2[api-machine-2]
      AG2[zbx-agent-machine-2]
      N2 --> W2
      N2 --> AG2
      W2 -->|/api| A2
    end

    subgraph M3[Machine 3]
      N3[machine-3]
      W3[web-machine-3 :8083]
      A3[api-machine-3]
      AG3[zbx-agent-machine-3]
      N3 --> W3
      N3 --> AG3
      W3 -->|/api| A3
    end
  end

  AG1 -->|active checks| ZS
  AG2 -->|active checks| ZS
  AG3 -->|active checks| ZS
```
