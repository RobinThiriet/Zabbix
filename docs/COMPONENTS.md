# Components and Files

Ce document centralise l'explication de tous les dossiers/fichiers du projet.

## `Zabbix/`

- `docker-compose.yaml`
  - Stack coeur:
    - `postgres`
    - `zabbix-server`
    - `zabbix-web`
    - `zabbix-agent` local
  - Variables: DB, timezone, ports Zabbix (`.env`)

## `Agent-Zabbix/`

- `docker-compose.yaml`
  - Service `zbx-agent-autoscale`
  - Connecte au reseau `zabbix_default`
  - Metadata d'auto-registration configurable (`ZBX_METADATA_AUTOSCALE`)

## `App/microservice_python/`

- `monitoring-compose.yml`
  - Simulation de 3 machines:
    - `web-machine-X` (Nginx)
    - `api-machine-X` (Flask)
    - `zbx-agent-machine-X`
  - Ports web parametrables via `.env`
- `docker-compose.yml`
  - Lancement simple des 3 APIs uniquement
- `COMPTE_RENDU_ZABBIX.md`
  - Compte-rendu pedagogique

### `App/microservice_python/microservice_user/`
- `user_service.py`: API REST `/user`
- `Dockerfile`: image Python
- `requirements.txt`: dependances Flask
- `swagger.yaml`: spec API

### `App/microservice_python/microservice_product/`
- `product_service.py`: API REST `/product`
- `Dockerfile`, `requirements.txt`, `swagger.yaml`

### `App/microservice_python/microservice_order/`
- `order_service.py`: API REST `/order`
- `Dockerfile`, `requirements.txt`, `swagger.yaml`

### `App/microservice_python/nginx/`
- `machine1/default.conf` + `index.html`: frontend machine 1 (port variable)
- `machine2/default.conf` + `index.html`: frontend machine 2
- `machine3/default.conf` + `index.html`: frontend machine 3

## `scripts/`

- `bootstrap.sh`
  - Deploy end-to-end
  - Utilise `--env-file .env`
- `configure_autoregistration.sh`
  - Cree/met a jour les actions d'auto-registration via API Zabbix
- `destroy.sh`
  - Arret/suppression propre des stacks
  - Options: `--purge-data`, `--purge-images`

## `docs/`

- `ARCHITECTURE.md`: architecture reseau et schema logique
- `COMPONENTS.md`: (ce document)
- `RUNBOOK.md`: procedures d'exploitation
- `images/monitoring-overview.svg`: visuel de monitoring integre dans le README principal
