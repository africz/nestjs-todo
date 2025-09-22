


define commands
	@echo "=== Available commands: ==="
	@echo make [command] help - show help
	@if [ "$(CONFIG_MONOLITHIC)" = "laravel" ] || [ "$(CONFIG_BACKEND)" = "laravel" ]; then \
		echo make artisan - start laravel artisan; \
	fi
	@echo make build 		- build containers
	@echo make build all	- build all containers
	@echo make composer 	- run composer
	@echo make console 		- start symfony console
	@echo make down 		- stop and remove containers
	@echo make mount 		- mount a container
	@echo make npm 			- run npm
	@echo make phpunit 		- run phpunit
	@echo make setup 		- install application
	@echo make symfony 		- run symfony console
	@echo make uninstall 	- uninstall application
	@echo make up 			- start docker containers
	@echo make codecept 	- run codecept
	@echo make php-cs-fixer - run php-cs-fixer
	@echo make phpcsfixer   - run php-cs-fixer
	@echo make phpstan 		- run phpstan
	@echo make phpunit 		- run phpunit
	@echo make codecept     - run codecept
endef

#simple install command has conflict with composer install command
#just for this project
setup:
	$(call setup)
.PHONY: setup

setup_react_laravel:
	$(call setup_react_laravel)
.PHONY: setup_react_laravel

setup_vue_laravel:
	$(call setup_vue_laravel)
.PHONY: setup_vue_laravel	

setup_wp:
	$(call setup_wp)
.PHONY: setup_wp

setup_laravel_mono:
	$(call setup_laravel_mono)
.PHONY: setup_laravel_mono

uninstall:
	$(call uninstall_application)
.PHONY: uninstall


define setup
	@echo "=== Choose setup type: ==="
	@echo "1. React-Laravel"
	@echo "2. Vue-Laravel"
	@echo "3. WordPress"
	@echo "4. Laravel Monolithic"
	@echo "5. NestJS"
	@read -p "Enter your choice (1-5): " choice; \
	case "$$choice" in \
		1) make setup_react_laravel ;; \
		2) make setup_vue_laravel ;; \
		3) make setup_wp ;; \
		4) make setup_laravel_mono ;; \
		5) make setup_nestjs ;; \
		*) echo "Invalid choice. Please enter 1, 2, 3, 4, or 5"; exit 1 ;; \
	esac
endef


define remove_node_modules
	@echo "=== Removing node_modules directories ==="
	@if [ -z "$(PROJECT_PATH)" ]; then \
		echo "Error: PROJECT_PATH is not set. Please export PROJECT_PATH before running make."; \
		exit 1; \
	fi
	@find $(PROJECT_PATH) -type d -name "node_modules" -exec rm -rf {} +
	@echo "=== node_modules directories removed successfully ==="
endef

