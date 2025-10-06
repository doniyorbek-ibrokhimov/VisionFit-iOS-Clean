.PHONY: help build up down logs ps clean restart

help: ## Show this help
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker images
	docker compose build

up: ## Start the application in detached mode
	docker compose up -d

down: ## Stop and remove containers
	docker compose down

logs: ## Show and follow container logs
	docker compose logs web -f

ps: ## List running containers
	docker compose ps

clean: ## Remove containers, volumes, cache files, and prune system
	# docker compose down -v
	# docker system prune -f
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} +

restart: ## Restart all services
	docker compose restart

shell: ## Open a bash shell in the web container
	docker compose exec web bash

db-shell: ## Open a PostgreSQL shell in the database container
	docker compose exec db psql -U bobdev -d ceo_chat

# Alembic Migration Commands
migrate: ## Apply all pending migrations
	docker compose exec web alembic upgrade head

migrate-down: ## Rollback the most recent migration
	docker compose exec web alembic downgrade -1

revision: ## Create a new migration (use with message="your message")
	docker compose exec web alembic revision --autogenerate -m "$(message)"

history: ## Show migration history
	docker compose exec web alembic history


ci: ## Run the Continuous Integration pipeline
	docker compose down
	git pull
	docker compose build
	docker compose up -d