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
  User[Admin Browser\nhttp://localhost:8080] --> ZW

  subgraph Core[Core Zabbix Stack]
    PG[(PostgreSQL)]
    ZS[Zabbix Server\n:10051]
    ZW[Zabbix Web\n:8080]
    ZA0[Local Agent\n:10050]
    ZW --> ZS
    ZS --> PG
    ZS --> ZA0
  end

  subgraph AppStack[Application Monitoring Stack]
    subgraph M1[Machine 1]
      N1[machine-1]
      W1[web-machine-1\n:8181]
      A1[api-machine-1]
      AG1[zbx-agent-machine-1]
      N1 --> W1
      N1 --> AG1
      W1 -->|/api| A1
    end
    subgraph M2[Machine 2]
      N2[machine-2]
      W2[web-machine-2\n:8082]
      A2[api-machine-2]
      AG2[zbx-agent-machine-2]
      N2 --> W2
      N2 --> AG2
      W2 -->|/api| A2
    end
    subgraph M3[Machine 3]
      N3[machine-3]
      W3[web-machine-3\n:8083]
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

  subgraph Autoscale[Autoscale Agents]
    AA[zbx-agent-autoscale-xN]
  end
  AA -->|active checks| ZS
```

Ports are configurable via `.env` (`ZABBIX_WEB_PORT`, `APP_MACHINE*_WEB_PORT`, etc.).

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
- `ENABLE_AUTOSCALE_STACK` (`false` par defaut)

## Lancement complet

```bash
cd /root/Zabbix
./scripts/bootstrap.sh
```

Par defaut, le bootstrap lance uniquement:
- core Zabbix
- stack applicative `machine-1/2/3`

Si tu veux aussi les anciens agents autoscale:
1. mettre `ENABLE_AUTOSCALE_STACK=true` dans `.env`
2. relancer `./scripts/bootstrap.sh`

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
