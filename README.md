# Zabbix Supervision Lab

Plateforme de supervision Docker conforme aux 3 consignes:

1. C1: Zabbix Server + Web + Base de donnees
2. C2: Agent sur machine vierge avec auto-discovery/template (noms lisibles `agent-1..4`)
3. C3: 3 machines logiques, chacune en 3 conteneurs (`web + api + agent`)

## Architecture

```mermaid
flowchart TB
  subgraph C1[Consigne 1 - Core Zabbix]
    PG[(PostgreSQL)]
    ZS[Zabbix Server]
    ZW[Zabbix Web]
    ZA[zabbix-agent local]
    ZW --> ZS
    ZS --> PG
    ZS --> ZA
  end

  subgraph C3[Consigne 3 - 3 machines]
    subgraph M1[machine-1]
      W1[web-machine-1] --> A1[api-machine-1]
      AG1[zbx-agent-machine-1]
    end
    subgraph M2[machine-2]
      W2[web-machine-2] --> A2[api-machine-2]
      AG2[zbx-agent-machine-2]
    end
    subgraph M3[machine-3]
      W3[web-machine-3] --> A3[api-machine-3]
      AG3[zbx-agent-machine-3]
    end
  end

  subgraph C2[Consigne 2 - machine vierge]
    AGF1[agent-1]
    AGF2[agent-2]
    AGF3[agent-3]
    AGF4[agent-4]
  end

  AG1 --> ZS
  AG2 --> ZS
  AG3 --> ZS
  AGF1 --> ZS
  AGF2 --> ZS
  AGF3 --> ZS
  AGF4 --> ZS
```

## Prerequis

```bash
cd /root/Zabbix
cp .env.example .env
```

## Scenarios d'execution

- C1 seulement:
```bash
./scripts/run_consigne_1_core.sh
```

- C2 (C1 + agents `agent-1..4`):
```bash
./scripts/run_consigne_2_machine_vierge.sh
```

- C3 (C1 + 3 machines web/api/agent):
```bash
./scripts/run_consigne_3_trois_machines.sh
```

- Reset propre:
```bash
./scripts/reset_lab.sh
```

## Nettoyage des hotes parasites

```bash
# Apercu
./scripts/cleanup_hosts.sh --dry-run

# Suppression
./scripts/cleanup_hosts.sh --apply
```

## Script principal

`./scripts/bootstrap.sh` choisit automatiquement:
- `run_consigne_2_machine_vierge.sh` si `ENABLE_AUTOSCALE_STACK=true`
- sinon `run_consigne_3_trois_machines.sh`

## Documentation detaillee

- [docs/RUNBOOK.md](docs/RUNBOOK.md)
- [docs/COMPONENTS.md](docs/COMPONENTS.md)
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
