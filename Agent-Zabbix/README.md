# Agent-Zabbix

Ce dossier contient la stack des anciens agents Zabbix en mode autoscale.

## Fichiers

- `docker-compose.yaml`: definit le service `zbx-agent-autoscale` connecte au reseau Docker externe `zabbix_default`.
  - `ZBX_SERVER_HOST` et `ZBX_SERVER_ACTIVE`: pointent vers `zabbix-server`.
  - `ZBX_HOSTNAMEITEM=system.hostname`: nom d'hote automatique.
  - `ZBX_METADATA=autoscale-linux`: metadata utilisee pour l'auto-registration Zabbix.

## Usage

```bash
cd /root/Zabbix/Agent-Zabbix
docker compose -f docker-compose.yaml up -d --scale zbx-agent-autoscale=4
```
