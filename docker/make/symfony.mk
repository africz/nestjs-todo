SRC_FOLDER := src
TEST_APP := pest
symfony:
	$(call symfony)
.PHONY: symfony

define symfony
	$(call setup_env,$(ENV_FILE))
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(eval ARG2 := $(word 2, $(ARGS)))
	$(eval ARG3 := $(word 3, $(ARGS)))
	$(eval ARG4 := $(word 4, $(ARGS)))
	$(call symfony_exec,$(ARG1),$(ARG2),$(ARG3),$(ARG4))
endef


define symfony_exec
	$(call setup_env,$(ENV_FILE))
	@echo "Executing symfony $(1) $(2) $(3) $(4)"
	@docker exec -it $(CNT) sh -c "symfony $(1) $(2) $(3) $(4)"

endef


define console
	$(call setup_env,$(ENV_FILE))
	$(call echo_env)
	$(eval ARGS := $(subst , ,$(RUN_ARGS)))
	$(eval ARG1 := $(word 1, $(ARGS)))
	$(call console_exec,$(ARG1))
endef


define console_exec
	$(call setup_env,$(ENV_FILE))
	@if [ "$(1)" = "help" ]; then \
		$(call console_exec_help); \
	else \
		echo "Executing console $(1)"; \
			START_TIME=$$(date +%s); \
				docker exec -it $(CNT) $(LINUX_CMD_SHELL) "bin/console $(1)"; \
			END_TIME=$$(date +%s); \
		echo "Execution time: $$((END_TIME - START_TIME)) seconds"; \
fi

endef

define console_exec_help
echo "Available console options:" && \
echo "make console" && \
echo "make console [command]" && \
exit 0
endef

