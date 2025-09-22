define build
	$(call setup_env,$(ENV_FILE))
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(call build_exec,$(ARG1),$(ARG2))
endef


define build_exec
	@if [ "$(1)" = "help" ] || [ -z "$(1)" ]; then \
		echo "Available build options:"; \
		echo "php, mysql,apache,nginx,react-nginx,laravel-nginx,mailbox,redis,redis-commander"; \
		exit 0; \
		elif [ "$(1)" != "all" ] && [ -n "$(1)" ]; then \
			echo "Building with arguments: $(1) $(COMPOSE_FILE)" ; \
			COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROFILES=$(1) docker compose build --build-arg platform=$(PLATFORM) $(1); \
		else \
			echo "Building all containers"; \
			if [ "$(1)" = "all" ]; then \
				echo "Building all containers"; \
				make build php; \
				make build mysql; \
				make build mailbox; \
				make build redis; \
				make build redis-commander; \
				make build node; \
				if [ "$(CONFIG_WEB_SERVER)" = "nginx" ]; then \
					make build nginx; \
				elif [ "$(CONFIG_WEB_SERVER)" = "apache" ]; then \
					make build apache; \
				else \
					echo "Error: CONFIG_WEB_SERVER must be either 'nginx' or 'apache'"; \
					exit 1; \
				fi; \
				make build traefik; \
			fi; \
	fi
endef


define down
	$(call setup_env,$(ENV_FILE))
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(call down_exec,$(ARG1),$(ARG2))
endef


define down_exec

	@if [ "$(1)" = "help" ]; then \
		echo "Available down options:"; \
		echo "down [container] - stop one container"; \
		echo "down -all containers"; \
		exit 0; \
		elif [ -z "$(1)" ]; then \
			echo "Stop all containers"; \
			COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROFILES=all docker compose -p $(PROJECT_NAME) down ; \
		elif [ -n "$(1)" ]; then \
			echo "Down one profile: $(1)"; \
			COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROFILES=$(1) docker compose -p $(PROJECT_NAME) down $(1); \
		else \
			echo "Available down options:"; \
			echo "down [container] - stop one container"; \
			echo "down -all containers"; \
			exit 0; \
	fi
endef


define list
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'
endef

define container_log
	$(call setup_env,$(ENV_FILE))
	@if [ "$(RUN_ARGS)" = "help" ] || [ -z "$(RUN_ARGS)" ]; then \
		echo "Available log options:" ; \
		echo "apache, php, nginx, mysql, node" ; \
		echo "redis, redis-commander, mailbox" ; \
		exit 0; \
	else \
		docker logs -f $(RUN_ARGS); \
	fi
endef

define mount
	$(call setup_env,$(ENV_FILE))
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(call mount_exec,$(ARG1),$(ARG2))
endef


define mount_exec
	$(call setup_env,$(ENV_FILE))
	@if [ "$(1)" = "help" ] || [ -z "$(1)" ]; then \
		echo "Available mount options:"; \
		echo "mount [container]"; \
		exit 0; \
		else \
			echo "mount profile: $(1)"; \
			COMPOSE_PROFILES=$(1) docker exec -it $(1) $(LINUX_SHELL); \
	fi
endef



define up
	$(call setup_env,$(ENV_FILE))
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(call up_exec,$(ARG1),$(ARG2))
endef

define up_exec

	@if [ "$(1)" = "help" ]; then \
		echo "Available run options:"; \
		echo "up [container] - one container"; \
		echo "up -all containers"; \
		exit 0; \
		elif [ -z "$(1)" ]; then \
			echo "Run all containers"; \
			COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROFILES=all docker compose -p $(PROJECT_NAME) up -d ; \
		elif [ -n "$(1)" ]; then \
			echo "Up one profile: $(1)"; \
			COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROFILES=$(1) docker compose -p $(PROJECT_NAME) up -d ; \
		else \
			echo "Available run options:"; \
			echo "up [container] - one container"; \
			echo "up -all containers"; \
			exit 0; \
	fi
endef

define restart
	$(call setup_env,$(ENV_FILE))
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(call restart_exec,$(ARG1),$(ARG2))
endef

