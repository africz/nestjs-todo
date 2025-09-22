npm:
	$(call npm)
.PHONY: npm

npx:
	$(call npx)
.PHONY: npx

eslint:
	$(call eslint)
.PHONY: eslint

define eslint
	$(call setup_env,$(ENV_FILE))
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	docker exec -it $(ARG1)-node $(LINUX_CMD_SHELL) "npx eslint . --ext .js,.jsx,.ts,.tsx $(RUN_ARGS)"
endef

define vitest
	$(call setup_env,$(ENV_FILE))
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	make npm $(ARG1) "run test"
endef

define npm
	$(call setup_env,$(ENV_FILE))
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(eval ARG3 := $(word 3, $(ARGS)))
	@if [ "$(ARG1)" = "help" ] || [ -z "$(ARG1)" ]; then \
		echo "Available npm options:"; \
		echo "make npm help"; \
		echo "make npm [laravel|vue|react] install"; \
		echo "make npm [laravel|vue|react] update"; \
		echo "make npm [laravel|vue|react] run build"; \
		echo "make npm [laravel|vue|react] run dev"; \
		exit 0; \
	elif [ "$(ARG1)" != "nestjs-be" ] && [ "$(ARG1)" != "nestjs-fe" ] && [ "$(ARG1)" != "laravel" ] && [ "$(ARG1)" != "vue" ] && [ "$(ARG1)" != "react" ]; then \
		echo "Error: The first argument must be 'nestjs-be','nestjs-fe','laravel', 'vue', or 'react'."; \
		exit 1; \
	else \
		echo "Running 'docker exec -it $(ARG1)-node $(LINUX_CMD_SHELL) \"npm $(ARG2) $(ARG3)\"'..."; \
		docker exec -it $(ARG1)-node $(LINUX_CMD_SHELL) "npm $(ARG2) $(ARG3)"; \
	fi
endef 


