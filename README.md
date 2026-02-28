# Plateforme de supervision Zabbix (reproductible)

Ce depot permet de reconstruire a l'identique une plateforme de supervision basee sur Zabbix avec:

- `Zabbix Server + Web + PostgreSQL` dans `/root/Zabbix/Zabbix`
- `Anciens agents autoscale` dans `/root/Zabbix/Agent-Zabbix`
- `3 machines applicatives` (web + API REST Python + agent Zabbix) dans `/root/Zabbix/App/microservice_python`

L'objectif est de pouvoir supprimer l'environnement local puis le recreer rapidement depuis GitHub.

## Arborescence

```text
.
├── Zabbix/
│   └── docker-compose.yaml
├── Agent-Zabbix/
│   └── docker-compose.yaml
├── App/
│   └── microservice_python/
│       ├── monitoring-compose.yml
│       ├── docker-compose.yml
│       ├── microservice_user/
│       ├── microservice_product/
│       ├── microservice_order/
│       └── nginx/
├── docs/
│   └── ARCHITECTURE.md
└── scripts/
    ├── bootstrap.sh
    └── configure_autoregistration.sh
```

## Architecture reseau

Voir le detail dans [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

Resume:
- Reseau `zabbix_default`: coeur Zabbix + agents
- Reseau `lab`: web/api des 3 machines
- Exposition web machines:
  - machine-1: `8181`
  - machine-2: `8082`
  - machine-3: `8083`
- Interface Zabbix: `8080`

## Prerequis

- Docker + plugin Docker Compose
- Ports disponibles: `8080`, `10050`, `10051`, `8181`, `8082`, `8083`

## Deploiement rapide (recommande)

```bash
cd /root/Zabbix
./scripts/bootstrap.sh
```

Ce script:
1. demarre Zabbix
2. configure les actions d'auto-registration via API
3. demarre les agents autoscale
4. demarre les 3 machines (web + API + agent)

## Deploiement manuel

```bash
# 1) Coeur Zabbix
cd /root/Zabbix/Zabbix
docker compose -f docker-compose.yaml up -d

# 2) Actions auto-registration
cd /root/Zabbix
./scripts/configure_autoregistration.sh

# 3) Agents autoscale
cd /root/Zabbix/Agent-Zabbix
docker compose -f docker-compose.yaml up -d --scale zbx-agent-autoscale=4

# 4) Stack 3 machines
cd /root/Zabbix/App/microservice_python
docker compose -f monitoring-compose.yml up -d --build
```

## Verification

- Zabbix UI: `http://localhost:8080` (`Admin` / `zabbix`)
- Hosts attendus: `machine-1`, `machine-2`, `machine-3`, `agent-*`
- Endpoints applicatifs:
  - `http://localhost:8181/api/user`
  - `http://localhost:8082/api/product`
  - `http://localhost:8083/api/order`

## Rebuild complet depuis zero

```bash
# Stop stacks
cd /root/Zabbix/App/microservice_python && docker compose -f monitoring-compose.yml down
cd /root/Zabbix/Agent-Zabbix && docker compose -f docker-compose.yaml down
cd /root/Zabbix/Zabbix && docker compose -f docker-compose.yaml down

# (optionnel) supprimer volumes/containers a la main si reset total voulu

# Recreate
cd /root/Zabbix
./scripts/bootstrap.sh
```

## Zone.Identifier (explication)

Les fichiers `*:Zone.Identifier` ne sont pas du code du projet.

Ce sont des metadonnees Windows (Mark-of-the-Web) creees quand des fichiers viennent de Windows/Internet vers WSL. Ils peuvent apparaitre comme de "faux" fichiers sous Linux. Ils sont sans utilite pour l'execution Docker/Python/Zabbix.

Actions prises:
- nettoyage de ces fichiers dans le projet
- ajout d'une regle `.gitignore` pour eviter leur retour

## Notes d'exploitation

- `Dockerhand` a ete nettoye pour ne conserver que `/root/Dockerhand/docker-compose.yaml`.
- Le depot Git est centralise dans: `/root/Zabbix`.
