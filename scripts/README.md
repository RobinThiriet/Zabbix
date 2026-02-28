# scripts

Scripts d'automatisation pour deploiement et configuration Zabbix.

## Fichiers

- `bootstrap.sh`: deploie l'ensemble des stacks dans le bon ordre:
  1. core Zabbix
  2. actions d'auto-registration
  3. agents autoscale
  4. stack applicative 3 machines
- `configure_autoregistration.sh`: configure via API Zabbix les actions d'auto-registration (metadata `agent`, `webapi-linux`, `autoscale-linux`).

## Usage

```bash
cd /root/Zabbix
./scripts/bootstrap.sh
```
