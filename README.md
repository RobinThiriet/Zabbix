# Zabbix Supervision Lab

Plateforme de supervision Docker, clonable et reconfigurable via un seul fichier `.env`.

## Ce que fournit le projet

- stack coeur Zabbix: PostgreSQL + Zabbix Server + Web + agent local
- stack agents autoscale (auto-registration)
- stack applicative 3 machines logiques (`web + api + agent`) pour la supervision applicative
- scripts d'exploitation: lancement complet, configuration auto-registration, destruction propre

## Capture monitoring

![Monitoring overview](docs/images/monitoring-overview.svg)

## Architecture

```mermaid
flowchart TB
  User[Admin Browser\nhttp://localhost:${ZABBIX_WEB_PORT}] --> ZW

  subgraph Core[Core Zabbix Stack]
    PG[(PostgreSQL)]
    ZS[Zabbix Server\n:${ZABBIX_SERVER_PORT}]
    ZW[Zabbix Web]
    ZA0[Local Agent\n:${ZABBIX_AGENT_PORT}]
    ZW --> ZS
    ZS --> PG
    ZS --> ZA0
  end

  subgraph AppStack[Application Monitoring Stack]
    subgraph M1[Machine 1]
      W1[web-machine-1\n:${APP_MACHINE1_WEB_PORT}] --> A1[api-machine-1]
      AG1[zbx-agent-machine-1]
    end
    subgraph M2[Machine 2]
      W2[web-machine-2\n:${APP_MACHINE2_WEB_PORT}] --> A2[api-machine-2]
      AG2[zbx-agent-machine-2]
    end
    subgraph M3[Machine 3]
      W3[web-machine-3\n:${APP_MACHINE3_WEB_PORT}] --> A3[api-machine-3]
      AG3[zbx-agent-machine-3]
    end
  end

  AG1 -->|active checks| ZS
  AG2 -->|active checks| ZS
  AG3 -->|active checks| ZS
```

## Arborescence

```text
/root/Zabbix
├── .env.example
├── Zabbix/
│   └── docker-compose.yaml
├── Agent-Zabbix/
│   └── docker-compose.yaml
├── App/microservice_python/
│   ├── monitoring-compose.yml
│   ├── docker-compose.yml
│   ├── microservice_user/
│   ├── microservice_product/
│   ├── microservice_order/
│   └── nginx/
├── scripts/
│   ├── bootstrap.sh
│   ├── configure_autoregistration.sh
│   └── destroy.sh
└── docs/
    ├── ARCHITECTURE.md
    ├── COMPONENTS.md
    ├── RUNBOOK.md
    └── images/
```

## Configuration centralisee (`.env`)

Ce projet est concu pour eviter les valeurs hardcodees (ports, metadata, secrets, etc.).

1. Creer le fichier local:
```bash
cd /root/Zabbix
cp .env.example .env
```
2. Modifier les variables selon ta machine (ports deja utilises, mot de passe DB, etc.).

Variables principales:
- `POSTGRES_PASSWORD`
- `ZABBIX_WEB_PORT`
- `ZABBIX_SERVER_PORT`
- `ZABBIX_AGENT_PORT`
- `APP_MACHINE1_WEB_PORT`, `APP_MACHINE2_WEB_PORT`, `APP_MACHINE3_WEB_PORT`

## Lancement complet

```bash
cd /root/Zabbix
./scripts/bootstrap.sh
```

## Destruction propre

```bash
cd /root/Zabbix
./scripts/destroy.sh
```

Options:
- reset data (volumes): `./scripts/destroy.sh --purge-data`
- reset data + images locales: `./scripts/destroy.sh --purge-data --purge-images`

## Rebuild complet

```bash
cd /root/Zabbix
./scripts/destroy.sh --purge-data --purge-images
./scripts/bootstrap.sh
```

## Documentation detaillee

- architecture reseau: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- description de tous les fichiers: [docs/COMPONENTS.md](docs/COMPONENTS.md)
- procedures d'exploitation: [docs/RUNBOOK.md](docs/RUNBOOK.md)
