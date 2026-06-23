# Default variables
FOO := foo

.PHONY: help
help: ## Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: networking
networking: ## Networking: Usage 'make networking ARGS="up -d"' or 'make networking ARGS="down"'
	docker compose --env-file ./networking/.env -f ./networking/docker-compose.yaml ${ARGS}

.PHONY: ci_cd
ci_cd: ## CI/CD: Usage 'make ci_cd ARGS="up -d"' or 'make ci_cd ARGS="down"'
	docker compose --env-file ./ci_cd/.env -f ./ci_cd/docker-compose.yaml ${ARGS}

.PHONY: all-up
all-up: ## Start both networking and ci_cd services
	make networking ARGS="up -d"
	make ci_cd ARGS="up -d"

.PHONY: all-down
all-down: ## Stop both networking and ci_cd services
	make networking ARGS="down"
	make ci_cd ARGS="down"
