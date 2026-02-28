# scripts

Scripts d'automatisation pour deploiement et exploitation du lab Zabbix.

## Fichiers

- `bootstrap.sh`: lance toute la plateforme dans le bon ordre.
- `configure_autoregistration.sh`: configure via API les actions d'auto-registration.
- `destroy.sh`: arrete et supprime proprement toutes les stacks.

## Utilisation

Lancement complet:
```bash
cd /root/Zabbix
./scripts/bootstrap.sh
```

Arret/suppression propre:
```bash
cd /root/Zabbix
./scripts/destroy.sh
```

Arret + suppression des volumes (reset data):
```bash
cd /root/Zabbix
./scripts/destroy.sh --purge-data
```

Arret + suppression des volumes + images locales:
```bash
cd /root/Zabbix
./scripts/destroy.sh --purge-data --purge-images
```
