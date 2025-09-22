

setup_nestjs:
	$(call setup_nestjs)
.PHONY: setup_nestjs

define setup_nestjs
	@echo "=== Setting Up NestJS Backend and Frontend Application: ==="
	$(call setup_env,$(ENV_FILE))
	@set -a && source $(ENV_FILE) && set +a
	@echo "=== Uninstall first the Application: ==="
	@make uninstall
	@echo "=== Setting Up Application: ==="
	@echo "Creating SSL certificates for Traefik"
	@cd system/${CONFIG_SYSTEM}/tools/nestjs-be/traefik && ./certgen
	@echo "Checking if docker network 'proxy' exists..."
	@if ! docker network ls --format '{{.Name}}' | grep -q '^proxy$$'; then \
			echo "Creating docker network 'proxy'..."; \
			docker network create proxy; \
		else \
			echo "Docker network 'proxy' already exists."; \
		fi
	@echo "Building all containers"
	make build all
	@sleep $(SLEEP)
	@echo "=== Setting up frontend Node.js Installation ==="
	$(call remove_node_modules)

	$(call setup_node,npm run start:dev,npm install,nestjs-fe)

	@echo "=== Setting up backend Node.js Installation ==="
	$(call setup_node,npm run start:dev,npm install,nestjs-be)

	@echo "=== Starting containers ==="
	@make up
	@echo "=== Waiting for npm install (20s - 60s) to finish in frontend and backend ==="
	@start_time=$$(date +%s); \
	while ! docker logs nestjs-fe-node | grep -q "added"; do \
		sleep 1; \
		current_time=$$(date +%s); \
		elapsed=$$((current_time - start_time)); \
		echo "Waiting for nestjs-fe-node... Elapsed time: $${elapsed}s"; \
	done
	@while ! docker logs nestjs-be-node | grep -q "added"; do \
		sleep 1; \
		current_time=$$(date +%s); \
		elapsed=$$((current_time - start_time)); \
		echo "Waiting for nestjs-be-node... Elapsed time: $${elapsed}s"; \
	done
	@echo "=== Restarting frontend and backend Node.js containers ==="
	
	$(call setup_node,npm install,npm run start:dev,nestjs-fe)
	@make restart nestjs-fe-node
	@echo "=== Setting up backend Node.js environment ==="
	$(call setup_node,npm install,npm run start:dev,nestjs-be)
	@make restart nestjs-be-node
	@echo "=== Installation finished successfully ==="
	@echo ""
	@echo "=== Waiting 20 seconds for all containers to be ready ==="
	@sleep 20
	@echo "=== Execute tests, static analysers and formatting checker ==="
	#@make eslint vue
	#@make vitest nestjs-fe
	#@make eslint nestjs-be
	@echo "=== There is no automatic redirection from HTTP to HTTPS. Please use the exact URL. ==="
	@echo ""
	@if [ "$(DOCKER_STACK_SSL)" = "true" ]; then \
		echo "=== SSL is enabled ==="; \
		echo "=== You can access the backend dev server at the following URL: https://nestjs-be-node-${DOMAIN} ==="; \
		echo "=== You can access the frontend dev server at the following URL: https://nestjs-fe-node-${DOMAIN} ==="; \
		echo "=== You can access the backend application at the following URL: https://nestjs-be-${DOMAIN} ==="; \
		echo "=== You can access the frontend application at the following URL: https://nestjs-fe-${DOMAIN} ==="; \
	else \
		echo "=== SSL is disabled ==="; \
		echo "=== You can access the backend dev server at the following URL: http://nestjs-be-node-${DOMAIN} ==="; \
		echo "=== You can access the frontend dev server at the following URL: http://nestjs-fe-node-${DOMAIN} ==="; \
		echo "=== You can access the backend application at the following URL: http://nestjs-be-${DOMAIN} ==="; \
		echo "=== You can access the frontend application at the following URL:http://nestjs-fe-${DOMAIN} ==="; \
	fi
	
endef	

