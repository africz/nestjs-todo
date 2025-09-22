SRC_FOLDER := app
TEST_APP := pest
artisan:
	$(call artisan)
.PHONY: artisan

laravel-install:
	$(call laravel-install)
.PHONY: laravel

define artisan
	$(call setup_env,$(ENV_FILE))
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(eval ARG3 := $(word 3, $(ARGS)))
	$(eval ARG4 := $(word 4, $(ARGS)))
	$(call artisan_exec,$(ARG1),$(ARG2),$(ARG3),$(ARG4))
endef


define artisan_exec
	$(call setup_env,$(ENV_FILE))
	@echo "Executing artisan $(1) $(2) $(3) $(4)"
	@docker exec -it $(CNT) sh -c "./artisan $(1) $(2) $(3) $(4)"

endef

define laravel-install
	$(call setup_env,$(ENV_FILE))
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(eval ARG3 := $(word 3, $(ARGS)))
	$(eval ARG4 := $(word 4, $(ARGS)))
	$(call laravel_exec,$(ARG1),$(ARG2),$(ARG3),$(ARG4))
endef


define laravel_exec
	$(call setup_env,$(ENV_FILE))
	@if [ "$(1)" = "help" ] || [ -z "$(1)" ]; then \
		$(call laravel_exec_help); \
	fi
	@echo "Executing laravel $(1) $(2) $(3) $(4)"
	@docker exec -it $(CNT) sh -c "/root/.config/composer/vendor/bin/laravel $(1) $(2) $(3) $(4)"
endef

define laravel_exec_help
	echo "Available laravel options:" && \
	echo "make laravel" && \
	echo "make laravel [command]" && \
	exit 0
endef
	
define pest
	$(call setup_env,$(ENV_FILE))
	docker exec -it $(CNT) $(LINUX_CMD_SHELL) "vendor/bin/pest $(RUN_ARGS)"
endef

define pest_filter
	$(call setup_env,$(ENV_FILE))
	$(if $(RUN_ARGS),, \
		@echo "Error: You must pass a test name or string to filter. Usage: make test/filter <test name>"; \
		exit 1; \
	)
	docker exec -it $(CNT) $(LINUX_CMD_SHELL) "vendor/bin/pest --filter=$(RUN_ARGS)"
endef

tenant:
	 $(call tenant)
.PHONY: tenant/create

define tenant
	$(call setup_env,$(ENV_FILE))
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(eval ARG3 := $(word 3, $(ARGS)))
	$(eval ARG4 := $(word 4, $(ARGS)))
	$(call tenant_exec,$(ARG1),$(ARG2),$(ARG3),$(ARG4))
endef

define tenant_exec
    $(call setup_env,$(ENV_FILE))
	@if [ -z "$(1)" ] || [ "$(1)" = "help" ]; then \
		$(call tenant_exec_help); \
		exit 0; \
	fi
	@if [ "$(1)" != "create" ] && [ "$(1)" != "dummy" ]; then \
		echo "Error: First parameter must be 'create' or 'dummy'. Usage: make tenant create [domain] or make tenant dummy [domain]"; \
		exit 1; \
	 fi
	@if [ "$(1)" = "create" ] && [ -z "$(2)" ]; then \
		echo "Error: You must pass a domain name. Usage: make tenant create [domain]"; \
		exit 1; \
	fi

	
	@echo "Executing tenant $(1) $(2) $(3) $(4)"

    @CNT=$$(docker ps --filter "name=php" --format "{{.Names}}"); \
    if [ -z "$$CNT" ]; then echo "Error: php container not running"; exit 1; fi; \
    id=$(2); root=laravel-${DOMAIN}; \
    echo "Creating tenant $$id (domain: $$id.$$root)"; \
	tinker_cmd="php artisan tinker --execute=\"\
		\\\$$tenant1=App\\Models\\Tenant::firstOrCreate(['id'=>'$$id']); \
		\\\$$tenant1->domains()->firstOrCreate(['domain'=>'$$id.$$root']); \
		echo 'Created $$id\n';\""; \
	docker exec -i $$CNT sh -c "$$tinker_cmd"	
endef

define tenant_exec_help
	echo "Available tenant options:" && \
	echo "make tenant create [domain]" && \
	exit 0
endef