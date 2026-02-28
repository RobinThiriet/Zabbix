# microservice_python

Ce dossier contient la stack applicative Python et la supervision associee.

## Fichiers principaux

- `monitoring-compose.yml`: stack complete de supervision applicative.
  - 3 APIs Python (`api-machine-1..3`)
  - 3 frontaux Nginx (`web-machine-1..3`)
  - 3 agents Zabbix (`zbx-agent-machine-1..3`)
  - 1 agent autoscale supplementaire
- `docker-compose.yml`: compose simple des 3 microservices API (sans Nginx/agents).
- `COMPTE_RENDU_ZABBIX.md`: compte-rendu pedagogique de la mise en place.

## Sous-dossiers

- `microservice_user/`: API REST utilisateurs
- `microservice_product/`: API REST produits
- `microservice_order/`: API REST commandes
- `nginx/`: configuration des 3 frontaux web

## Usage

```bash
cd /root/Zabbix/App/microservice_python
docker compose -f monitoring-compose.yml up -d --build
```
