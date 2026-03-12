SHELL := /bin/bash

.DEFAULT_GOAL := help

.PHONY: help init \
	run-c1 run-c2 run-c3 all bootstrap \
	c1 c2 c3 \
	cleanup cleanup-c1 cleanup-c2 cleanup-c3 cleanup-all \
	reset reset-hard destroy destroy-hard \
	status hosts env-show env-edit

help:
	@echo "========================================================="
	@echo " Zabbix Lab - commandes principales"
	@echo "========================================================="
	@echo "Setup initial :"
	@echo "  make init           -> cree .env si absent"
	@echo "  make env-show       -> affiche les variables importantes"
	@echo "  make env-edit       -> ouvre .env dans nano"
	@echo ""
	@echo "Execution des consignes :"
	@echo "  make run-c1         -> C1: core Zabbix uniquement"
	@echo "  make run-c2         -> C2: core + agents nommes agent-1..4"
	@echo "  make run-c3         -> C3: core + 3 machines (web/api/agent)"
	@echo "  make all            -> C1 + C2 + C3 ensemble"
	@echo "  make bootstrap      -> lance C2 ou C3 selon ENABLE_AUTOSCALE_STACK"
	@echo ""
	@echo "Nettoyage :"
	@echo "  make cleanup        -> supprime les hotes stale dans Zabbix (ne touche pas aux conteneurs)"
	@echo "  make cleanup-c1     -> conserve seulement C1"
	@echo "  make cleanup-c2     -> conserve C1 + C2"
	@echo "  make cleanup-c3     -> conserve C1 + C3"
	@echo "  make cleanup-all    -> conserve C1 + C2 + C3"
	@echo "  make destroy        -> stop + remove des stacks C1/C2/C3"
	@echo "  make destroy-hard   -> destroy + volumes + images locales"
	@echo "  make reset          -> arret propre de toutes les stacks"
	@echo "  make reset-hard     -> reset + volumes + images locales"
	@echo ""
	@echo "Verification :"
	@echo "  make status         -> etat des conteneurs des 3 stacks"
	@echo "  make hosts          -> liste des hotes Zabbix via API"
	@echo ""
	@echo "Raccourcis :"
	@echo "  make c1 | make c2 | make c3"
	@echo "========================================================="

init:
	@test -f .env || cp .env.example .env
	@echo "OK: .env present"

run-c1:
	@./scripts/run_consigne_1_core.sh

run-c2:
	@./scripts/run_consigne_2_machine_vierge.sh

run-c3:
	@./scripts/run_consigne_3_trois_machines.sh

all:
	@test -f .env || (echo "Erreur: .env absent. Lance d'abord: make init" && exit 1)
	@./scripts/run_consigne_1_core.sh
	@echo "[ALL] Starting C2 fixed agents..."
	@docker compose --env-file .env -f Agent-Zabbix/docker-compose.yaml up -d
	@echo "[ALL] Starting C3 application monitoring stack..."
	@docker compose --env-file .env -f App/microservice_python/monitoring-compose.yml up -d --build
	@sleep 5
	@./scripts/cleanup_hosts.sh --mode all --apply
	@echo "[ALL] Ready: C1 + C2 + C3"

# Aliases courts (compatibilite)
c1: run-c1
c2: run-c2
c3: run-c3

bootstrap:
	@./scripts/bootstrap.sh

cleanup:
	@./scripts/cleanup_hosts.sh --apply

cleanup-c1:
	@./scripts/cleanup_hosts.sh --mode c1 --apply

cleanup-c2:
	@./scripts/cleanup_hosts.sh --mode c2 --apply

cleanup-c3:
	@./scripts/cleanup_hosts.sh --mode c3 --apply

cleanup-all:
	@./scripts/cleanup_hosts.sh --mode all --apply

reset:
	@./scripts/reset_lab.sh

reset-hard:
	@./scripts/reset_lab.sh --purge-data --purge-images

destroy:
	@./scripts/destroy.sh

destroy-hard:
	@./scripts/destroy.sh --purge-data --purge-images

status:
	@docker compose --env-file .env -f Zabbix/docker-compose.yaml ps
	@docker compose --env-file .env -f Agent-Zabbix/docker-compose.yaml ps
	@docker compose --env-file .env -f App/microservice_python/monitoring-compose.yml ps

hosts:
	@TOKEN=$$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"user.login","params":{"username":"Admin","password":"zabbix"},"id":1}' http://localhost:8080/api_jsonrpc.php | sed -n 's/.*"result":"\([^"]*\)".*/\1/p'); \
	curl -s -X POST -H 'Content-Type: application/json-rpc' -H "Authorization: Bearer $$TOKEN" -d '{"jsonrpc":"2.0","method":"host.get","params":{"output":["hostid","host"],"sortfield":"host"},"id":2}' http://localhost:8080/api_jsonrpc.php | sed 's/},{/}\n{/g'

env-show:
	@test -f .env || (echo "Erreur: .env absent. Lance d'abord: make init" && exit 1)
	@echo "ENABLE_AUTOSCALE_STACK=$$(grep '^ENABLE_AUTOSCALE_STACK=' .env | cut -d= -f2-)"
	@echo "ZABBIX_WEB_PORT=$$(grep '^ZABBIX_WEB_PORT=' .env | cut -d= -f2-)"
	@echo "ZABBIX_SERVER_PORT=$$(grep '^ZABBIX_SERVER_PORT=' .env | cut -d= -f2-)"
	@echo "ZABBIX_AGENT_PORT=$$(grep '^ZABBIX_AGENT_PORT=' .env | cut -d= -f2-)"
	@echo "APP_MACHINE1_WEB_PORT=$$(grep '^APP_MACHINE1_WEB_PORT=' .env | cut -d= -f2-)"
	@echo "APP_MACHINE2_WEB_PORT=$$(grep '^APP_MACHINE2_WEB_PORT=' .env | cut -d= -f2-)"
	@echo "APP_MACHINE3_WEB_PORT=$$(grep '^APP_MACHINE3_WEB_PORT=' .env | cut -d= -f2-)"

env-edit:
	@test -f .env || cp .env.example .env
	@nano .env
