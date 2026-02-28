# Compte rendu - Supervision Zabbix

## Objectif pedagogique
- Configurer et utiliser des outils de supervision pour surveiller la performance, l'etat et la securite des systemes informatiques et des infrastructures reseau. (C3.2.1, C5.2.1)
- Concevoir et mettre en oeuvre des tableaux de bord personnalises pour le suivi en temps reel des indicateurs cles. (C5.4.1, C3.2.1)

## Realisation

### 1) Mise en place Zabbix Server + Web + Base de donnees
Dossier: `/root/Zabbix`

Fichier utilise: `docker-compose.yaml`

Lancement:
```bash
cd /root/Zabbix
docker compose up -d
```

Acces interface:
- URL: `http://<IP_SERVEUR>:8080`
- Compte par defaut: `Admin / zabbix`

Composants deployes:
- PostgreSQL
- Zabbix Server
- Zabbix Web (Nginx)
- Agent local Zabbix (sur le serveur Zabbix)

### 2) Agent sur machine vierge (auto-scaling + auto-discovery + template)
Dossier: `/root/Agent-Zabbix`

Lancement d'un pool d'agents:
```bash
cd /root/Agent-Zabbix
docker compose up -d --scale zbx-agent-autoscale=4
```

Principe:
- Chaque agent envoie des checks actifs vers `zabbix-server`
- `ZBX_HOSTNAMEITEM=system.hostname` donne un hostname unique par conteneur
- `ZBX_METADATA=autoscale-linux` permet de cibler l'auto-enregistrement

Configuration Zabbix (UI):
1. Aller dans `Alerts > Actions > Autoregistration actions > Create action`
2. Condition: `Host metadata contains autoscale-linux`
3. Operations:
- `Add host`
- `Add to host groups`: `Linux servers` (ou groupe dedie)
- `Link templates`: `Linux by Zabbix agent active`

Resultat attendu:
- Les nouveaux agents scales apparaissent automatiquement avec template applique.

### 3) Agents sur 3 machines avec serveur web + API REST Python
Dossier: `/root/App/microservice_python`

Fichiers utilises:
- `monitoring-compose.yml`
- `microservice_user/*`
- `microservice_product/*`
- `microservice_order/*`
- `nginx/machine*/default.conf`

Lancement:
```bash
cd /root/App/microservice_python
docker compose -f monitoring-compose.yml up -d --build
```

Architecture simulee:
- Machine 1: `web-machine-1` (Nginx, port 8081) + `api-machine-1` + `zbx-agent-machine-1`
- Machine 1: `web-machine-1` (Nginx, port 8181) + `api-machine-1` + `zbx-agent-machine-1`
- Machine 2: `web-machine-2` (Nginx, port 8082) + `api-machine-2` + `zbx-agent-machine-2`
- Machine 3: `web-machine-3` (Nginx, port 8083) + `api-machine-3` + `zbx-agent-machine-3`

Auto-enregistrement conseille (UI Zabbix):
1. Creer une action d'auto-registration
2. Condition: `Host metadata contains webapi-linux`
3. Operations:
- `Add host`
- `Add to host groups`: `Web/API`
- `Link templates`: `Linux by Zabbix agent active`

### 4) Tableau de bord personnalise (temps reel)
Dans Zabbix:
1. `Dashboards > Create dashboard`
2. Widgets recommandes:
- `Problems` (filtre groupe `Web/API`)
- `Host availability`
- `Graph` CPU utilisation
- `Graph` Memoire disponible
- `Top hosts` par charge CPU

Indicateurs cles proposes:
- Disponibilite des hotes
- CPU (%), RAM, charge systeme
- Nombre de problemes actifs
- Disponibilite web (via checks HTTP simples sur ports 8081/8082/8083)
- Disponibilite web (via checks HTTP simples sur ports 8181/8082/8083)

## Commandes de verification
```bash
# Voir les conteneurs Zabbix
cd /root/Zabbix && docker compose ps

# Voir les agents autoscales
cd /root/Agent-Zabbix && docker compose ps

# Voir les 3 machines web+api+agent
cd /root/App/microservice_python && docker compose -f monitoring-compose.yml ps
```

## Correction appliquee dans le code Python
Le service `microservice_product/product_service.py` contenait des erreurs de syntaxe.
Le fichier a ete corrige pour exposer correctement l'endpoint REST `/product`.
