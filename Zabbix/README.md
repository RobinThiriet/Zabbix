# Zabbix (core)

Ce dossier contient la stack coeur de supervision.

## Fichiers

- `docker-compose.yaml`: deploie:
  - `postgres` (base de donnees Zabbix)
  - `zabbix-server` (moteur de supervision)
  - `zabbix-web` (interface web)
  - `zabbix-agent` (agent local du serveur)

## Ports exposes

- `8080`: interface web Zabbix
- `10051`: serveur Zabbix
- `10050`: agent local

## Usage

```bash
cd /root/Zabbix/Zabbix
docker compose -f docker-compose.yaml up -d
```
