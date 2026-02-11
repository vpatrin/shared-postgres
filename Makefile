.PHONY: help up down logs psql restart

help: ## Show this help
	@echo "Shared PostgreSQL - Available Commands"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

up: ## Start shared-postgres
	docker compose up -d

down: ## Stop shared-postgres
	docker compose down

logs: ## Show logs (follow)
	docker compose logs -f

psql: ## Open PostgreSQL shell (admin)
	docker exec -it shared-postgres psql -U $$(grep POSTGRES_USER .env | cut -d= -f2)

restart: down up ## Restart shared-postgres
