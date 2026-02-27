# Default variables
ENV_FILE := --env-file .env

.PHONY: help
help: ## Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: networking
networking: ## Networking: Usage 'make networking ARGS="up -d"' or 'make networking ARGS="down"'
	docker compose $(ENV_FILE) -f ./networking/docker-compose.yaml ${ARGS}

.PHONY: monitoring
monitoring: ## Monitoring: Usage 'make monitoring ARGS="up -d"' or 'make monitoring ARGS="down"'
	docker compose $(ENV_FILE) -f ./monitoring/docker-compose.yaml ${ARGS}

.PHONY: homepage
homepage: ## Homepage: Usage 'make homepage ARGS="up -d"' or 'make homepage ARGS="down"'
	docker compose $(ENV_FILE) -f ./homepage/docker-compose.yaml ${ARGS}

.PHONY: all-up
all-up: ## Start every service in the project
	make networking ARGS="up -d"
	make monitoring ARGS="up -d"
	make homepage ARGS="up -d"

.PHONY: all-down
all-down: ## Stop every service in the project
	make networking ARGS="down"
	make monitoring ARGS="down"
	make homepage ARGS="down"