define setup_node
	$(call setup_env,$(ENV_FILE))
	@set -a && source $(ENV_FILE) && set +a
	@echo "=== Setting up Node.js environment ==="
	@echo "Using SOURCE_CMD: $(1)"
	@echo "Using DEST_CMD: $(2)"
	@echo "Using PROJECT_PATH: $(PROJECT_PATH)"
	@echo "Using frontend/backend/mono: $(3)"
	@if [ -z "$(PROJECT_PATH)" ]; then \
		echo "Error: PROJECT_PATH is not set. Please export PROJECT_PATH before running make."; \
		exit 1; \
	fi
	@if [ "$(3)" = "mono" ]; then \
		NODE_COMPOSE_FILE="$(PROJECT_PATH)/docker/system/${CONFIG_SYSTEM}/tools/${CONFIG_MONOLITHIC}/node/node-mono-compose.yml"; \
	elif [ "$(3)" = "frontend" ]; then \
			NODE_COMPOSE_FILE="$(PROJECT_PATH)/docker/system/${CONFIG_SYSTEM}/tools/${CONFIG_FRONTEND}/node/node-micro-compose.yml"; \
	elif [ "$(3)" = "nestjs-fe" ]; then \
			NODE_COMPOSE_FILE="$(PROJECT_PATH)/docker/system/${CONFIG_SYSTEM}/tools/nestjs-fe/node/node-micro-compose.yml"; \
	elif [ "$(3)" = "nestjs-be" ]; then \
			NODE_COMPOSE_FILE="$(PROJECT_PATH)/docker/system/${CONFIG_SYSTEM}/tools/nestjs-be/node/node-micro-compose.yml"; \
	elif [ "$(3)" = "backend" ]; then \
		NODE_COMPOSE_FILE="$(PROJECT_PATH)/docker/system/${CONFIG_SYSTEM}/tools/${CONFIG_BACKEND}/node/node-micro-compose.yml"; \
	else \
		echo "Error: Invalid frontend/backend/mono value."; \
		exit 1; \
	fi; \
	echo "Using Node.js compose file: $$NODE_COMPOSE_FILE"; \
	if [ ! -f "$$NODE_COMPOSE_FILE" ]; then \
		echo "Warning: $$NODE_COMPOSE_FILE not found, skipping Node.js setup."; \
		exit 0; \
	fi; \
	if [ -z "$(1)" ]; then \
		echo "Error: SOURCE_CMD is not set. Please provide the source command."; \
		exit 1; \
	fi; \
	if [ -z "$(2)" ]; then \
		echo "Error: DEST_CMD is not set. Please provide the destination command."; \
		exit 1; \
	fi; \
	if [ -z "$(PROJECT_PATH)" ]; then \
		echo "Error: PROJECT_PATH is not set. Please export PROJECT_PATH before running make."; \
		exit 1; \
	fi; \
	if grep -q "$(1)" "$$NODE_COMPOSE_FILE"; then \
		if sed --version >/dev/null 2>&1; then \
			sed -i.bak "s|$(1)|$(2)|g" "$$NODE_COMPOSE_FILE"; \
		else \
			sed -i "" "s|$(1)|$(2)|g" "$$NODE_COMPOSE_FILE"; \
		fi; \
		if grep -q "$(2)" "$$NODE_COMPOSE_FILE"; then \
			echo "Replaced '$(1)' with '$(2)' in $$NODE_COMPOSE_FILE"; \
		else \
			echo "Error: Replacement failed, '$(2)' not found in $$NODE_COMPOSE_FILE"; \
			exit 1; \
		fi; \
	else \
		echo "No occurrences of '$(1)' found in $$NODE_COMPOSE_FILE, nothing replaced."; \
	fi
	
endef


define setup_react_laravel
	@echo "=== Setting Up React-Laravel Application: ==="
	$(call setup_env,$(ENV_FILE))
	@set -a && source $(ENV_FILE) && set +a
	@echo "=== Uninstall first the Application: ==="
	@make uninstall
	@echo "=== Setting Up Application: ==="
	@echo "Creating SSL certificates for Traefik"
	@cd system/${CONFIG_SYSTEM}/tools/react/traefik && ./certgen
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

	$(call setup_node,npm run dev,npm install,frontend)

	@echo "=== Setting up backend Node.js Installation ==="
	$(call setup_node,npm run dev,npm install,backend)
	
	@echo "=== Starting containers ==="
	@make up
	@echo "=== Installing composer packages ==="
	@sleep $(SLEEP)
	@make composer install
	@echo "=== Waiting 20 seconds for the database to be ready ==="
	@sleep 20
	@echo "=== Executing migrations to create database structure ==="
	@make artisan migrate:install
	@make artisan migrate
	@echo "=== Generating application key ==="
	@make artisan key:generate

	@echo "=== Setting up frontend Node.js environment ==="
	
	$(call setup_node,npm install,npm run dev,frontend)
	@make restart react-node
	@echo "=== Setting up backend Node.js environment ==="
	$(call setup_node,npm install,npm run dev,backend)
	@make restart laravel-node


	@echo "=== Installation finished successfully ==="
	@echo ""
	@echo "=== Waiting 20 seconds for all containers to be ready ==="
	@sleep 20
	@echo "=== Execute tests, static analysers and formatting checker ==="
	@make phpstan
	#@make eslint
	@make php-cs-fixer
	@make vitest react
	@make fresh/db
	@make fresh/testdb
	@make test/pest
	@echo "=== There is no automatic redirection from HTTP to HTTPS. Please use the exact URL. ==="
	@echo ""
	@if [ "$(DOCKER_STACK_SSL)" = "true" ]; then \
		echo "=== SSL is enabled ==="; \
		echo "=== You can access the frontend dev server at the following URL: https://react-node-${DOMAIN} ==="; \
		echo "=== You can access the backend application at the following URL: https://laravel-node-${DOMAIN} ==="; \
		echo "=== You can access the frontend application at the following URL: https://laravel-${DOMAIN} ==="; \
		echo "=== You can access the frontend application at the following URL: https://react-${DOMAIN} ==="; \
	else \
		echo "=== SSL is disabled ==="; \
		echo "=== You can access the frontend dev server at the following URL: http://react-node-${DOMAIN} ==="; \
		echo "=== You can access the backend dev server at the following URL: http://laravel-node-${DOMAIN} ==="; \
		echo "=== You can access the backend application at the following URL: http://laravel-${DOMAIN} ==="; \
		echo "=== You can access the frontend application at the following URL:http://react-${DOMAIN} ==="; \
	fi
	