define restart_exec
	@if [ "$(1)" = "help" ]; then \
		echo "Available restart options:"; \
		echo "restart [container] - restart one container"; \
		echo "restart - restart all containers"; \
		exit 0; \
	elif [ -z "$(1)" ]; then \
		echo "Restarting all containers"; \
		COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROFILES=all docker compose -p $(PROJECT_NAME) down ; \
		COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROFILES=all docker compose -p $(PROJECT_NAME) up -d ; \
	elif [ -n "$(1)" ]; then \
		echo "Restarting one profile: $(1)"; \
		COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROFILES=$(1) docker compose -p $(PROJECT_NAME) down $(1); \
		COMPOSE_FILE=$(COMPOSE_FILE) COMPOSE_PROFILES=$(1) docker compose -p $(PROJECT_NAME) up -d $(1); \
	else \
		echo "Available restart options:"; \
		echo "restart [container] - restart one container"; \
		echo "restart -all containers"; \
		exit 0; \
	fi
endef

define disable
	$(call setup_env,$(ENV_FILE))
	$(call echo_env)
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(call disable_exec,$(ARG1),$(ARG2))
endef


define disable_exec
	$(call setup_env,$(ENV_FILE))
	@if [ "$(1)" = "help" ] || [ -z "$(1)" ]; then \
		$(call disable_exec_help); \
	elif [ "$(1)" = "xdebug" ] && [ "$(2)" = "cli" ]; then \
			echo "Disable xdebug cli"; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^xdebug\.mode=.*?/xdebug.mode=off/' /etc/php/8.3/cli/conf.d/20-xdebug.ini"  > /dev/null; \
			docker compose restart $(CNT); \
	elif [ "$(1)" = "xdebug" ] && [ "$(2)" = "fpm" ]; then \
			echo "Disable xdebug fpm"; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^xdebug\.mode=.*?/xdebug.mode=off/' /etc/php/8.3/fpm/conf.d/20-xdebug.ini"  > /dev/null; \
			docker compose restart $(CNT); \
	elif [ "$(1)" = "xdebug" ]; then \
			echo "Disable xdebug fpm & cli"; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^xdebug\.mode=.*?/xdebug.mode=off/' /etc/php/8.3/cli/conf.d/20-xdebug.ini"  > /dev/null; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^xdebug\.mode=.*?/xdebug.mode=off/' /etc/php/8.3/fpm/conf.d/20-xdebug.ini"  > /dev/null; \
			docker compose restart $(CNT); \
	elif [ "$(1)" = "opcache" ]; then \
			echo "Disable opcache"; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^opcache.enable=.*?/opcache.enable=0/' /etc/php/8.3/mods-available/opcache.ini"  > /dev/null; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^opcache.enable_cli=.*?/opcache.enable_cli=0/' /etc/php/8.3/mods-available/opcache.ini"  > /dev/null; \
			docker compose restart $(CNT); \
	elif [ "$(1)" = "apcu" ]; then \
			echo "Disable apcu"; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^apc.enabled=.*?/apc.enabled=0/' /etc/php/8.3/mods-available/apcu.ini"  > /dev/null; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^apc.enable_cli=.*?/apc.enable_cli=0/' /etc/php/8.3/mods-available/apcu.ini"  > /dev/null; \
			docker compose restart $(CNT); \
	elif [ "$(1)" = "all" ]; then \
			echo "Disable all options"; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^xdebug\.mode=.*?/xdebug.mode=off/' /etc/php/8.3/cli/conf.d/20-xdebug.ini" > /dev/null ; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^xdebug\.mode=.*?/xdebug.mode=off/' /etc/php/8.3/fpm/conf.d/20-xdebug.ini" > /dev/null ; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^opcache.enable=.*?/opcache.enable=0/' /etc/php/8.3/mods-available/opcache.ini" > /dev/null ; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^opcache.enable_cli=.*?/opcache.enable_cli=0/' /etc/php/8.3/mods-available/opcache.ini" > /dev/null ; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^apc.enabled=.*?/apc.enabled=0/' /etc/php/8.3/mods-available/apcu.ini" > /dev/null; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^apc.enable_cli=.*?/apc.enable_cli=0/' /etc/php/8.3/mods-available/apcu.ini" > /dev/null; \
			docker compose restart $(CNT); \
	else \
		echo "Invalid arguments"; \
		$(call disable_exec_help); \
		exit 1;	\
	fi
endef

