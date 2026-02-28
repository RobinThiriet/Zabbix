SHELL := /bin/bash

.DEFAULT_GOAL := help

help:
	@echo "Targets disponibles:"
	@echo "  make init           -> copie .env.example vers .env si absent"
	@echo "  make c1             -> Consigne 1 (Zabbix core)"
	@echo "  make c2             -> Consigne 2 (machine vierge + agent-1..4)"
	@echo "  make c3             -> Consigne 3 (3 machines web+api+agent)"
	@echo "  make bootstrap      -> route auto vers C2/C3 selon ENABLE_AUTOSCALE_STACK"
	@echo "  make cleanup        -> supprime hotes techniques stale (mode auto)"
	@echo "  make cleanup-c1     -> cleanup mode C1"
	@echo "  make cleanup-c2     -> cleanup mode C2"
	@echo "  make cleanup-c3     -> cleanup mode C3"
	@echo "  make reset          -> stop/down propre"
	@echo "  make reset-hard     -> stop/down + volumes + images"
	@echo "  make status         -> etat des stacks docker"
	@echo "  make hosts          -> liste hotes Zabbix (API)"

init:
	@test -f .env || cp .env.example .env
	@echo "OK: .env present"

c1:
	@./scripts/run_consigne_1_core.sh

c2:
	@./scripts/run_consigne_2_machine_vierge.sh

c3:
	@./scripts/run_consigne_3_trois_machines.sh

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

reset:
	@./scripts/reset_lab.sh

reset-hard:
	@./scripts/reset_lab.sh --purge-data --purge-images

status:
	@docker compose --env-file .env -f Zabbix/docker-compose.yaml ps
	@docker compose --env-file .env -f Agent-Zabbix/docker-compose.yaml ps
	@docker compose --env-file .env -f App/microservice_python/monitoring-compose.yml ps

hosts:
	@TOKEN=$$(curl -s -X POST -H 'Content-Type: application/json-rpc' -d '{"jsonrpc":"2.0","method":"user.login","params":{"username":"Admin","password":"zabbix"},"id":1}' http://localhost:8080/api_jsonrpc.php | sed -n 's/.*"result":"\([^"]*\)".*/\1/p'); \
	curl -s -X POST -H 'Content-Type: application/json-rpc' -H "Authorization: Bearer $$TOKEN" -d '{"jsonrpc":"2.0","method":"host.get","params":{"output":["hostid","host"],"sortfield":"host"},"id":2}' http://localhost:8080/api_jsonrpc.php | sed 's/},{/}\n{/g'
