# Zabbix Auto-Registration Lab

Projet prêt pour GitHub avec:
- Stack Zabbix (Postgres + Server + Web + agent local)
- Stack agents externes (agent-1..4)
- Auto-enregistrement par `host metadata`

## 1) Démarrer la stack Zabbix

```bash
cp .env.example .env
docker compose -f docker-compose.core.yaml up -d
```

Interface Web: `http://localhost:8080`

## 2) Démarrer les agents

```bash
docker compose -f docker-compose.agents.yaml up -d
```

## 3) Configurer l'auto-registration dans Zabbix UI

Menu: `Alerts > Actions > Autoregistration actions`

Créer (ou éditer) une action:
- Name: `auto-enrollement`
- Condition: `Host metadata contains agent`
- Operations:
  - Add host
  - Add to host groups: `Linux servers`
  - Link templates: `Linux by Zabbix agent`
  - Enable host

## 4) Points importants validés

- Utiliser `ZBX_METADATA` (et non `ZBX_HOSTMETADATA`) pour l'image `zabbix/zabbix-agent2`.
- Si l'IP Docker change, préférer `Connect to: DNS` dans l'interface host Zabbix.
  - Exemple: host `Zabbix server` -> DNS `zbx-agent`, port `10050`.

## 5) Vérification rapide

Logs server:

```bash
docker logs --tail 200 zbx-server
```

En cas de succès agent:
- l'erreur `host [agent-x] not found` disparaît
- côté agent: `active checks on server are active again`

## 6) Stop / reset

```bash
docker compose -f docker-compose.agents.yaml down
docker compose -f docker-compose.core.yaml down
```

> Note: ne pas versionner `data/` dans Git.