define disable_exec_help
	echo "Available options:" && \
	echo "make disable xdebug" && \
	echo "make disable xdebug cli" && \
	echo "make disable xdebug fpm" && \
	echo "make disable opcache" && \
	echo "make disable apcu" && \
	echo "make disable all" && \
	exit 0
endef

define enable
	$(call setup_env,$(ENV_FILE))
	$(call echo_env)
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(call enable_exec,$(ARG1),$(ARG2))
endef


define enable_exec
	$(call setup_env,$(ENV_FILE))
	@if [ "$(1)" = "help" ] || [ -z "$(1)" ]; then \
		$(call enable_exec_help); \
	elif [ "$(1)" = "xdebug" ] && [ "$(2)" = "cli" ]; then \
			echo "Enable xdebug cli"; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^xdebug\.mode=.*?/xdebug.mode=debug/' /etc/php/8.3/cli/conf.d/20-xdebug.ini"  > /dev/null; \
			docker compose restart $(CNT); \
	elif [ "$(1)" = "xdebug" ] && [ "$(2)" = "fpm" ]; then \
			echo "Enable xdebug fpm"; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^xdebug\.mode=.*?/xdebug.mode=debug/' /etc/php/8.3/fpm/conf.d/20-xdebug.ini"  > /dev/null; \
			docker compose restart $(CNT); \
	elif [ "$(1)" = "xdebug" ]; then \
			echo "Enable xdebug fpm & cli"; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^xdebug\.mode=.*?/xdebug.mode=debug/' /etc/php/8.3/cli/conf.d/20-xdebug.ini"  > /dev/null; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^xdebug\.mode=.*?/xdebug.mode=debug/' /etc/php/8.3/fpm/conf.d/20-xdebug.ini"  > /dev/null; \
			docker compose restart $(CNT); \
	elif [ "$(1)" = "opcache" ]; then \
			echo "Enable opcache"; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^opcache.enable=.*?/opcache.enable=1/' /etc/php/8.3/mods-available/opcache.ini"  > /dev/null; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^opcache.enable_cli=.*?/opcache.enable_cli=1/' /etc/php/8.3/mods-available/opcache.ini"  > /dev/null; \
			docker compose restart $(CNT); \
	elif [ "$(1)" = "apcu" ]; then \
			echo "Enable apcu"; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^apc.enabled=.*?/apc.enabled=1/' /etc/php/8.3/mods-available/apcu.ini"  > /dev/null; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^apc.enable_cli=.*?/apc.enable_cli=1/' /etc/php/8.3/mods-available/apcu.ini"  > /dev/null; \
			docker compose restart $(CNT); \
	elif [ "$(1)" = "all" ]; then \
			echo "Enable all options"; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^xdebug\.mode=.*?/xdebug.mode=debug/' /etc/php/8.3/cli/conf.d/20-xdebug.ini" > /dev/null ; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^xdebug\.mode=.*?/xdebug.mode=debug/' /etc/php/8.3/fpm/conf.d/20-xdebug.ini" > /dev/null ; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^opcache.enable=.*?/opcache.enable=1/' /etc/php/8.3/mods-available/opcache.ini" > /dev/null ; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^opcache.enable_cli=.*?/opcache.enable_cli=1/' /etc/php/8.3/mods-available/opcache.ini" > /dev/null ; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^apc.enabled=.*?/apc.enabled=1/' /etc/php/8.3/mods-available/apcu.ini" > /dev/null; \
			docker exec -u root -ti $(CNT) /bin/bash -c "sed -ri 's/^apc.enable_cli=.*?/apc.enable_cli=1/' /etc/php/8.3/mods-available/apcu.ini" > /dev/null; \
			docker compose restart $(CNT); \
	else \
		echo "Invalid arguments"; \
		$(call enable_exec_help); \
		exit 1;	\
	fi
endef

define enable_exec_help
	echo "Available options:" && \
	echo "make enable xdebug" && \
	echo "make enable xdebug cli" && \
	echo "make enable xdebug fpm" && \
	echo "make enable opcache" && \
	echo "make enable apcu" && \
	echo "make enable all" && \
	exit 0
endef


# Catch-all rule to handle undefined targets
%:
	@if [ "$(DEBUG_MAKE_FILE)" = "true" ]; then \
		echo "Warning: Target '$@' is not defined in the Makefile."; \
	fi
	@exit 0
