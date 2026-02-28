# Runbook

## 1) Initialisation

```bash
cd /root/Zabbix
cp .env.example .env
```

Renseigner au minimum:
- `POSTGRES_PASSWORD`
- ports si conflit local (`ZABBIX_WEB_PORT`, `APP_MACHINE*_WEB_PORT`, etc.)
- `ENABLE_AUTOSCALE_STACK=false` (recommande pour un environnement lisible)

## 2) Deploiement complet

```bash
cd /root/Zabbix
./scripts/bootstrap.sh
```

Par defaut, seuls `machine-1`, `machine-2`, `machine-3` sont provisionnes.
Pour lancer aussi les anciens agents autoscale:
1. passer `ENABLE_AUTOSCALE_STACK=true` dans `.env`
2. relancer `./scripts/bootstrap.sh`

## 3) Verification rapide

- UI Zabbix: `http://localhost:${ZABBIX_WEB_PORT}`
- Hosts attendus: `machine-1`, `machine-2`, `machine-3`, `agent-*`
- Endpoints:
  - `http://localhost:${APP_MACHINE1_WEB_PORT}`
  - `http://localhost:${APP_MACHINE2_WEB_PORT}`
  - `http://localhost:${APP_MACHINE3_WEB_PORT}`

## 4) Arret/suppression propre

```bash
cd /root/Zabbix
./scripts/destroy.sh
```

### Reset complet (data + images)

```bash
./scripts/destroy.sh --purge-data --purge-images
```

## 5) Rebuild from scratch

```bash
cd /root/Zabbix
./scripts/destroy.sh --purge-data --purge-images
./scripts/bootstrap.sh
```
