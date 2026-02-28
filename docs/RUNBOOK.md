# RUNBOOK

## Initialisation

```bash
cd /root/Zabbix
cp .env.example .env
```

## C1 - Zabbix Server/Web/DB

```bash
./scripts/scenario_c1.sh
```

Validation:
- UI: `http://localhost:${ZABBIX_WEB_PORT}`
- host `Zabbix server` en vert

## C2 - Machine vierge (auto-discovery/template)

```bash
./scripts/scenario_c2.sh
```

Validation:
- hosts `agent-1`, `agent-2`, `agent-3`, `agent-4`
- template Linux lie automatiquement

## C3 - 3 machines web+api+agent

```bash
./scripts/scenario_c3.sh
```

Validation:
- hosts `machine-1`, `machine-2`, `machine-3`
- endpoints:
  - `http://localhost:${APP_MACHINE1_WEB_PORT}/api/user`
  - `http://localhost:${APP_MACHINE2_WEB_PORT}/api/product`
  - `http://localhost:${APP_MACHINE3_WEB_PORT}/api/order`

## Nettoyage hôtes techniques

```bash
./scripts/cleanup_stale_hosts.sh --apply
```

## Reset global

```bash
./scripts/scenario_reset.sh
```

Reset complet:
```bash
./scripts/scenario_reset.sh --purge-data --purge-images
```