endef	

define setup_vue_laravel
	@echo "=== Setting Up Vue-Laravel Application: ==="
	$(call setup_env,$(ENV_FILE))
	@set -a && source $(ENV_FILE) && set +a
	@echo "=== Uninstall first the Application: ==="
	@make uninstall
	@echo "=== Setting Up Application: ==="
	@echo "Creating SSL certificates for Traefik"
	@cd system/${CONFIG_SYSTEM}/tools/vue/traefik && ./certgen
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
	$(call setup_node,npm run dev,npm install,frontend)

	@echo "=== Setting up backend Node.js Installation ==="
	$(call setup_node,npm run dev,npm install,backend)

	@echo "=== Starting containers ==="
	@make up
	@echo "=== Installing composer packages ==="
	@sleep $(SLEEP)
	@make composer install
	@echo "=== Waiting 20 seconds for the database to be ready ==="
	@sleep 20
	@echo "=== Executing migrations to create database structure ==="
	@make artisan migrate:install
	@make artisan migrate
	@echo "=== Generating application key ==="
	@make artisan key:generate
	@echo "=== Setting up frontend Node.js environment ==="
	$(call setup_node,npm install,npm run dev,frontend)
	@make restart vue-node
	@echo "=== Setting up backend Node.js environment ==="
	$(call setup_node,npm install,npm run dev,backend)
	@make restart laravel-node
	@echo "=== Installation finished successfully ==="
	@echo ""
	@echo "=== Waiting 20 seconds for all containers to be ready ==="
	@sleep 20
	@echo "=== Execute tests, static analysers and formatting checker ==="
	@make phpstan
	#@make eslint vue
	@make php-cs-fixer
	@make vitest vue
	@make fresh/db
	@make fresh/testdb
	@make test/pest
	@echo "=== There is no automatic redirection from HTTP to HTTPS. Please use the exact URL. ==="
	@echo ""
	@if [ "$(DOCKER_STACK_SSL)" = "true" ]; then \
		echo "=== SSL is enabled ==="; \
		echo "=== You can access the backend dev server at the following URL: https://laravel-node-${DOMAIN} ==="; \
		echo "=== You can access the frontend dev server at the following URL: https://vue-node-${DOMAIN} ==="; \
		echo "=== You can access the backend application at the following URL: https://laravel-${DOMAIN} ==="; \
		echo "=== You can access the frontend application at the following URL: https://vue-${DOMAIN} ==="; \
	else \
		echo "=== SSL is disabled ==="; \
		echo "=== You can access the backend dev server at the following URL: http://laravel-node-${DOMAIN} ==="; \
		echo "=== You can access the frontend dev server at the following URL: http://vue-node-${DOMAIN} ==="; \
		echo "=== You can access the backend application at the following URL: http://laravel-${DOMAIN} ==="; \
		echo "=== You can access the frontend application at the following URL:http://vue-${DOMAIN} ==="; \
	fi
	
endef	

define setup_laravel_mono
	@echo "=== Setting Up Monolithic Laravel Application: ==="
	@echo "Using ENV_FILE: $(ENV_FILE)"
	$(call setup_env,$(ENV_FILE))
	@set -a && source $(ENV_FILE) && set +a
	@echo "=== Uninstall first the Application: ==="
	@make uninstall
	@echo "=== Setting Up Laravel Application: ==="
	@echo "Creating SSL certificates for Traefik"
	@cd system/${CONFIG_SYSTEM}/tools/laravel/traefik && ./certgen-mono
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
	@echo "=== Setting up Node.js Installation ==="
	$(call remove_node_modules)

	$(call setup_node,npm run dev,npm install,mono)

	@echo "=== Starting containers ==="
	@make up
	@echo "=== Installing composer packages ==="
	@sleep $(SLEEP)
	@make composer install
	@echo "=== Waiting 20 seconds for the database to be ready ==="
	@sleep 20
	@echo "=== Executing migrations to create database structure ==="
	@make artisan migrate:install
	@make artisan migrate
	@echo "=== Generating application key ==="
	@make artisan key:generate
	@echo "=== Seeding the database with initial data ==="
	@make artisan db:seed
	@echo "=== Setting up Node.js environment ==="
	$(call setup_node,npm install,npm run dev,mono)
	@make restart node
	@echo "=== Installation finished successfully ==="
	@echo ""
	@echo "=== Waiting 20 seconds for all containers to be ready ==="
	@sleep 20
	@echo "=== Execute tests, static analysers and formatting checker ==="
	@make phpstan
	@make php-cs-fixer
	@make test/pest
	@echo "=== There is no automatic redirection from HTTP to HTTPS. Please use the exact URL. ==="
	@echo ""
	@if [ "$(DOCKER_STACK_SSL)" = "true" ]; then \
		echo "=== SSL is enabled ==="; \
		echo "=== You can access the frontend dev server at the following URL: https://node-${DOMAIN} ==="; \
		echo "=== You can access the backend application at the following URL: https://${DOMAIN} ==="; \
	else \
		echo "=== SSL is disabled ==="; \
		echo "=== You can access the frontend dev server at the following URL: http://node-${DOMAIN} ==="; \
		echo "=== You can access the backend application at the following URL: http://${DOMAIN} ==="; \
	fi
endef	

define setup_wp
	$(call setup_env,$(ENV_FILE))
	@set -a && source $(ENV_FILE) && set +a
	@echo "=== Setting Up Wordpress: ==="
	@echo "Creating SSL certificates for Traefik"
	@cd system/${CONFIG_SYSTEM}/tools/wordpress/traefik && ./certgen
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
	@echo "=== Starting containers ==="
	@make up
	@echo "=== Installation finished successfully ==="
	@echo ""
	@echo "=== You may need to wait 10-20 seconds for the initialization to finish and the page to work properly ==="
	@echo "=== There is no automatic redirection from HTTP to HTTPS. Please use the exact URL. ==="
	@echo ""
	@if [ "$(DOCKER_STACK_SSL)" = "true" ]; then \
		echo "=== SSL is enabled ==="; \
		echo "=== You can access the application at the following URL: https://${DOMAIN} ==="; \
	else \
		echo "=== SSL is disabled ==="; \
		echo "=== You can access the application at the following URL: http://${DOMAIN} ==="; \
	fi
	
endef	



define uninstall_application
	@echo "=== Uninstall Application: ==="
	$(call down)
	@set -a
	$(call setup_env,$(ENV_FILE))
	@echo "=== Removing network proxy ==="
	@if docker network ls --format '{{.Name}}' | grep -q '^proxy$$'; then \
		docker network rm proxy; \
	else \
		echo "Docker network 'proxy' does not exist."; \
	fi
	@echo === Remove project images ===
	@sleep $(SLEEP)
	@if [ -z "$(PROJECT_NAME)" ]; then \
		echo "PROJECT_NAME is not set"; \
		exit 1; \
	fi
	@docker images -q ${PROJECT_NAME}* | xargs -r docker rmi -f
	@echo === Remove project volumes ===
	@sleep $(SLEEP)
	@docker volume ls -q | grep ${PROJECT_NAME} | xargs -r docker volume rm -f
	@echo === Uninstall was successful ===
endef	

define schema_spy
 $(call setup_env,$(ENV_FILE))
 docker run --rm \
  -v "${PROJECT_PATH}/docs/schemaspy:/output" \
  schemaspy/schemaspy:latest \
  -t mysql \
  -host host.docker.internal -port 3306 \
  -db ${PROJECT_NAME} -s ${PROJECT_NAME} \
  -u ${PROJECT_NAME} -p ${PROJECT_NAME}
  open ${PROJECT_PATH}/docs/schemaspy/index.html
endef